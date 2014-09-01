//
//  Feed.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "Feed.h"
#import "AutoCoding.h"

@implementation Feed

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    //ignore, we don't mind trying to set values for properties that don't exist, e.g. from a web service response
}

@end
