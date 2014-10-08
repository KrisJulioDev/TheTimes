//
//  User.m
//  TheSun
//
//  Created by Daniel on 28/05/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "User.h"
#import "AutoCoding.h"
#import "UICKeyChainStore.h"

@implementation User

static NSString *ACS_KEY = @"acs_ngn";
static NSString *SACS_KEY = @"sacs_ngn";
static NSString *IAM_KEY = @"iam_tgt";
static NSString *LIVEFYRE_KEY = @"livefyre_token";

- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    //ignore, we don't mind trying to set values for properties that don't exist, e.g. from a web service response
}

- (NSString *) extractCpn
{
    NSString *acs_ngn = [[User getKeychainAcs] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (_isAppleAccount || acs_ngn == nil)
    {
        return nil;
    }
    
    if (_cpn != nil)
    {
        return _cpn;
    }
    
    static NSString *eidString = @"eid=";
    
    NSUInteger eidIndex = [acs_ngn rangeOfString:eidString].location;
    
    if (eidIndex != NSNotFound)
    {
        eidIndex+=eidString.length;
    }
    
    if (acs_ngn.length > eidIndex)
    {
        NSString *croppedAcs_ngn = [acs_ngn substringFromIndex:eidIndex];
        long endIndex = [croppedAcs_ngn rangeOfString:@"&"].location;
        if (endIndex != NSNotFound)
        {
            croppedAcs_ngn = [croppedAcs_ngn substringToIndex:endIndex];
        }
        
        self.cpn = croppedAcs_ngn;
    }
    
    return _cpn;
}

+ (NSString *) getKeychainAcs
{
    return [UICKeyChainStore stringForKey:ACS_KEY];
}

+ (NSString *) getKeychainSacs
{
    return [UICKeyChainStore stringForKey:SACS_KEY];
}

+ (NSString *) getKeychainIam
{
    return [UICKeyChainStore stringForKey:IAM_KEY];
}

+ (NSString *) getKeychainLivefyre
{
    return [UICKeyChainStore stringForKey:LIVEFYRE_KEY];
}

+ (void) setKeychainAcs:(NSString *)value
{
    [UICKeyChainStore setString:value forKey:ACS_KEY];
}

+ (void) setKeychainSacs:(NSString *)value
{
    [UICKeyChainStore setString:value forKey:SACS_KEY];
}

+ (void) setKeychainIam:(NSString *)value
{
    [UICKeyChainStore setString:value forKey:IAM_KEY];
}

+ (void) setKeychainLivefyre:(NSString *)value
{
    [UICKeyChainStore setString:value forKey:LIVEFYRE_KEY];
}

+ (void) clearKeychain
{
    [UICKeyChainStore removeItemForKey:ACS_KEY];
    [UICKeyChainStore removeItemForKey:SACS_KEY];
    [UICKeyChainStore removeItemForKey:IAM_KEY];
    [UICKeyChainStore removeItemForKey:LIVEFYRE_KEY];
}
@end
