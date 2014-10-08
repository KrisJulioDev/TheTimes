///
///  IGCacheVariables.h
///
///  IGFrameworkProject
///
///  Created by Ondrej Rafaj on 25.3.10.
///
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>
#import "IGCacheImages.h"

@class IGCache;

@protocol IGCacheDelegate <NSObject>

@optional

- (void)loadingComplete:(id)object;

- (void)loadingError:(NSString *)message;

@end

@interface IGCache : NSObject {
	
	id <IGCacheDelegate> delegate;
	
}

@property (nonatomic, assign) id <IGCacheDelegate> delegate;


+ (NSString *)getCachedFilePath:(NSString *)fileUrlString;

+ (void)deleteCacheFiles;

+ (void)deleteCacheFilesOlderThan:(NSDate *)date;

@end
