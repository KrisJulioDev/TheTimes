//
//  SPDownloaer.h
//  Jigsaw
//
//  Created by SAMI EDDAIKRA on 5/4/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "Edition.h"

#define kNetworkConnectionLostErrorCode -1005
#define kDownloaderRedirectRequestNotification @"downloaderRedirectRequestNotification"
#define kDownloaderRedirectRequestKey @"redirectRequestKey"

@protocol SPDownloaderDelegate;


@interface SPDownloader : NSObject<NSURLConnectionDataDelegate>
{
	id <SPDownloaderDelegate> delegate;
	NSString *fileDirectory;
	NSString *fileFullPath;	//directoryPath + filename
	NSFileHandle *theFile;
	NSURLConnection *myConnection;
	NSString *myURL;
    BOOL willResign;
    NSDate *startDate;
	long long totalDataReceived;
	double bytesAlreadyDownloaded;
	double fileSizeExpected;
	BOOL shouldResumeDonload;
	NSString *errorMessage;
	BOOL isDownloading;
	BOOL isShowingManager;
	BOOL isPauseDownloadedManually;
	NSTimer *checkIfDataReceived;
	double dataReceivedForThisConnection;
	BOOL hasSpeedError;
    
    long long totalBytesRead;
}

@property (nonatomic) BOOL willResign;
@property (nonatomic) BOOL isPauseDownloadedManually;
@property (nonatomic) BOOL isShowingManager;
@property (nonatomic,retain) id <SPDownloaderDelegate> delegate;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic, retain) NSString *myURL;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic) BOOL hasSpeedError;
@property (nonatomic) BOOL isRedirectedToUpgradeSubs;
@property (nonatomic, retain) Edition *edition;

+(SPDownloader *) mySPDownloader;

-(id) init;
- (void) startDownload:(Edition *)theEdition isAutomated:(BOOL)isAutomated;
-(void) pauseDownload;
-(void) clearDownloadOnDelete;
-(void) resumeDownload:(double)fromBytes;

@end


@protocol SPDownloaderDelegate <NSObject>

- (void) downloadStoppedForURL:(NSString*)url toPath:(NSString*)path file:(NSString*)fileFullPath success:(BOOL)isSuccess;
- (void) downloadUpdatedProgress:(NSString*)url progress:(float)progress;
- (void) downloadFailed:(Edition *)edition;
- (void) downloadError:(Edition *)edition;

@end