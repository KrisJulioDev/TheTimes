//
//  SubscriptionHandler.m
//  TheSun
//
//  Created by Alan Churley on 05/03/2013.
//
//

#import "SubscriptionHandler.h"
#import "configOptions.h"
#import "trackingClass.h"
#import "Networking/NINetworkingConnection.h"
#import "NI_reachabilityService.h"
#import "TheTimesAppDelegate.h"

@interface SubscriptionHandler ()

@end

@implementation SubscriptionHandler
+ (BOOL)checkLoginValid{
    if([NI_reachabilityService isNetworkAvailable]){
        return [self checkLoginValid:[self returnUserName] password:[self returnPassword]];
    }
    else{
      return YES;  
    }
    
}

/* Check login if valid.
 * params userName , password
 * Debug BYPASS_PAYWALL if define, all entries will return 1
 * Request POST with username and password, if success loginvalid = 1 else loginvalid = 0
 */
+ (BOOL)checkLoginValid:(NSString*)userName password:(NSString*)password{
    if(BYPASS_PAYWALL){
        return 1;
    }
    BOOL loginValid = 0;
    
    NSMutableDictionary *dataFields = [NSMutableDictionary dictionary];
    
    
    [dataFields setObject:@"Website" forKey:@"TimesApp"];
    [dataFields setObject:@"Times_iPad_lite" forKey:@"hash_udid"];
    [dataFields setObject:@"IPAD" forKey:@"device_name"];
    //[dataFields setObject:@"" forKey:@"content_name"];
    
    if(![userName isEqual: @""] && ![password isEqual: @""]
       && password != nil && userName != nil)
    {
        [dataFields setObject:userName forKey:@"username"];
        [dataFields setObject:password forKey:@"password"];
        [dataFields setObject:@"1" forKey:@"onlyiam"];
        
    }else{
        NSLog(@"No username or password sent");
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dataFields options:0 error:nil];
    
    TheTimesAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *serviceURL = delegate.config.authenticationURL;
 
    NSString* dataLength = [NSString stringWithFormat:@"%d", [data length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceURL]];
    
	[request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:data];
    
	[request setTimeoutInterval:5.0];
    
    NSLog(@"REQUEST URL %@", request);
    
    NSURLResponse *response;
    NSError *error;
    //NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   
    if(responseData != nil){
        
        NSError* error = nil;
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
   
        NSString* success = [dict valueForKey:@"success"];
        NSString* type = [dict valueForKey:@"type"];
        NSString* returnCode = [dict valueForKey:@"return_code"];
        NSString* user_id = [dict valueForKey:@"user_id"];
        
        if([success isEqualToString:@"YES"] && [type isEqualToString:@"IAM_SUBSCRIPTION"] && [returnCode isEqualToString:@"VALID_SUBSCRIPTION"]){
            [[trackingClass getInstance] returnOmnature].prop25 = @"timeslite_app/ni";
            [[trackingClass getInstance] returnOmnature].events = @"event8";
            [[trackingClass getInstance] returnOmnature].prop11 = user_id;
            [[[trackingClass getInstance] returnOmnature] track];
            loginValid =1;
          
            if([[dict valueForKey:@"acs_token_id"] length]>0){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[dict valueForKey:@"acs_token_id"] forKey:@"token"];
                [defaults synchronize];
            }
        }
    }
    if(loginValid==0){
        //NSLog(@"Invalid user account");
    }
    return loginValid;
};

/* Store User Details upon succeful login
 * Params Username and Password
 * if both are not nil, it'll be saved in NSUserDefaults
 */
+ (void)storeUserDetails:(NSString*)userName password:(NSString*)password{
  //   NSLog(@"Storing details length:, %d, %d",[userName length],[password length]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(userName == nil){
        userName = @"";
    }
    if(password==nil){
        password=@"";
    }
    [defaults setObject:userName forKey:@"userName"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];
};

/* Check if there's previously saved userName for login purposes
 */
+ (NSString*)returnUserName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    return userName;
};

/* Check if there's previously saved password for login purposes
 */
+ (NSString*)returnPassword{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];
    return password;
};


@end
