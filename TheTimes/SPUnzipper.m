//
//  SPUnzipper.m
//  Jigsaw
//
//  Created by SAMI EDDAIKRA on 5/5/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SPUnzipper.h"
#import "Config.h"
#import "ZipArchive.h"

#define kUnzipStatusForFile @"unzipStatusForFile"

@implementation SPUnzipper

+ (SPUnzipper *) mySPUnzipper {
	static SPUnzipper *SPUnzipperSingleton;
	
	if (!SPUnzipperSingleton) {
		SPUnzipperSingleton = [[SPUnzipper alloc] init];
	}
	return SPUnzipperSingleton;
}


-( id) init {
	self = [super init];
	return self;
}

- (BOOL) unzipFile:(NSString*)fileFullPath inDirectory:(NSString*)directoryPath {	
	__block BOOL returnValue = NO;
    dispatch_queue_t _queue = dispatch_queue_create("extracting", NULL);
    dispatch_sync(_queue, ^{
        NSError *error = nil;
        
        NSMutableDictionary *unzipFinishedDic = [[NSMutableDictionary alloc] initWithCapacity:1];
        [unzipFinishedDic setObject:[NSNumber numberWithInt:0] forKey:fileFullPath];
        [[NSUserDefaults standardUserDefaults] setObject:unzipFinishedDic forKey:kUnzipStatusForFile];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        @try {
            ZipArchive* za = [[ZipArchive alloc] init];
            
            if ([za UnzipOpenFile:fileFullPath]) {
                if([za UnzipFileTo:directoryPath overWrite:YES]) {
                    [za UnzipCloseFile];
                    [za release];
                    [unzipFinishedDic setObject:[NSNumber numberWithInt:1] forKey:fileFullPath];
                    [[NSUserDefaults standardUserDefaults] setObject:unzipFinishedDic forKey:kUnzipStatusForFile];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [unzipFinishedDic release];
                    
                    // removing the zip file from the disk
                    // delete the folder from the disk
                    [[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:&error];
                    returnValue =  YES;
                }
                else {
                    [za release];
                    [[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:&error];
                    [unzipFinishedDic release];
                    returnValue =  NO;
                }
            }
            else {
                [za release];
                [[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:&error];
                [unzipFinishedDic release];
                returnValue =  NO;
            }
        }
        @catch (NSException *e) {
            [[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:&error];
            [unzipFinishedDic release];
            returnValue = NO;
        }
        

        //dispatch_release(_queue);
    });
    return returnValue;
    
    
    
  
}

- (void) dealloc {
	[super dealloc];
}
@end
