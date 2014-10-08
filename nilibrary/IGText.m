//
//  IGText.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGText.h"
#import <UIKit/UIKit.h>
#import "IGValidationText.h"


@implementation IGText

/**
 Return string without new lines
 
 @param text NSString Input text
 
 @return NSString text
 
 */
 
+ (NSString *)removeNewLines:(NSString *)text {
	NSMutableString *newText = [[[NSMutableString alloc] initWithString:text] autorelease];
	[newText replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [newText length])];
	[newText replaceOccurrencesOfString:@"\r" withString:@" " options:0 range:NSMakeRange(0, [newText length])];
	return (NSString *)newText;
}

/**
 Return string with escaped new lines \\\\n
 
 @param text NSString Input text
 
 @return NSString text
 
 */
+ (NSString *)replaceNewLinesWithEscapes:(NSString *)text {
	NSMutableString *newText = [[[NSMutableString alloc] initWithString:text] autorelease];
	[newText replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, [newText length])];
	[newText replaceOccurrencesOfString:@"\r" withString:@"\\n" options:0 range:NSMakeRange(0, [newText length])];
	return (NSString *)newText;
}

/**
 Returns lowercased text where special characters and spaces are being replaced with dash - 
 
 @param text NSString Input text
 
 @return NSString text
 */
+ (NSString *)getSafeText:(NSString *)text {
	NSString *newText = @"";
	NSString *a;
	for(int i = 0; i < [text length]; i++) {
		a = [text substringWithRange:NSMakeRange(i + 0, 1)];
		if (![IGValidationText isAlphanumeric:a]) a = @"-";
		newText = [NSString stringWithFormat:@"%@%@", newText, a];
	}
	return newText;
}

/**
 Converts text from one encoding to another
 
 @param text NSString Input text
 @param from NSStringEncoding Input encoding
 @param to NSStringEncoding Output encoding
 
 @return NSString Converted text
 */
+ (NSString *)convertText:(NSString *)text fromEncoding:(NSStringEncoding)from toEncoding:(NSStringEncoding)to {
	NSString *ss = [[[NSString alloc] initWithData:[text dataUsingEncoding:from]] autorelease];
	NSData *md = [ss dataUsingEncoding:to];
	return [[[NSString alloc] initWithData:md encoding:to] autorelease];
}


@end
