//
//  ImageCache.h
//  The Sun
//
//  Created by Daniel on 05/03/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSMutableDictionary *files;

+ (ImageCache *) sharedInstance;

- (void) addFileToCache:(NSData *)imageData url:(NSString *)url;
- (UIImage *) getImage:(NSString *)url;

@end
