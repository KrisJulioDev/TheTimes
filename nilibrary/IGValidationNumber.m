//
//  IGValidationNumber.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGValidationNumber.h"
#import "IGValidationText.h"


@implementation IGValidationNumber

/**
 Validates if given string contains only numeric characters
 
 @param candidate NSString Email address
 
 @return BOOL
 */
- (BOOL)isNumeric:(NSString *)candidate {
	return [IGValidationText isStringInCharacterSet:candidate characterSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
}


@end
