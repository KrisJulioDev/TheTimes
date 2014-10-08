//
//  NSString+URL.m
//  urlTools
//
//  Created by Ondrej Rafaj on 19.10.09.
//  Copyright 2009 Home. All rights reserved.
//

#import "NSString+URL.h"
#import <UIKit/UIKit.h>

 
@implementation NSString (urlTools)

+ (NSString *)stringWithContentsOfURLInUtf8:(NSString *)targetUrl {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURL *location = [NSURL URLWithString:[targetUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
	NSString *content = [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:&error];
	if (error) NSLog(@"Something went wrong Error: %d; Message: %@", [error code], [error localizedDescription]);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	return content;
}

- (NSString *)contentOfStringURLInUtf8 {
	return [NSString stringWithContentsOfURLInUtf8:self];
}

@end
