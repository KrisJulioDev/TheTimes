//
//  TTEditionManager.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTEditionManager.h"
#import "TTWebService.h"
#import "Edition.h"
#import "TheTimesAppDelegate.h"


NSString * const LATEST_EDITIONS_KEY = @"latestEditions";
NSString * const DOWNLOADED_EDITIONS_KEY = @"downloadedEditions";

@implementation TTEditionManager

+(instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^ {
        
          sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) updateEditions
{
    [self performSelectorInBackground:@selector(updateEditionsInBackground) withObject:nil];
}

- (Edition *) getDownloadedEdition:(Edition *)edition
{
    for (Edition *thisEdition in _downloadedEditions)
    {
        if ([edition.paperUrl isEqualToString:thisEdition.paperUrl])
        {
            return thisEdition;
        }
        
    }
    return nil;
}

- (BOOL) downloadedEdition:(Edition *)edition
{
    for (Edition *thisEdition in _downloadedEditions)
    {
        if ([edition.paperUrl isEqualToString:thisEdition.paperUrl])
        {
            NSString *configFile = [thisEdition getConfigFile];
            return [[NSFileManager defaultManager] fileExistsAtPath:configFile];
        }
        
    }
    return NO;
}

- (void) updateEditionsInBackground
{
    @autoreleasepool
    {
        NSMutableArray *newEditions = [[TTWebService sharedInstance] getEditions];
        [self performSelectorOnMainThread:@selector(completeUpdateEditions:) withObject:newEditions waitUntilDone:YES];
    }
}

- (void) completeUpdateEditions:(NSMutableArray *)newEditions
{
    if (newEditions != nil && [newEditions count] > 0)
    {
        self.LatestEditions = newEditions;
        
        TheTimesAppDelegate* appDelegate = (TheTimesAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.bookShelfVC refreshEditionViews];
    }
}

- (void) snapshot
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_LatestEditions] forKey:LATEST_EDITIONS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_downloadedEditions] forKey:DOWNLOADED_EDITIONS_KEY];
}
@end