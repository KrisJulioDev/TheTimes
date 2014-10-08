//
//  NI_reachabilityService.h
//  iPadTimes
//
//  Created by Digitalsol on 15/04/2010.
//  Copyright 2010 News International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>

#define reachabilityContent @"OK"
#define reachabilityTimeout 10
#define longReachabilityTimeout 40

#define kNIReachabilityNoError				0			// No error
#define kNIReachabilityInterfaceError		1			// No WIFI or 3G physical interfaces
#define kNIReachabilityNetworkError			2			// No data connections on the the interfaces
#define kNIReachabilityResourceError		3			// No url found
#define kNIReachabilityTimeoutError			4			// connection timed out


@interface NI_reachabilityService : NSObject {
}

+ (BOOL)isNetworkAvailable;
+ (BOOL)ignoreConnectionRequiredIsNetworkAvailable; 
+ (BOOL)doesURLExist:(NSString *)urlString;
+ (BOOL)ignoreErrorDoesURLExist:(NSString *)urlString;
+ (BOOL)hasNetworkInterfaces;
+ (int)doesResourceExist:(NSString *)urlString;
+ (int)ignoreErrorDoesResourceExist:(NSString *)urlString;
+ (void)showAlertForReachabilityStatus:(int)reachabilityStatus 
							   withInterfaceErrorMessage:(NSString*)interfaceErrorMessage
									 networkErrorMessage:(NSString*)networkErrorMessage
									resourceErrorMessage:(NSString*)resourceErrorMessage
									 timeoutErrorMessage:(NSString*)timeoutErrorMessage;
+ (int)errorLevelForINETInterface;
+ (int)errorLevelForURL:(NSString *)aUrl timeoutInterval:(NSTimeInterval)timeout;

@end