//
//  IGFilesystemPaths.m
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGFilesystemPaths.h"
#import "IGConfiguration.h"
#import "IGFilesystemIO.h"


@implementation IGFilesystemPaths

/**
 Returns path to the application documents directory
 
 @return NSString Path
 */
+ (NSString *)getDocumentsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}


/**
 Returns path to the root folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getRootDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getDocumentsDirectoryPath], kIGFilesystemPathsFolder];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the temporary folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getTempDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"temp"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the configuration folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getConfigDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"config"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the cache folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getCacheDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"cache"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the persistent images folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getImagesDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"images"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the files folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getFilesDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"files"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the system folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSystemDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"system"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the non SQLite database folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getDatabaseDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"database"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the SQLite database folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSQLiteDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"sqlite"];
	[IGFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the root folder used by IGFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSQLiteFilePath:(NSString *)databaseName {
	return [NSString stringWithFormat:@"%@%@.sqlite", [self getSQLiteDirectoryPath], databaseName];
}


@end
