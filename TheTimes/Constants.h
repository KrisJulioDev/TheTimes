//
//  Constants.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TO_LOGIN_SEGUE @"LoginScreen"

#define REGION_ENGLAND  @"england"
#define REGION_IRELAND  @"ireland"
#define REGION_SCOTLAND @"scotland" 

#define OVERRIDDEN_URL_KEY      @"overriddenUrl"
#define OVERRIDDEN_REGION_KEY   @"overriddenRegion"
#define PAPER_REGION_KEY        @"region"
#define CONFIG_KEY              @"config"
#define USER_KEY                @"user"

#define FEED_URL                @"http://feeds.thetimes.co.uk/timeslite/global.json"

#define SCREEN_WIDTH (IOS_VERSION_LOWER_THAN_8 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height) : [[UIScreen mainScreen] bounds].size.width)

#define SCREEN_HEIGHT (IOS_VERSION_LOWER_THAN_8 ? (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width) : [[UIScreen mainScreen] bounds].size.height)

#define IOS_VERSION_LOWER_THAN_8 (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

@protocol Constants <NSObject>

@end
