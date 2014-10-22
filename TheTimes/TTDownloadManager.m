//
//  TTDownloadManager.m
//  TheTimes
//
//  Created by KrisMraz on 10/10/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTDownloadManager.h"
#import "Edition.h"

#define kBytes_already_downloaded   @"downloadedBytes_"
#define kShouldResumeDownload       @"shouldResumeDownload_"
#define kfileClosedOK               @"fileHasBeenClosed_"
#define kUnzipStatusForFile         @"unzipStatusForFile_"
#define kSizeByFileDict             @"sizeByFile_"

@implementation TTDownloadManager

+ (id) sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [self init];
    });
    
    return _sharedInstance;
}


- (void) startDownload : (Edition*) edition isAutomatic:(BOOL) isAuto
{
    NSDictionary *bytesForFiles = [[NSUserDefaults standardUserDefaults] objectForKey:kSizeByFileDict];
	NSDictionary *filesDict = [[NSUserDefaults standardUserDefaults] objectForKey:kfileClosedOK];
    
    NSString *theURL = edition.paperUrl;
    
    double size = 0;
	size = [[bytesForFiles objectForKey:theURL] doubleValue];
	int fileClosed = 0;
	fileClosed = [[filesDict objectForKey:theURL] intValue];

}

@end
