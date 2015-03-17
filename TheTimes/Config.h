//
//  Config.h
//  The Sun
//
//  Created by Daniel on 14/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "ConfigLive.h"

@interface Config : NSObject <NSCoding>

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *hostURL;
@property (strong, nonatomic) NSString *feedsURL;
@property (strong, nonatomic) NSString *logOutURL;
@property (strong, nonatomic) NSString *registrationURL;
@property (strong, nonatomic) NSString *forgotPasswordURL;
@property (strong, nonatomic) NSString *authenticationURL;
@property (strong, nonatomic) NSString *receiptVerificationURL;
@property (strong, nonatomic) NSString *restoreProductURL;

//settings
@property (strong, nonatomic) NSString *helpURL;
@property (strong, nonatomic) NSString *faqURL;
@property (strong, nonatomic) NSString *termsURL;
@property (strong, nonatomic) NSString *contactURL;

@property (strong, nonatomic) NSMutableArray *feeds;

- (Feed *) getFeed;

@end
