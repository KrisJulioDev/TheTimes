//
//  TrackingUtil.m
//  The Sun
//
//  Created by Daniel on 06/03/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "TrackingUtil.h"
#import <sys/utsname.h>
#import <TealiumLibrary/Tealium.h>
#import "AppConfig.h"
#import "UserInterfaceUtils.h"
#import "LocalyticsSession.h"
#import "User.h"
#import "TheTimesAppDelegate.h"
#import "Reachability.h"

@implementation TrackingUtil

NSString * const REGION_ENGLAND = @"england";
NSString * const REGION_IRELAND = @"ireland";
NSString * const REGION_SCOTLAND = @"scotland";

+ (void) trackPageName:(NSString *)name
{
    [TrackingUtil trackPageName:name fromView:nil extraData:nil includeInTesting:NO isEvent:NO];
}

+ (void) trackPageName:(NSString *)name includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:nil extraData:nil includeInTesting:includeInTesting isEvent:NO];
}

+ (void) trackPageName:(NSString *)name extraData:(NSDictionary *)extraData
{
    [TrackingUtil trackPageName:name fromView:nil extraData:extraData includeInTesting:NO isEvent:NO];
}

+ (void) trackPageName:(NSString *)name extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:nil extraData:extraData includeInTesting:includeInTesting isEvent:NO];
}

+ (void) trackPageName:(NSString *)name fromView:(UIView *)view
{
    [TrackingUtil trackPageName:name fromView:view extraData:nil includeInTesting:NO isEvent:NO];
}

+ (void) trackPageName:(NSString *)name fromView:(UIView *)view includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:view extraData:nil includeInTesting:includeInTesting isEvent:NO];
}

+ (void) trackPageName:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData
{
    [TrackingUtil trackPageName:name fromView:view extraData:extraData includeInTesting:NO isEvent:NO];
}

+ (void) trackEvent:(NSString *)name
{
    [TrackingUtil trackPageName:name fromView:nil extraData:nil includeInTesting:NO isEvent:YES];
}

+ (void) trackEvent:(NSString *)name includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:nil extraData:nil includeInTesting:includeInTesting isEvent:YES];
}

+ (void) trackEvent:(NSString *)name extraData:(NSDictionary *)extraData
{
    [TrackingUtil trackPageName:name fromView:nil extraData:extraData includeInTesting:NO isEvent:YES];
}

+ (void) trackEvent:(NSString *)name extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:nil extraData:extraData includeInTesting:includeInTesting isEvent:YES];
}

+ (void) trackEvent:(NSString *)name fromView:(UIView *)view
{
    [TrackingUtil trackPageName:name fromView:view extraData:nil includeInTesting:NO isEvent:YES];
}

+ (void) trackEvent:(NSString *)name fromView:(UIView *)view includeInTesting:(BOOL)includeInTesting
{
    [TrackingUtil trackPageName:name fromView:view extraData:nil includeInTesting:includeInTesting isEvent:YES];
}

+ (void) trackEvent:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData
{
    [TrackingUtil trackPageName:name fromView:view extraData:extraData includeInTesting:NO isEvent:YES];
}

+ (void) trackEvent:(NSString *)name fromView:(UIView *)view eventName:(NSString *)eventName eventAction:(NSString *)eventAction eventMethod:(NSString *)eventMethod eventRegistrationAction:(NSString *)eventRegistrationAction customerId:(NSString *)customerId customerType:(NSString *)customerType
{
    NSMutableDictionary *thisData = [[NSMutableDictionary alloc] init];
    if (eventAction != nil) { [thisData setObject:eventAction forKey:@"event_navigation_action"]; }
    if (eventName != nil) { [thisData setObject:eventName forKey:@"event_navigation_name"]; }
    if (eventMethod != nil) { [thisData setObject:eventMethod forKey:@"event_navigation_browsing_method"]; }
    if (eventRegistrationAction != nil) { [thisData setObject:eventRegistrationAction forKey:@"event_registration_action"]; }
    if (customerId != nil) { [thisData setObject:customerId forKey:@"customer_id"]; }
    if (customerType != nil) { [thisData setObject:customerType forKey:@"customer_type"]; }
    
    [TrackingUtil trackPageName:name fromView:view extraData:thisData includeInTesting:NO isEvent:YES];
    
}

