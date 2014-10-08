//
//  configOptions.h
//  TheSun
//
//  Created by Alan Churley on 05/03/2013.
//
//

#import <Foundation/Foundation.h>
 

@interface configOptions : NSObject
#define BYPASS_PAYWALL          0                //If true paywall will always return valid account
#define STORE_USER_DETAILS      1       //if false userdetails will not be persisted through sessions
#define FORCELOGIN              0       //Force the user to login to the app
#define FORCECHECK              1       //Force the download to recheck the server often!
#define kShowPageLabels         1
#define STORE_FIRST_LOAD        @"YES"
#define kUserAgent              @"nitimes/1.3.4 CFNetwork/548.0.4 Darwin/11.0.0"
#define AUTHENTICAION_URL       @"https://inapp.nidigitalsolutions.co.uk/tt/admin/device_subscription_verify_2.0.php"
#define showMarioLink           NO
#define MarioAppURL             @"itms-apps://itunes.apple.com/gb/app/the-times-the-sunday-times/id364276908?mt=8"

#ifdef STAGING_BUILD
    #define kWebServicePath         @"http://feeds.thetimes.co.uk/timeslite/global-staging.json"
#else
    #define kWebServicePath			@"http://feeds.thetimes.co.uk/timeslite/global.json"
#endif


//#define kWebServicePath           @"http://192.168.0.6:8080/global.json"
//#define kWebServicePath           @"http://172.172.6.175:8080/global.json"

#define availablePapersKey      @"availablePapers"

@end
