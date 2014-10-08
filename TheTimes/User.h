//
//  User.h
//  TheSun
//
//  Created by Daniel on 28/05/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic, retain) NSString *cpn;

- (NSString *) extractCpn;

+ (NSString *) getKeychainAcs;
+ (NSString *) getKeychainSacs;
+ (NSString *) getKeychainIam;
+ (NSString *) getKeychainLivefyre;

+ (void) setKeychainAcs:(NSString *)value;
+ (void) setKeychainSacs:(NSString *)value;
+ (void) setKeychainIam:(NSString *)value;
+ (void) setKeychainLivefyre:(NSString *)value;

+ (void) clearKeychain;

@property (nonatomic) BOOL isAppleAccount;

@end
