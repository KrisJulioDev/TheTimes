//
//  NIReachabilityAsynchronous.m
//  iPadTimes
//
//  Created by Digital Sol on 18/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NIReachabilityAsynchronous.h"


@implementation NIReachabilityAsynchronous
@synthesize urlConnection;
@synthesize delegate;

#pragma mark Start / Stop reachability checks

// Check if a URL is reachable
- (void)performReachabilityCheckForURL:(NSString *)aUrl timeoutInterval:(NSTimeInterval)timeout {
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
	[request setHTTPMethod:@"HEAD"];
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[urlConnection release];
}

// Cancel current reachability check
- (void)cancelReachabilityCheck {
	[urlConnection cancel];
	self.urlConnection = nil;
}

#pragma mark Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if (delegate)
		[delegate reachabilityCheckSucceeded];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (delegate)
		[delegate reachabilityCheckFailed];
}

#pragma mark Dealloc

- (void)dealloc {
	[self cancelReachabilityCheck];
	self.urlConnection = nil;
	[super dealloc];
}

@end
