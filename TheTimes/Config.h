//
//  Config.h
//  The Sun
//
//  Created by Daniel on 14/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@interface Config : NSObject <NSCoding>

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *hostURL;
@property (strong, nonatomic) NSString *feedsURL;
@property (strong, nonatomic) NSString *logOutURL;
@property (strong, nonatomic) NSString *registrationURL;
@property (strong, nonatomic) NSString *receiptVerificationURL;
@property (strong, nonatomic) NSString *restoreProductURL;

@property (strong, nonatomic) NSMutableArray *feeds;

- (Feed *) getFeed;

@end
