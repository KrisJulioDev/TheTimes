
#import "Edition.h"
#import "UserInterfaceUtils.h"
#import "AutoCoding.h"

@implementation EditionPageExtra

@end

@implementation EditionPage

@end

@implementation EditionSection

@end

@implementation Edition

- (NSString *) getBaseDirectory
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (_type != nil)
    {
        return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"papers/%@/%@/%@/", _region, _type, _dateString]];
    }
    return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"papers/%@/%@/", _region, _dateString]];
}

- (NSString *) getImageDirectory
{
    return [NSString stringWithFormat:@"%@%@", [self getBaseDirectory], @"/JPG/"];
}

- (NSString *) getPDFDirectory
{
    return [NSString stringWithFormat:@"%@%@", [self getBaseDirectory], @"/PDF/"];
}

- (NSString *) getConfigDirectory
{
    return [NSString stringWithFormat:@"%@%@", [self getBaseDirectory], @"/CONFIG/"];
}

- (NSString *) getConfigFile
{
    return [NSString stringWithFormat:@"%@%@", [self getConfigDirectory], @"edition.json"];;
}

- (NSString *) getThumbnailFile
{
    return [NSString stringWithFormat:@"%@%@.jpg", [self getBaseDirectory], _dateString];
}

static NSDateFormatter *trackingDateFormatter;

- (NSString *) getTrackingDateString
{
    if (trackingDateFormatter == nil)
    {
        trackingDateFormatter = [[NSDateFormatter alloc] init];
        [trackingDateFormatter setDateFormat:@"EEEE, d MMMM yyyy"];
    }

    return [[trackingDateFormatter stringFromDate:_date] lowercaseString];
}

- (BOOL) isDownloaded
{
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToEdition:other];
}

- (BOOL)isEqualToEdition:(Edition *)aEdition {
    if (self == aEdition)
        return YES;
    if (![[self paperUrl] isEqualToString:[aEdition paperUrl]])
        return NO;
    return YES;
}

- (NSString *) getPdfUrl:(EditionPage *)page
{
    return [NSString stringWithFormat:@"%@%@", [self getPDFDirectory], page.relativePdfUrl];
}

- (NSString *) getThumbnailUrl:(EditionPage *)page
{
    return [NSString stringWithFormat:@"%@%@", [self getImageDirectory], page.relativeThumbnailUrl];
}

@end
