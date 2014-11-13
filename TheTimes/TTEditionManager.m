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
#import "SPDownloader.h"


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

/* loadData
 * load Data from nsuserdefaults using LATEST_EDITIONS_KEY key and DOWNLOADED_EDITIONS_KEY key
 */
- (void) loadData
{
    self.LatestEditions     = [self loadFromDefaults:LATEST_EDITIONS_KEY defaultValue:[[NSMutableArray alloc] init]];
    self.downloadedEditions = [self loadFromDefaults:DOWNLOADED_EDITIONS_KEY defaultValue:[[NSMutableArray alloc] init]];
}

/* loadFromDefaults:key:defaultValue
 * get saved object from NSUSerDefaults using key parameter
 * if there's no value. return defaultValue parameter
 */
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

/* deleteEdition:edition
 * delete edition. remove file from directory path and from downloadedEdition array. 
 * snapshot to save it to nsuserdefaults
 */
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

/* updateEditions
 * perform updatedEditionsInMainThread at the background
 */
- (void) updateEditions
{
    [self performSelectorInBackground:@selector(updateEditionsInMainThread) withObject:nil];
}

/* getDownloadedEdition:edition
 * param - edition
 * return edition if exists in downloadEditions; otherwise return nil
 */
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


/* downloadedEdition:edition
 * param - edition 
 * check if edition 's path exists
 */
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

/* Fetch new editions and download
 */
- (void) updateEditionsInMainThread
{
    @autoreleasepool
    {
        NSMutableArray *newEditions = [[TTWebService sharedInstance] getEditions];
        [self performSelectorOnMainThread:@selector(completeUpdateEditions:) withObject:newEditions waitUntilDone:YES];
    }
}

/* CompleteUpdateEditions
 * params newEditions ; if nil download latest editions and refreshEditionsViews
 */
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

/* Save latest editions and downloaded editions to the device.
 */
- (void) snapshot
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_LatestEditions] forKey:LATEST_EDITIONS_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_downloadedEditions] forKey:DOWNLOADED_EDITIONS_KEY];
}
@end