//
//  NSString+Ereg.m
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 15.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSString+Ereg.h"


@implementation NSString (Ereg)

+ (BOOL)ereg:(NSString *)pattern inString:(NSString *)string {
	return !([[string lowercaseString] rangeOfString:pattern].location == NSNotFound);
}

+ (BOOL)eregi:(NSString *)pattern inString:(NSString *)string {
	return !([string rangeOfString:[pattern lowercaseString]].location == NSNotFound);
}

- (BOOL)ereg:(NSString *)pattern {
	return NO;
	/*
	NSString *string = nil;
	if (string == nil || pattern == nil) return NO;
	NSRange textRange = [string rangeOfString:pattern];
	if(textRange.location != NSNotFound) return NO;
	else return YES;
	*/
}

- (BOOL)eregi:(NSString *)pattern {
	NSString *string = nil;
	if (string == nil || pattern == nil) return NO;
	NSRange textRange = [[string lowercaseString] rangeOfString:[pattern lowercaseString]];
	if(textRange.location != NSNotFound) return NO;
	else return YES;
}



@end
