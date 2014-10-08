//
//  NSDate+Misc.h
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 16.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NIMisc)

+ (NSString *)formatToCountdown:(NSString *)interval;

+ (NSDate *)dateWithoutTime;

- (NSDate *)dateByAddingDays:(NSInteger)numDays;

- (NSDate *)dateAsDateWithoutTime;

- (int)differenceInDaysTo:(NSDate *)toDate;

- (NSString *)formattedDateString;

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat;


@end