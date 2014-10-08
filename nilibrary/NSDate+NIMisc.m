//
//  NSDate+Misc.m
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 16.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NSDate+NIMisc.h"
//#import "IGLocalization.h"


@implementation NSDate (NIMisc)

+ (NSString *)formatToCountdown:(NSString *)interval {
//	NSTimeInterval theTimeInterval = [interval intValue];
//	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
//	NSDate *date1 = [[NSDate alloc] init];
//	NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1]; 
//	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
//	NSDateComponents *bi = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
//	[date1 release];
//	[date2 release];
	NSString *ret = @"";
//	if ([bi month]) ret = [ret stringByAppendingFormat:@"%d %@ ", [bi month], [IGLocalization get:@"lTMonth"]];
//	if ([bi day]) ret = [ret stringByAppendingFormat:@"%d %@ ", [bi day], [IGLocalization get:@"lTDay"]];
//	if ([bi hour]) ret = [ret stringByAppendingFormat:@"%d %@ ", [bi hour], [IGLocalization get:@"lTHour"]];
//	if ([bi minute]) ret = [ret stringByAppendingFormat:@"%d %@ ", [bi minute], [IGLocalization get:@"lTMin"]];
//	if ([ret isEqualToString:@""]) ret = [NSString stringWithFormat:@"0 %@", [IGLocalization get:@"lTMin"]];
	return ret;
}

+ (NSDate *)dateWithoutTime {
    return [[NSDate date] dateAsDateWithoutTime];
}

-(NSDate *)dateByAddingDays:(NSInteger)numDays {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:numDays];
    
    NSDate *date = [gregorian dateByAddingComponents:comps toDate:self options:0];
    [comps release];
    [gregorian release];
    return date;
}

- (NSDate *)dateAsDateWithoutTime {
    NSString *formattedString = [self formattedDateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *ret = [formatter dateFromString:formattedString];
    [formatter release];
    return ret;
}

- (int)differenceInDaysTo:(NSDate *)toDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self toDate:toDate options:0];
    NSInteger days = [components day];
    [gregorian release];
    return days;
}

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *ret = [formatter stringFromDate:self];
    [formatter release];
    return ret;
}

- (NSString *)formattedDateString {
    return [self formattedStringUsingFormat:@"MMM dd, yyyy"];
}




@end
