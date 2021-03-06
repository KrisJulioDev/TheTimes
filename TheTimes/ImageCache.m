//
//  ImageCache.m
//  The Sun
//
//  Created by Daniel on 05/03/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "ImageCache.h" 
#import "Edition.h"

@implementation ImageCache

NSString * const FILES_DATA_KEY = @"filesData";

static ImageCache *sharedInstance;

+ (ImageCache *) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[ImageCache alloc] init];
    }
    
    return sharedInstance;
}

- (id) init
{
    if (self = [super init])
    {
        NSData *filesData = [[NSUserDefaults standardUserDefaults] objectForKey:FILES_DATA_KEY];
        if (filesData != nil)
        {
            self.files = [NSKeyedUnarchiver unarchiveObjectWithData:filesData];
        }
        if (_files == nil)
        {
            self.files = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

/**
 *  Cache imageData to NSUserdefaults with url key
 *
 *  @param imageData Data to Cache
 *  @param url       Url key for locating the data
 */
- (void) addFileToCache:(NSData *)imageData url:(NSString *)url
{
    if (imageData != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filename = [NSString stringWithFormat:@"%f.jpg", [NSDate timeIntervalSinceReferenceDate]];
        filename = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
        if ([fileManager createFileAtPath:filename contents:imageData attributes:nil])
        {
            NSURL *urlToSkip = [NSURL fileURLWithPath:filename];
            [self addSkipBackupAttributeToItemAtURL:urlToSkip];
            
            [_files setObject:filename forKey:url];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_files] forKey:FILES_DATA_KEY];
        }
    }
}

/**
 *  FETCH IMAGE FROM PATH LOCATION
 *
 *  @param url location of image from device directory
 *
 *  @return UIImage data from filename
 */
- (UIImage *) getImage:(NSString *)url
{
    NSString *filename = [_files objectForKey:url];
    if (filename != nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *imageData = [fileManager contentsAtPath:filename];
        if (imageData != nil)
        {
            return [UIImage imageWithData:imageData];
        }
    }
    
    return nil;
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        //DDLogWarn(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
