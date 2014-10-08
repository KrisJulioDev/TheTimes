//
//  TemplatePageUIViewDelegate.h
//  iPadTimes
//
//  Created by Ondrej Rafaj on 22.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIReachabilityAsynchronousDelegate <NSObject>

@required

- (void)reachabilityCheckSucceeded;

- (void)reachabilityCheckFailed;

@end
