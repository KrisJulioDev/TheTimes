     //
//  SPDownloaer.m
//  Jigsaw
//
//  Created by SAMI EDDAIKRA on 5/4/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SPDownloader.h"
#import "Config.h"
#import "UserInterfaceUtils.h"
#import "configOptions.h"

#define kBytes_already_downloaded @"downloadedBytes"
#define kShouldResumeDownload @"shouldResumeDownload"
#define kfileClosedOK @"fileHasBeenClosed"
#define kUnzipStatusForFile @"unzipStatusForFile"
#define kSizeByFileDict(DATE_ENTRY) [NSString stringWithFormat:@"sizeByFile%@", DATE_ENTRY]

#define kLowConnectionSpeedTime 120.0
#define kLowConnectionSpeedAmount 3072000

@implementation SPDownloader

NSString * const OVERRIDDEN_REGION_KEY = @"overriddenRegion";
NSString * const PAPER_REGION_KEY = @"region";

@synthesize errorMessage, delegate, isDownloading, myURL, isShowingManager, isPauseDownloadedManually, willResign;
@synthesize hasSpeedError, startDate;
@synthesize edition;

+(SPDownloader *) mySPDownloader {
	static SPDownloader *SPDownloaderSingleton;
	
	if (!SPDownloaderSingleton) {
		SPDownloaderSingleton = [[SPDownloader alloc] init];
	}
	return SPDownloaderSingleton;
}

-(id) init {
	self = [super init];
	return self;
} 

/* startDownload - calls when user tap the download button from edition
 * params theEdition - edition to be downloaded
 * params isAutomated - will be use for future implementation
 * the method will check if there is saved state to resume, else it downloads from the beginning
 */
- (void) startDownload:(Edition *)theEdition isAutomated:(BOOL)isAutomated
{
	theFile = nil;
	hasSpeedError = NO;
	isDownloading = YES;
	totalDataReceived = 0;
	bytesAlreadyDownloaded = 0;
	fileSizeExpected = 0;
	isPauseDownloadedManually = NO;
	
    self.edition = theEdition;
	self.myURL = theEdition.paperUrl;
    NSString *theURL = myURL;
	
	NSDictionary *bytesForFiles = [[NSUserDefaults standardUserDefaults] objectForKey:kSizeByFileDict(edition.dateString)];
	NSDictionary *filesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK];
	
	double size = 0;
	size =  [[bytesForFiles objectForKey:theURL] doubleValue];
	int fileClosed = 0;
	fileClosed = [[filesDict objectForKey:theURL] intValue];
	
	if (size> 0 && fileClosed == 1)
    {
        self.startDate =nil;
		[self resumeDownload:size];
	}
	else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.myURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kLowConnectionSpeedTime];
        [request setValue:[NSString stringWithFormat:@"%@",[defaults valueForKey:@"token"]] forHTTPHeaderField: @"ACS-Auth-TokenId"];
        [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        self.startDate =[NSDate date];
		myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSLog(@"REQUEST %@", request);
	}
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; ;
}

// the pause method saves in the UserDefaults the number of bytes downloaded to allow resuming download for later.
// It also closes the file so it can be opened later to add the rest of the data
-(void) pauseDownload
{
    if (!isDownloading) return;
    
    isPauseDownloadedManually = YES;
    
    [theFile closeFile];
    self.startDate = nil;
	//if(!isPauseDownloadedManually){
    //totalDataReceived=0;
    //}
    
	NSMutableDictionary *bytesForFiles = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kSizeByFileDict(edition.dateString)]];
	if (!bytesForFiles) {
		bytesForFiles = [[NSMutableDictionary alloc] initWithCapacity:1];
	}
	if (totalDataReceived > 0) {
		[bytesForFiles setObject:[NSNumber numberWithLongLong:totalDataReceived] forKey:myURL];
	}
	[[NSUserDefaults standardUserDefaults] setObject:bytesForFiles forKey:kSizeByFileDict(edition.dateString)];
	
	NSMutableDictionary *filesDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK]];
	[filesDict setObject:[NSNumber numberWithInt:1] forKey:myURL];
	[[NSUserDefaults standardUserDefaults] setObject:filesDict forKey:kfileClosedOK];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[myConnection cancel];
	isDownloading = NO;
	
	// we notify the delegate (EditorManager) that the download has been paused. So he can cerate the appropriate managed object
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(downloadStoppedForURL:toPath:file:success:)])
    {
		[delegate downloadStoppedForURL:self.myURL toPath:fileDirectory file:fileFullPath success:NO];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void) clearDownloadOnDelete:(NSMutableArray*) latestEditions {
    
    NSMutableDictionary *bytesForFiles;
	 
    for (Edition *e in latestEditions) {
        bytesForFiles  = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kSizeByFileDict(e.dateString)]];
        
        if ( [bytesForFiles objectForKey:e.paperUrl] ) {
            [bytesForFiles removeObjectForKey:e.paperUrl];
            [[NSUserDefaults standardUserDefaults] setObject:bytesForFiles forKey:kSizeByFileDict(e.dateString)];
        }
    }
    
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[myConnection cancel];
	isDownloading = NO;
	
	// we notify the delegate (EditorManager) that the download has been paused. So he can cerate the appropriate managed object
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(downloadStoppedForURL:toPath:file:success:)])
    {
		[delegate downloadStoppedForURL:self.myURL toPath:fileDirectory file:fileFullPath success:NO];
	}
    
	isPauseDownloadedManually = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

