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

- (id) init
{
    if (self = [super init])
    {
        [self loadData];
    }
    
    return self;
}

- (void) loadData
{
    self.LatestEditions = [self loadFromDefaults:LATEST_EDITIONS_KEY defaultValue:[[NSMutableArray alloc] init]];
    self.downloadedEditions = [self loadFromDefaults:DOWNLOADED_EDITIONS_KEY defaultValue:[[NSMutableArray alloc] init]];
}

- (id) loadFromDefaults:(NSString *)key defaultValue:(id)defaultValue
{
    id result = nil;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (data != nil)
    {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (result != nil)
    {
        return result;
    }
    else
    {
        return defaultValue;
    }
}

- (BOOL) deleteEdition:(Edition *)edition
{
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[edition getBaseDirectory] error:&error];
    
    if (success)
    {
        [_downloadedEditions removeObject:edition];
        [self snapshot];
    }
    
    return success;
}

- (BOOL) clearEditionDownload:(Edition*) edition
{
    
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
        [appDelegate.bookShelfVC downloadLatest];
        [appDelegate.bookShelfVC refreshEditionViews];
    }
}

- (void) snapshot
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_LatestEditions] forKey:LATEST_EDITIONS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_downloadedEditions] forKey:DOWNLOADED_EDITIONS_KEY];
}
@end