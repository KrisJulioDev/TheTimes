//
//  Config.m
//  The Sun
//
//  Created by Daniel on 14/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "Config.h"
#import "AutoCoding.h"
#import "UserInterfaceUtils.h"

@implementation Config

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    //ignore, we don't mind trying to set values for properties that don't exist, e.g. from a web service response
}

- (Feed *) getFeed
{
    Feed *result = nil;
    if (_feeds != nil)
    {
        NSString *region = [UserInterfaceUtils getPaperRegion];
        for (Feed *thisFeed in _feeds)
        {
            if ([[region lowercaseString] isEqualToString:[thisFeed.region lowercaseString]])
            {
                return thisFeed;
            }
        }
        
        if ([_feeds count] > 0)
        {
            result = [_feeds objectAtIndex:0];
        }
    }
    
    return result;
}


@end