-(void) resumeDownload:(double)fromBytes
{
	//we retrieve the number of bytes already downloaded
    //bytesAlreadyDownloaded = [[[NSUserDefaults standardUserDefaults] objectForKey:kBytes_already_downloaded] integerValue];
    //totalDataReceived = bytesAlreadyDownloaded;
	
    totalDataReceived = (double)fromBytes;
	self.startDate = nil;
	// creating a new URLRequest (mutable so we can add in the header the range of the bytes)
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.myURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
	[request setValue:[NSString stringWithFormat:@"%@",[defaults valueForKey:@"token"]] forHTTPHeaderField: @"ACS-Auth-TokenId"];
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"bytes" forHTTPHeaderField:@"Accept-Ranges"];
	[request addValue:[NSString stringWithFormat:@"bytes=%f-", fromBytes] forHTTPHeaderField:@"Range"];
	myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    isPauseDownloadedManually = NO;
}

/* Periodically check for connection speed
 */
- (void)checkData
{
	// if no more than 512 Kb in 20 seconds, the connection is very poor, we pause it
	if (dataReceivedForThisConnection < kLowConnectionSpeedAmount && isDownloading) 
	{
		hasSpeedError = YES;
        
        //isDownloading = NO; 
        
        if(checkIfDataReceived!=nil){
            checkIfDataReceived = nil;
           [checkIfDataReceived invalidate]; 
        }
	}
	else if (isDownloading) {
		dataReceivedForThisConnection = 0;
		[NSTimer scheduledTimerWithTimeInterval:kLowConnectionSpeedTime target:self selector:@selector(checkData) userInfo:nil repeats:NO];
	}
	 
}

