//
// AsyncImageView.h
// Postcard
//
// Created by markj on 2/18/09.
// Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
// http://www.markj.net
//

@interface AsyncImageView : UIImageView 
{
	BOOL scale;
    int scaleWidth;
    int scaleHeight;
    
	BOOL loading;
}

@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic) BOOL dontClearImageOnLoad;
@property (nonatomic) BOOL thumbnail;
@property (nonatomic, retain) NSURL* myUrl;
@property (nonatomic, retain) NSURL* showingUrl;

@property (nonatomic, retain) NSString *userProfileId;

- (void) loadImageFromURL:(NSURL*)url;
- (void) loadScaledImageFromURL:(NSURL*)url width:(int)scaleWidth height:(int)scaleHeight;
+ (void) clearCache;
+ (void) storeCache;
+ (void) loadCache;

@end