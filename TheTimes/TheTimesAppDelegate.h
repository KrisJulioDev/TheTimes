//
//  TheTimesAppDelegate.h
//  TheTimes
//
//  Created by KrisMraz on 8/20/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BookShelfViewController.h"
//#import "PDFVGlobal.h"
#import "Config.h"
#import "User.h"
#import <Filesystem/NIFilesystemPaths.h>

@interface TheTimesAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (strong, nonatomic) Config *config;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) BookShelfViewController *bookShelfVC;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;

- (void) loginUser:(User *)newUser;
- (NSManagedObjectContext *) managedObjectContext;

@end
