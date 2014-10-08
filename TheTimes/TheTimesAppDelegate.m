//
//  TheTimesAppDelegate.m
//  TheTimes
//
//  Created by KrisMraz on 8/20/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TheTimesAppDelegate.h"
#import "AsyncImageView.h"
#import "PDFVGlobal.h"
#import "Config.h"
#import "Constants.h"
#import "TTWebService.h"
#import "AppConfig.h"
#import "UAirship.h"
#import "UAConfig.h" 
#import "UAPush.h"
#import "User.h"
#import "TTEditionManager.h"
#import "Filesystem/NIFilesystemPaths.h"
#import "Filesystem/NIFilesystem.h"

@interface TheTimesAppDelegate (PrivateCoreDataStack)

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TheTimesAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    APP_Init();
    
    //AirShip Configs
    [self setupUrbanAirship];
    [self loadCachedConfigAndUserData];
    [[TTEditionManager sharedInstance] updateEditions];
    [AsyncImageView loadCache];
    
    return YES;
}

- (void) setupUrbanAirship
{
    UAConfig *uaConfig = [UAConfig defaultConfig];
    uaConfig.developmentAppKey = [[AppConfig sharedInstance] getAirshipDevKey];
    uaConfig.developmentAppSecret = [[AppConfig sharedInstance] getAirshipDevSecret];
    //uaConfig.productionAppKey = [[AppConfig sharedInstance] getAirshipProductionKey];
    //uaConfig.productionAppSecret = [[AppConfig sharedInstance] getAirshipProductionSecret];
    uaConfig.inProduction = [[AppConfig sharedInstance] isAirshipInProduction];
    
    [UAirship takeOff:uaConfig];
    [UAPush setDefaultPushEnabledValue:YES];
}

// Update the config from the web service
- (void) loadConfigInBackground
{
    @autoreleasepool
    {
        Config *newConfig = [[TTWebService sharedInstance] getConfig];
        [self performSelectorOnMainThread:@selector(completeLoadConfig:) withObject:newConfig waitUntilDone:YES];
    }
}

- (void) completeLoadConfig:(Config *)newConfig
{
    if (newConfig != nil)
    {
        self.config = newConfig;
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_config] forKey:CONFIG_KEY];
        
    }
    else
    {
        
    }
}

- (void) loadCachedConfigAndUserData
{
    NSData *configData = [[NSUserDefaults standardUserDefaults] objectForKey:CONFIG_KEY];
    if (configData != nil)
    {
        self.config = [NSKeyedUnarchiver unarchiveObjectWithData:configData];
    }
    
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_KEY];
    if (userData != nil)
    {
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
}

- (void) loginUser:(User *)newUser
{
    self.user = newUser;
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_user] forKey:USER_KEY];
}


- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[UAPush shared] registerDeviceToken:deviceToken];
    
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [self performSelectorInBackground:@selector(loadConfigInBackground) withObject:nil];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
	if (managedObjectContext != nil) {
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	return managedObjectContext;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
	if (persistentStoreCoordinator != nil) {
		return persistentStoreCoordinator;
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"SunPaper.sqlite"]];
	
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	//NSLog(storeUrl.path);
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//abort();
	}
	
	return persistentStoreCoordinator;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
	if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"TheTimes" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	//NSLog(momURL.path);
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	//managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	return managedObjectModel;
}


/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NIFilesystemPaths getDatabaseDirectoryPath];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
