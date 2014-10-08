//
//  TrackingUtil.h
//  The Sun
//
//  Created by Daniel on 06/03/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackingUtil : NSObject

+ (void) trackPageName:(NSString *)name;
+ (void) trackPageName:(NSString *)name extraData:(NSDictionary *)extraData;
+ (void) trackPageName:(NSString *)name fromView:(UIView *)view;
+ (void) trackPageName:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData;
+ (void) trackPageName:(NSString *)name includeInTesting:(BOOL)includeInTesting;
+ (void) trackPageName:(NSString *)name extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting;
+ (void) trackPageName:(NSString *)name fromView:(UIView *)view includeInTesting:(BOOL)includeInTesting;

+ (void) trackEvent:(NSString *)name;
+ (void) trackEvent:(NSString *)name extraData:(NSDictionary *)extraData;
+ (void) trackEvent:(NSString *)name fromView:(UIView *)view;
+ (void) trackEvent:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData;
+ (void) trackEvent:(NSString *)name includeInTesting:(BOOL)includeInTesting;
+ (void) trackEvent:(NSString *)name extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting;
+ (void) trackEvent:(NSString *)name fromView:(UIView *)view includeInTesting:(BOOL)includeInTesting;

+ (void) trackPageView:(NSString *)name fromView:(UIView *)view pageName:(NSString *)pageName pageType:(NSString *)pageType pageSection:(NSString *)pageSection pageNumber:(NSString *)pageNumber articleParent:(NSString *)articleParent customerId:(NSString *)customerId customerType:(NSString *)customerType;
+ (void) trackEvent:(NSString *)name fromView:(UIView *)view eventName:(NSString *)eventName eventAction:(NSString *)eventAction eventMethod:(NSString *)eventMethod eventRegistrationAction:(NSString *)eventRegistrationAction customerId:(NSString *)customerId customerType:(NSString *)customerType;

+ (void) trackPageName:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting isEvent:(BOOL)isEvent;

+ (void) applicationDidFinishLaunching;
+ (void) applicationWillTerminate;
+ (void) applicationWillResignActive;
+ (void) applicationDidBecomeActive;
+ (void) applicationWillEnterForeground;
+ (void) applicationDidEnterBackground;

@end
