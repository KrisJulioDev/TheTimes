//
//  SubscriptionHandler.h
//  TheSun
//
//  Created by Alan Churley on 05/03/2013.
//
//

#import <UIKit/UIKit.h>

@interface SubscriptionHandler : NSObject{
    
}
+ (BOOL)checkLoginValid;
+ (BOOL)checkLoginValid:(NSString*)userName password:(NSString*)password;
+ (void)storeUserDetails:(NSString*)userName password:(NSString*)password;
+ (NSString*)returnUserName;
+ (NSString*)returnPassword;

@end
