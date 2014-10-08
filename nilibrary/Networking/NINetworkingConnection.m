//
//  NINetworkingConnection.m
//  NIFramework
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NINetworkingConnection.h"
#import "NINetworkingReachability.h"

@implementation NINetworkingConnection


/**
 Checks if the device is connected to the WiFi
 
 @return BOOL
 */
+ (BOOL)isWiFiConnectionAvailable {
	NINetworkingReachability *internetReach = [[[NINetworkingReachability reachabilityForInternetConnection] retain] autorelease];
	if([internetReach currentReachabilityStatus] == ReachableViaWiFi) return YES;
	else return NO;
}

/**
 Checks if the device is reachable on the cellular network
 
 @return BOOL
 */
+ (BOOL)isCellularConnectionAvailable {
	NINetworkingReachability* internetReach = [[[NINetworkingReachability reachabilityForInternetConnection] retain] autorelease];
	if([internetReach currentReachabilityStatus] == ReachableViaWWAN) return YES;
	else return NO;
}


/**
 Checks if the device is reachable
 
 @return BOOL
 */
+ (BOOL)isAnyConnectionAvailable {
	NSLog(@"isAnyConnectionAvailable");
	NINetworkingReachability* internetReach = [[[NINetworkingReachability reachabilityForInternetConnection] retain] autorelease];
	if([internetReach currentReachabilityStatus] != NotReachable) return YES;
	else return NO;
}

+ (BOOL)isConnectionAvailable: (NSString*) hostName {
	NINetworkingReachability* internetReach = [[[NINetworkingReachability reachabilityWithHostName: hostName] retain] autorelease];
	if([internetReach currentReachabilityStatus] != NotReachable) 
	{
		NSLog(@"YES - isConnectionAvailable %@", hostName);
		return YES;
	}
	else {
		NSLog(@"NO- isConnectionAvailable %@", hostName);
		return NO;
	}
	
}


@end
