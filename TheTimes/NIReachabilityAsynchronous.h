//
//  NIReachabilityAsynchronous.h
//  iPadTimes
//
//  Created by Digital Sol on 18/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NIReachabilityAsynchronousDelegate.h"

@interface NIReachabilityAsynchronous : NSObject {
	NSURLConnection *urlConnection;
	
	id<NIReachabilityAsynchronousDelegate> delegate;
}

@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, assign) id<NIReachabilityAsynchronousDelegate> delegate;

// Check if a URL is reachable
- (void)performReachabilityCheckForURL:(NSString *)aUrl timeoutInterval:(NSTimeInterval)timeout;

// Cancel current reachability check
- (void)cancelReachabilityCheck;

@end
