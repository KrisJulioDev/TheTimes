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

@protocol Constants <NSObject>

@end
