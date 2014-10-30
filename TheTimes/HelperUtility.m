//
//  HelperUtility.m
//  TheTimes
//
//  Created by KrisMraz on 10/27/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "HelperUtility.h"
#import "Reachability.h"
#import "trackingClass.h"

@implementation HelperUtility
{
    
}

/* SINGLETON INSTANCE
 */
+ (id) sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
       
        _sharedInstance = [[self alloc] init];
        
    });
    
    return _sharedInstance;
}

/* CHECK DEVICE INTERNET CONNECTION
 */
-(int) connectionType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        return None;
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        return Wifi;
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        return Wwan;
    }
}

/* RETURN TRACKING CLASS UTILITY
 * USE FOR TRACKING USER ACTIONS
 */
+(id<GAITracker>) trackingClass
{
    return [[trackingClass getInstance] returnInstance];
}
@end
