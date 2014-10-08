//
//  IGCacheImages.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGCacheImages.h"
#import <UIKit/UIKit.h>
#import "IGFilesystem.h"
#import "IGImagesTools.h"
#import "IGText.h"

// [[self delegate] loadingComplete:image];

@implementation IGCacheImages
 
@synthesize delegate;

/**
 Returns unique path for the image based on the url of the image
 
 @param imageUrlString NSString Url of the image
 */
+ (NSString *)getCachedImagePath:(NSString *)imageUrlString withRoundCorners:(int)corners andWidth:(int)width andHeight:(int)height {
	NSString *filename = [NSString stringWithFormat:@"%@.%d.%d.%d.png", [IGText getSafeText:imageUrlString], corners, width, height];
	return [[IGFilesystemPaths getCacheDirectoryPath] stringByAppendingPathComponent: filename];
}

/**
 Downloads the image if it's not already cached
 
 @param imageUrlString NSString Url of the image
 @param corners int Rounded corners radius
 @param width int New width
 @param height int New height
 */
+ (void)cacheResizedImage:(NSString *)imageUrlString withRoundCorners:(int)corners andWidth:(int)width andHeight:(int)height {
    NSURL *imageURL = [NSURL URLWithString: imageUrlString];
	NSString *path = [IGCacheImages getCachedImagePath:imageUrlString withRoundCorners:corners andWidth:width andHeight:height];
	UIImage *image;
    if(![IGFilesystemIO isFile:path]) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		image = [[[UIImage alloc] initWithData:data] autorelease];
		[data release];
		if (width > 0 && height > 0) image = [IGImagesTools resizeImage:image toWidth:width andHeight:height];
        if (corners > 0) image = [IGImagesTools roundCorners:image withRadius:corners];
        [UIImagePNGRepresentation(image) writeToFile:path atomically: YES];
		if (![IGFilesystemIO isFile:path]) NSLog(@"Unable to save image: %@", path);
		//[image release];
    }
}

/**
 Downloads the image if it's not already cached
 
 @param imageUrlString NSString Url of the image
 */
+ (void)cacheRoundedImage:(NSString *)imageUrlString withRoundCorners:(int)corners {
	[self cacheResizedImage:imageUrlString withRoundCorners:corners andWidth:0 andHeight:0];
}

/**
 Downloads the image if it's not already cached
 
 @param imageUrlString NSString Url of the image
 @param corners int Rounded corners radius
 */
+ (void)cacheImage:(NSString *)imageUrlString {
	[self cacheResizedImage:imageUrlString withRoundCorners:0 andWidth:0 andHeight:0];
}

/**
 Returns NSString for a specific key in initiated file
 
 @param imageUrlString NSString Url of the image
 @param corners int Rounded corners radius
 @param width int New width
 @param height int New height
 
 @return NSString Object
 */
+ (UIImage *)getResizedCachedImage:(NSString *)imageUrlString withRoundCorners:(int)corners andWidth:(int)width andHeight:(int)height {
	NSString *path = [IGCacheImages getCachedImagePath:imageUrlString withRoundCorners:corners andWidth:width andHeight:height];
	UIImage *image;
    if([IGFilesystemIO isFile:path]) {
        image = [UIImage imageWithContentsOfFile:path]; // this is the cached image
    }
    else {
        [self cacheResizedImage:imageUrlString withRoundCorners:corners andWidth:width andHeight:height];
        image = [UIImage imageWithContentsOfFile:path];
    }
    return image;
}

/**
 Returns NSString for a specific key in initiated file
 
 @param imageUrlString NSString Url of the image
 @param corners int Rounded corners radius
 
 @return NSString Object
 */
+ (UIImage *)getRoundedCachedImage:(NSString *)imageUrlString withRoundCorners:(int)corners {
	return [self getResizedCachedImage:imageUrlString withRoundCorners:corners andWidth:0 andHeight:0];
}

/**
 Returns NSString for a specific key in initiated file
 
 @param imageUrlString NSString Url of the image
 
 @return NSString Object
 */
+ (UIImage *)getCachedImage:(NSString *)imageUrlString {
	return [self getResizedCachedImage:imageUrlString withRoundCorners:0 andWidth:0 andHeight:0];
}

- (void)dealloc {
	[delegate release];
	[super dealloc];
}


@end
