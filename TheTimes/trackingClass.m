//
//  trackingClass.m
//  TheSun
//
//  Created by Alan Churley on 20/03/2013.
//
//

#import "trackingClass.h"
#import "Networking/NINetworkingConnection.h"
#import "NI_reachabilityService.h"
#import <sys/utsname.h>

@implementation trackingClass
@synthesize googleTracker, omnatureTracker;
static trackingClass *instance =nil;



-(BOOL)initGoogleTracking:(NSString*)trackingID{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
    //@"UA-39332722-1"
    googleTracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
    return YES;
}

-(void)initOmnature{
 
    omnatureTracker = [[AppMeasurement alloc] init];
    
    /* Specify the Report Suite ID(s) to track here */
    omnatureTracker.account = @"newsintttipadliteprod";
    
    /* You may add or alter any code config here */
    omnatureTracker.pageName = @"timeslite_app";
    omnatureTracker.pageURL = @"";
    
    omnatureTracker.currencyCode = @"GBP";
    
    /* Turn on and configure debugging here */
    omnatureTracker.debugTracking = NO;
    omnatureTracker.ssl = NO;
    
    /* WARNING: Changing any of the below variables will cause drastic changes
     to how your visitor data is collected.  Changes should only be made
     when instructed to do so by your account manager.*/
    omnatureTracker.trackingServer = @"newsinternational.122.2o7.net";
    
    omnatureTracker.trackOffline = YES;
    omnatureTracker.offlineLimit = 500;
    omnatureTracker.pageName = @"timeslite_app";
    NSString *version = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    omnatureTracker.prop47 = [NSString stringWithFormat:@"timeslite %@",version];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceID = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    omnatureTracker.prop58 = deviceID;
    

}
-(AppMeasurement *)returnOmnature{
    return omnatureTracker;
}
+(trackingClass *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [trackingClass new];
        }
    }
    return instance;
}
-(id<GAITracker>)returnInstance{
    return googleTracker;
}
-(void)firePageLoad{
    if([NI_reachabilityService isNetworkAvailable]){
        omnatureTracker.prop35 = @"online" ;
    }else{
        omnatureTracker.prop35 = @"offline";
    }
    omnatureTracker.events=nil;
    [omnatureTracker track];
}


@end
