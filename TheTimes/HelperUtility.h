//
//  HelperUtility.h
//  TheTimes
//
//  Created by KrisMraz on 10/27/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "trackingClass.h"

@interface HelperUtility : NSObject
{
    enum CONNECTION_TYPE{
        None = 0,
        Wifi,
        Wwan,
    };
} 

-(int) connectionType;

+ (id) sharedInstance;
+ (id<GAITracker>) trackingClass;
@end
