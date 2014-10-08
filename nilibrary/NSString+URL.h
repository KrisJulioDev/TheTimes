//
//  NSString+URL.h
//  urlTools
//
//  Created by Ondrej Rafaj on 19.10.09.
//  Copyright 2009 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (urlTools)

+ (NSString *)stringWithContentsOfURLInUtf8:(NSString *)targetUrl;

- (NSString *)contentOfStringURLInUtf8;


@end