#pragma mark NSURLConnection interface
-(void) connection:(NSURLConnection *) connection didReceiveResponse: (NSURLResponse *)response
{
	// we need to make sure the content size is > 0 so that there is something to write into the file
	if (response.expectedContentLength > 0) {
		
		// timer to check if after 20 seconds 
		checkIfDataReceived = [NSTimer scheduledTimerWithTimeInterval:kLowConnectionSpeedTime target:self selector:@selector(checkData) userInfo:nil repeats:NO];
		dataReceivedForThisConnection = 0;
		
		fileSizeExpected = [[NSNumber numberWithLongLong:response.expectedContentLength] doubleValue];
		
		// we check if the "papers" directory exists, if not we create it.
		NSError *error = nil;
		NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		//NSString *documentsPath = [NIFilesystemPaths getCacheDirectoryPath];
		
		if (![[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/papers", documentsPath] error:&error]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/papers", documentsPath] withIntermediateDirectories:YES attributes:nil error:&error];
		}
		
		// creating the directory for the file : only if has not not been created before (preivous download of the same edition)
		NSString *fileName = [response.suggestedFilename substringToIndex:(response.suggestedFilename.length - 4)];	// 4 = ".zip"
		if (![[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/papers/%@/%@", documentsPath, [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY], fileName] error:&error]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/papers/%@/%@", documentsPath, [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY], fileName] withIntermediateDirectories:YES attributes:nil error:&error];
		}
		
		fileDirectory = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"papers/%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY], fileName]];
		fileFullPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"papers/%@/%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY], fileName, response.suggestedFilename]];
		
		// if the file does not exist, we create it.
		if (![[NSFileManager defaultManager] fileExistsAtPath:fileFullPath])
        {
			[[NSFileManager defaultManager] createFileAtPath:fileFullPath contents:nil attributes:nil];
			
			NSMutableDictionary *filesDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK]];
			[filesDict setObject:[NSNumber numberWithInt:0] forKey:myURL];
			[[NSUserDefaults standardUserDefaults] setObject:filesDict forKey:kfileClosedOK];
			
			//[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kfileClosedOK];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		// else if teh file is already here, but the shouldDownload is not set to YES (because of crash during download), we need to remove the file 
		// to start a fresh download to avoid file corrpution
		else if ([[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
			
			NSDictionary *unzipDic = [[NSUserDefaults standardUserDefaults] objectForKey:kUnzipStatusForFile];
			NSDictionary *filesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK];
			int isFileClosedOk = 0;
			
			if (filesDict) {
				isFileClosedOk = [[filesDict objectForKey:myURL] intValue];
			}
			
			BOOL unzipFailed = NO;
			if (unzipDic) {
				int i = [[unzipDic objectForKey:fileFullPath] intValue];
				NSString *theExistingFile = [[unzipDic allKeys] objectAtIndex:0];	// the file for which we last had a unzip status set
				
				if ([theExistingFile isEqualToString:fileFullPath] && i != 1) {
					unzipFailed = YES;
				}
			}
			if (unzipFailed || isFileClosedOk == 0)
            {
            }
		}
		
		// we get a FileHandler for the file at the specified path
		theFile = [NSFileHandle fileHandleForUpdatingAtPath:fileFullPath];
		
		if (theFile) {
			//[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kfileClosedOK];
			NSMutableDictionary *filesDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK]];
			[filesDict setObject:[NSNumber numberWithInt:0] forKey:myURL];
			[[NSUserDefaults standardUserDefaults] setObject:filesDict forKey:kfileClosedOK];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
            [theFile seekToEndOfFile];
		}
	}
	else {
		// no  content in the response.. No file at the specified location ?

	}
}

/* Return downloaded edition directory with PAPER_REGION_KEY = ireland as default
 */
+ (NSString *) getPapersPath
{
    return [NSString stringWithFormat:@"papers/%@/", [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY]];
}

#pragma mark WEB VIEW METHOD DELEGATES
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (theFile) {
        
		totalDataReceived += [[NSNumber numberWithInt:data.length] doubleValue];
		dataReceivedForThisConnection += [[NSNumber numberWithInt:data.length] doubleValue];
		
		[theFile seekToEndOfFile];
		[theFile writeData:data];
		
		double progress = totalDataReceived/fileSizeExpected;
        
        if ([delegate respondsToSelector:@selector(downloadUpdatedProgress:progress:)]) {
            [delegate downloadUpdatedProgress:myURL progress:progress];
        }
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[theFile closeFile];
	isDownloading = NO;

	NSMutableDictionary *filesDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK]];
	[filesDict setObject:[NSNumber numberWithInt:1] forKey:myURL];
	[[NSUserDefaults standardUserDefaults] setObject:filesDict forKey:kfileClosedOK];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	

	// notify the delegate of download succes
	if (self.delegate != NULL && theFile && [self.delegate respondsToSelector:@selector(downloadStoppedForURL:toPath:file:success:)]) {
        
		[delegate downloadStoppedForURL:self.myURL toPath:fileDirectory file:fileFullPath success:YES];
	}
    else if(self.isRedirectedToUpgradeSubs == FALSE){
        [delegate downloadStoppedForURL:self.myURL toPath:@"" file:@"" success:NO];
    }
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    errorMessage = @"There was an error during the download, please try again.";
    self.startDate = nil;
        
    if (error.code == kNetworkConnectionLostErrorCode)
    {
        //[delegate downloadFailed:edition];
    }
    else
    {
        isPauseDownloadedManually = NO;
    }
    
	// pausing the download so we can resume later
	[self pauseDownload];
	[delegate downloadFailed:edition];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    
    if (self.isRedirectedToUpgradeSubs == YES)
    {
        self.isRedirectedToUpgradeSubs = NO;
    }
     
    return request;
}


@end
