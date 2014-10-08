//
//  IGValidationText.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGValidationText.h"


@implementation IGValidationText

/**
 Validates correct email address
 
 @param candidate NSString Email address
 
 @return BOOL
 */
+ (BOOL)isEmail:(NSString *)candidate {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	return [emailTest evaluateWithObject:candidate];
}

/**
 Validates if given string contains only alphanumeric characters
 
 @param candidate NSString Email address
 
 @return BOOL
 */
+ (BOOL)isAlphanumeric:(NSString *)candidate {
	return [IGValidationText isStringInCharacterSet:candidate characterSet:[NSCharacterSet alphanumericCharacterSet]];
}

/**
 Validates if given string contains only characters from the character set
 
 @param candidate NSString Email address
 @param characterSet NSMutableCharacterSet Caracter set
 
 @return BOOL
 */
+ (BOOL)isStringInCharacterSet:(NSString *)string characterSet:(NSMutableCharacterSet *)characterSet {
	return ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) ? NO : YES;
}





@end
