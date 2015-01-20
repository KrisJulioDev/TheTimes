//
// AsyncImageView.m
// Postcard
//
// Created by markj on 2/18/09.
// Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
// http://www.markj.net
//

#import "AsyncImageView.h"
#import "ImageCache.h"

// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn’t block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time.

@implementation AsyncImageView

static NSMutableDictionary *cache;

+ (void) storeCache
{
    //[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:cache] forKey:@"imageCache"];
}

+ (void) loadCache
{
    /*
    NSData *imageCacheData = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageCache"];
    if (imageCacheData != nil)
    {
        cache = [NSKeyedUnarchiver unarchiveObjectWithData:imageCacheData];
    }
     */
}

// Clear the cache when we get memory warnings.
+ (void)clearCache
{
    [cache removeAllObjects];
}

- (void) loadScaledImageFromURL:(NSURL*)url width:(int)width height:(int)height
{
    self.myUrl = url;
	scale = YES;
	scaleWidth = width;
	scaleHeight = height;
	
	[self performSelectorInBackground:@selector(loadImageInBackground:) withObject:url];
}

- (void)loadImageFromURL:(NSURL*)url
{
    self.myUrl = url;
	scale = NO;
    
    NSString *cacheKey = [url absoluteString];
    UIImage *image = [[ImageCache sharedInstance] getImage:cacheKey];
    if (image != nil)
    {
        if (_showingUrl == nil || ![_showingUrl isEqual:url])
        {
            self.showingUrl = url;
            [self performSelectorOnMainThread:@selector(setNewImage:) withObject:image waitUntilDone:YES];
        }
    }
    else
    {
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:url];
    }
}

- (void) loadImageInBackground: (NSURL *)url
{
    @autoreleasepool
    {
        
    if (!_dontClearImageOnLoad)
    {
        if (_showingUrl == nil || ![_showingUrl isEqual:url])
        {
            //self.showingUrl = url;
            [self performSelectorOnMainThread:@selector(setNewImage:) withObject:nil waitUntilDone:YES];
        }
    }
    
	if (cache == nil)
	{
		cache = [[NSMutableDictionary alloc] init];	
	}
	
    NSString *cacheKey = [url absoluteString];
    if (scale)
    {
        cacheKey = [cacheKey stringByAppendingString:[NSString stringWithFormat:@"_scaled%i,%i", scaleWidth, scaleHeight]];
    }
    
        UIImage *image = [[ImageCache sharedInstance] getImage:cacheKey];

	if (image == nil)
	{
		NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
		UIImage* img = [[UIImage alloc] initWithData:imageData];
        
        if (imageData != nil && cacheKey != nil)
        {
            [[ImageCache sharedInstance] addFileToCache:imageData url:cacheKey];
        }
		
        if (img != nil)
        {
        }
        
        if ([[url absoluteString] isEqualToString:[_myUrl absoluteString]])
        {
            if (_showingUrl == nil || ![_showingUrl isEqual:url])
            {
                self.showingUrl = url;
                [self performSelectorOnMainThread:@selector(setNewImage:) withObject:img waitUntilDone:YES];
            }
        }
	}
	else
	{
        if (_showingUrl == nil || ![_showingUrl isEqual:url])
        {
            self.showingUrl = url;
            [self performSelectorOnMainThread:@selector(setNewImage:) withObject:image waitUntilDone:YES];
        }
	}
    }
}

- (void) setNewImage:(UIImage *)img
{
	self.image = img;
}

@end