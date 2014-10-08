///
///  IGValidationText.h
///
///  IGFrameworkProject
///
///  Created by Ondrej Rafaj on 1.4.10.
///
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>


@interface IGValidationText : NSObject {

}

+ (BOOL)isEmail:(NSString *)candidate;

+ (BOOL)isAlphanumeric:(NSString *)candidate;

+ (BOOL)isStringInCharacterSet:(NSString *)string characterSet:(NSMutableCharacterSet *)characterSet;


@end
