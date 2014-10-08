//
//  NI_reachabilityService.m
//  iPadTimes
//
//  Created by Digitalsol on 15/04/2010.
//  Copyright 2010 News International. All rights reserved.
//

#import "NI_reachabilityService.h"
#import <SystemConfiguration/SystemConfiguration.h>
//#import "TimesCoreDataAppDelegate.h"
#import "Reachability.h"
#import "Config.h"


@implementation NI_reachabilityService


#pragma mark -
#pragma mark Reachability checks returning boolean

// Checks if a network connection exists (doesn't check that a specific URL is reachable
+ (BOOL)hasNetworkInterfaces {
	return ![NI_reachabilityService errorLevelForINETInterface];
}

// Checks reachability of an arbitrary URL
+ (BOOL)isNetworkAvailable {
	//return [NI_reachabilityService doesURLExist:NSLocalizedString(@"reachabilityUrl",nil)];
    
	return [NI_reachabilityService doesURLExist:REACHABILITYCHECKURL];

}

+ (BOOL)ignoreConnectionRequiredIsNetworkAvailable {
	return [NI_reachabilityService ignoreErrorDoesURLExist:REACHABILITYCHECKURL];
}

// Checks reachability for a given URL, returns true if reachable
+ (BOOL)doesURLExist:(NSString *)urlString {
	
	return ![NI_reachabilityService doesResourceExist:urlString];
}

+ (BOOL)ignoreErrorDoesURLExist:(NSString *)urlString {
	
	return ![NI_reachabilityService ignoreErrorDoesResourceExist:urlString];
}

#pragma mark -
#pragma mark Reachability with error levels

// Checks reachability for a given URL, returns result (reachability boolean and error level)
+ (int)doesResourceExist:(NSString *)urlString {
	
	// Check that there is a network connection
	int errorLevel = [NI_reachabilityService errorLevelForINETInterface];
	
	// If there is a network connection, 
	if (!errorLevel) {
		
		if (urlString && [urlString length]) {
			errorLevel = [NI_reachabilityService errorLevelForURL:urlString timeoutInterval:reachabilityTimeout];
		}
	}
	return errorLevel;
}

+ (int)ignoreErrorDoesResourceExist:(NSString *)urlString {
	
	int errorLevel = [NI_reachabilityService errorLevelForURL:urlString timeoutInterval:longReachabilityTimeout];

	return errorLevel;
}


// Checks to see if the network (WIFI then 3G) is on/off
+ (int)errorLevelForINETInterface {
	
	int interfaceQueryResult;
	int errorLevel = kNIReachabilityNetworkError;
	struct ifaddrs	*interfaceList, *currentInterface;
	
	interfaceQueryResult = getifaddrs(&interfaceList);
	
	if (interfaceQueryResult == 0) {
		currentInterface = interfaceList;
		
		while (currentInterface != nil) {
			
			if (((strncmp(currentInterface->ifa_name, (const char*)"en", 2) == 0) || (strncmp(currentInterface->ifa_name, (const char*)"pdp_ip0", 7) == 0)))
				errorLevel = kNIReachabilityNoError;
			else
				errorLevel = kNIReachabilityInterfaceError;
			
			if (currentInterface->ifa_addr->sa_family == AF_INET) {
				
				// en0, en1... ethernet connection (iPad is only en0, however simulator can be en1 etc.)
				// pdp_ip0... celular connection (safe to assume 0 as unlikely there will be two celular connections, eg. 3G at the same time)
				if ((strncmp(currentInterface->ifa_name, (const char*)"en", 2) == 0) || (strncmp(currentInterface->ifa_name, (const char*)"pdp_ip0", 7) == 0)) {
					
					errorLevel = kNIReachabilityNoError;
					break;
				}
			} else if (errorLevel == kNIReachabilityNoError)
				errorLevel = kNIReachabilityNetworkError;
			
			currentInterface = currentInterface->ifa_next;
		}
		freeifaddrs(interfaceList);
	}
	
	return errorLevel;
}

// Check if a URL is reachable
+ (int)errorLevelForURL:(NSString *)aUrl timeoutInterval:(NSTimeInterval)timeout {
	
	int errorLevel;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
	NSHTTPURLResponse *response = nil;
	NSError *error;
	
	[request setHTTPMethod:@"HEAD"];
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response) {
		if ([response statusCode] < 400) {
			errorLevel = kNIReachabilityNoError;
		}
		else
			errorLevel = kNIReachabilityResourceError;
    } else {
		errorLevel = kNIReachabilityResourceError;
	}
	
	return errorLevel;
}

#pragma mark -
#pragma mark Messages

// Open alert view with error message for given reachability status
+ (void)showAlertForReachabilityStatus:(int)reachabilityStatus 
			 withInterfaceErrorMessage:(NSString*)interfaceErrorMessage
				   networkErrorMessage:(NSString*)networkErrorMessage
				  resourceErrorMessage:(NSString*)resourceErrorMessage
				   timeoutErrorMessage:(NSString*)timeoutErrorMessage {
	
	NSString *reachabilityMessage;
	
	// Choose alert message to use
	if (reachabilityStatus == kNIReachabilityInterfaceError)
		reachabilityMessage = NSLocalizedString(interfaceErrorMessage, nil);
	else if (reachabilityStatus == kNIReachabilityNetworkError)
		reachabilityMessage = NSLocalizedString(networkErrorMessage, nil);
	else if (reachabilityStatus == kNIReachabilityResourceError)
		reachabilityMessage = NSLocalizedString(resourceErrorMessage, nil);
	else if (reachabilityStatus == kNIReachabilityTimeoutError)
		reachabilityMessage = NSLocalizedString(timeoutErrorMessage, nil);
	else {
		// Default, should never get hit unless invalid reachability status passed
		reachabilityMessage = NSLocalizedString(networkErrorMessage, nil);
	}
	
	// Show alert
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"times", nil)
													message:reachabilityMessage
												   delegate:nil
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

@end