+ (void) trackPageView:(NSString *)name fromView:(UIView *)view pageName:(NSString *)pageName pageType:(NSString *)pageType pageSection:(NSString *)pageSection pageNumber:(NSString *)pageNumber articleParent:(NSString *)articleParent customerId:(NSString *)customerId customerType:(NSString *)customerType
{
    NSMutableDictionary *thisData = [[NSMutableDictionary alloc] init];
    if (pageName != nil) { [thisData setObject:pageName forKey:@"page_name"]; }
    if (pageType != nil) { [thisData setObject:pageType forKey:@"page_type"]; }
    if (pageSection != nil) { [thisData setObject:pageSection forKey:@"page_section"]; }
    if (pageNumber != nil) { [thisData setObject:pageNumber forKey:@"page_number"]; }
    if (articleParent != nil) { [thisData setObject:articleParent forKey:@"article_parent_name"]; }
    if (customerId != nil) { [thisData setObject:customerId forKey:@"customer_id"]; }
    if (customerType != nil) { [thisData setObject:customerType forKey:@"customer_type"]; }

    [TrackingUtil trackPageName:name fromView:view extraData:thisData includeInTesting:NO isEvent:NO];
}

static NSString *LAST_PAGE_NAME;
static NSString *LAST_PAGE_TYPE;
static NSString *LAST_PAGE_SECTION;
static NSString *LAST_ARTICLE_PARENT_NAME;

