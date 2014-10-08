//
//  IGCacheVariables.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 25.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGCache.h"
#import "IGText.h"
#import "IGFilesystemIO.h"
#import "IGFilesystemPaths.h"


@implementation IGCache

@synthesize delegate;

/**
 Returns unique path for the file based on the url
 
 @param fileUrlString NSString Url of the file
 */
+ (NSString *)getCachedFilePath:(NSString *)fileUrlString {
	NSString *filename = [NSString stringWithFormat:@"%@.cache", [IGText getSafeText:fileUrlString]];
	return [[IGFilesystemPaths getCacheDirectoryPath] stringByAppendingPathComponent: filename];
}

/**
 Deletes all cached file for the app
 */
+ (void)deleteCacheFiles {
	[IGFilesystemIO deleteFile:[IGFilesystemPaths getCacheDirectoryPath]];
}

/**
 Deletes all cached file for the app that are older that specified date
 
 @param date NSDate Limit date
 */
+ (void)deleteCacheFilesOlderThan:(NSDate *)date {
	[IGFilesystemIO deleteFilesOlderThan:date inDirectory:[IGFilesystemPaths getCacheDirectoryPath]];
}

- (void)dealloc {
	[delegate release];
	[super dealloc];
}



@end
