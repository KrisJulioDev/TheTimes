 
#import <Foundation/Foundation.h>

@interface EditionPageExtra : NSObject <NSCoding>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *data;

@end

@interface EditionPage : NSObject <NSCoding>

@property (nonatomic, strong) NSString *relativePdfUrl;
@property (nonatomic, strong) NSString *relativeThumbnailUrl;

@property (nonatomic, strong) NSString * linkUrl;
@property (nonatomic, strong) NSMutableArray *extras;

@end

@interface EditionSection : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (atomic) int pageNumber;

@end

@interface Edition : NSObject <NSCoding>

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *dateString;
@property (nonatomic, retain) NSString *paperThumb;
@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *paperUrl;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *fullPDFPath;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSMutableArray *sections;

- (NSString *) getBaseDirectory;
- (NSString *) getImageDirectory;
- (NSString *) getPDFDirectory;
- (NSString *) getConfigDirectory;
- (NSString *) getConfigFile;
- (NSString *) getThumbnailFile;
- (NSString *) getTrackingDateString;
- (BOOL) isDownloaded;

- (NSString *) getPdfUrl:(EditionPage *)page;
- (NSString *) getThumbnailUrl:(EditionPage *)page;

@end
