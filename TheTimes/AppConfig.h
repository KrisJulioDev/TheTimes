//
//  AppConfig.h
//  The Sun
//
//  Created by Daniel on 07/05/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject
{
    
}

@property (nonatomic, retain) NSDictionary *values;

+ (AppConfig *) sharedInstance;

- (NSString *) getBaseUrl;
- (BOOL) isTestAccount;

- (BOOL) isPaymentAllowAllFree;
- (BOOL) isPaymentAlwaysSubscribed;

- (BOOL) isAllowUrlChanger;
- (BOOL) isTestingTracking;
- (BOOL) isTrackingUseOmnitureV4;
- (BOOL) isTrackingUseTealium;
- (BOOL) isTrackingUseLocalytics;

- (NSString *) getLocalyticsAppKey;
- (NSString *) getTealiumAccountName;
- (NSString *) getTealiumProfileName;
- (NSString *) getTealiumTarget;

- (NSString *) getCrashlyticsKey;

- (NSString *) getOoyalaPlayerDomain;
- (NSString *) getOoyalaPCode;

- (NSString *) subscriptionProductId;
- (NSString *) getVerifyUrl;

- (NSString *) getAirshipDevKey;
- (NSString *) getAirshipDevSecret;
- (NSString *) getAirshipProductionKey;
- (NSString *) getAirshipProductionSecret;
- (BOOL) isAirshipInProduction;

@end
