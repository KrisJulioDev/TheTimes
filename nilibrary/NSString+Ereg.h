//
//  NSString+Ereg.h
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 15.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Ereg)

+ (BOOL)ereg:(NSString *)pattern inString:(NSString *)string; 

+ (BOOL)eregi:(NSString *)pattern inString:(NSString *)string; 

- (BOOL)ereg:(NSString *)pattern; 

- (BOOL)eregi:(NSString *)pattern; 



@end