+ (void) trackPageName:(NSString *)name fromView:(UIView *)view extraData:(NSDictionary *)extraData includeInTesting:(BOOL)includeInTesting isEvent:(BOOL)isEvent
{
    if ([[AppConfig sharedInstance] isTestingTracking] && !includeInTesting) { return; }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    if (extraData != nil)
    {
        [data addEntriesFromDictionary:extraData];
    }
    
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:gbLocale];
    [dateFormatter setDateFormat:@"ha"];
    [data setObject:[dateFormatter stringFromDate:now] forKey:@"HourOfDay"];

    [dateFormatter setDateFormat:@"EEEE"];
    [data setObject:[dateFormatter stringFromDate:now] forKey:@"DayOfWeek"];

    [data setObject:[TrackingUtil isWeekend:now] ? @"Weekend" : @"Weekday" forKey:@"WeekdayWeekend"];

    NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
    [timestampDateFormatter setLocale:gbLocale];
    [timestampDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *timestampString = [timestampDateFormatter stringFromDate:now];
    [data setObject:timestampString forKey:@"t"];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    [data setObject:[NSString stringWithFormat:@"%i x %i", (int)screenBounds.size.width, (int)screenBounds.size.height] forKey:@"ScreenResolution"];
    [data setObject:[UIDevice currentDevice].systemVersion forKey:@"DeviceFirmware"];
    
    [data setObject:@"the sun classic ios app" forKey:@"page_site_name"];
    
    NSString * region = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
    NSString *regionName = nil;
    if ([REGION_ENGLAND isEqual:region]) { regionName = @"england"; }
    else if ([REGION_IRELAND isEqual:region]) { regionName = @"ireland"; }
    else if ([REGION_SCOTLAND isEqual:region]) { regionName = @"scotland"; }
    else { regionName = @"uk"; }
    
    [data setObject:regionName forKey:@"page_site_region"];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    [data setObject:machineName forKey:@"device"];
    
    if (view != nil)
    {
        [data setObject:view.frame.size.width > view.frame.size.height ? @"landscape" : @"portrait" forKey:@"orientation"];
    }
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [data setObject:[NSString stringWithFormat:@"ios %@", bundleVersion] forKey:@"app_version"];
    
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.user != nil)
    {
        NSString *cpn = [appDelegate.user extractCpn];
        if (cpn != nil && ![@"" isEqualToString:cpn])
        {
            [data setObject:[NSString stringWithFormat:@"cpn:%@", cpn] forKey:@"customer_id"];
        }
    }
    
    NSString *connectionType = @"none";
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (status == ReachableViaWiFi)
    {
        connectionType = @"wifi";
    }
    else if (status == ReachableViaWWAN)
    {
        connectionType = @"wwan";
    }
    [data setObject:connectionType forKey:@"connection_type"];
    
    if (isEvent)
    {
        if (LAST_PAGE_NAME != nil) { [data setObject:LAST_PAGE_NAME forKey:@"page_name"]; }
        if (LAST_PAGE_TYPE != nil) { [data setObject:LAST_PAGE_TYPE forKey:@"page_type"]; }
        if (LAST_PAGE_SECTION != nil) { [data setObject:LAST_PAGE_SECTION forKey:@"page_section"]; }
        if (LAST_ARTICLE_PARENT_NAME != nil) { [data setObject:LAST_ARTICLE_PARENT_NAME forKey:@"article_parent_name"]; }
    }
    else
    {
        LAST_PAGE_NAME = [data objectForKey:@"page_name"];
        LAST_PAGE_TYPE = [data objectForKey:@"page_type"];
        LAST_PAGE_SECTION = [data objectForKey:@"page_section"];
        LAST_ARTICLE_PARENT_NAME = [data objectForKey:@"article_parent_name"];
    }
    
    if ([[AppConfig sharedInstance] isTrackingUseTealium])
    {
        NSMutableDictionary *tealiumData = [[NSMutableDictionary alloc] initWithDictionary:data];
        if ([data objectForKey:@"customer_id"] == nil && [[Tealium sharedInstance] retrieveUUID] != nil)
        {
            [tealiumData setObject:[[Tealium sharedInstance] retrieveUUID] forKey:@"customer_id"];
        }
        [[Tealium sharedInstance] track:name customData:data as:(isEvent ? TealiumEventCall : TealiumViewCall)];
    }
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] tagEvent:name attributes:data];
    }
}

+ (void) applicationDidFinishLaunching
{
    if ([[AppConfig sharedInstance] isTrackingUseTealium])
    {
        [Tealium initSharedInstance: [[AppConfig sharedInstance] getTealiumAccountName]
                            profile: [[AppConfig sharedInstance] getTealiumProfileName]
                             target: [[AppConfig sharedInstance] getTealiumTarget]
                            options: 0];
    }
}

+ (void) applicationDidBecomeActive
{
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] LocalyticsSession:[[AppConfig sharedInstance] getLocalyticsAppKey]];
        [[LocalyticsSession shared] resume];
        [[LocalyticsSession shared] upload];
    }
}

+ (void) applicationWillTerminate
{
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] close];
        [[LocalyticsSession shared] upload];
    }
}

+ (void) applicationWillResignActive
{
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] close];
        [[LocalyticsSession shared] upload];
    }
}

+ (void) applicationWillEnterForeground
{
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] resume];
        [[LocalyticsSession shared] upload];
    }
}

+ (void) applicationDidEnterBackground
{
    if ([[AppConfig sharedInstance] isTrackingUseLocalytics])
    {
        [[LocalyticsSession shared] close];
        [[LocalyticsSession shared] upload];
    }
}

+ (BOOL) isWeekend:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSUInteger weekdayOfDate = [components weekday];
    
    if (weekdayOfDate == weekdayRange.location || weekdayOfDate == weekdayRange.length)
    {
        return YES;
    }
    
    return NO;
}

@end
