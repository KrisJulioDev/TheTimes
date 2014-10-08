//
//  NIFilesystemPaths.m
//  NILibrary
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NIFilesystemPaths.h"
#import "NIConfiguration.h"
#import "NIFilesystemIO.h"


@implementation NIFilesystemPaths

/**
 Returns path to the application documents directory
 
 @return NSString Path
 */
+ (NSString *)getDocumentsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}


+ (NSString *)getDocumentsDirectoryPathAppending:(NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *p = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], path];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}


/**
 Returns path to the root folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getRootDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@", [self getDocumentsDirectoryPath], kNIFilesystemPathsFolder];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the temporary folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getTempDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"temp"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the configuration folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getConfigDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"config"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the cache folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getCacheDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"cache"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the persistent images folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getImagesDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"images"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the files folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getFilesDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"files"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the system folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSystemDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"system"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the non SQLite database folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getDatabaseDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"database"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the SQLite database folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSQLiteDirectoryPath {
	NSString *p = [NSString stringWithFormat:@"%@/%@/", [self getRootDirectoryPath], @"sqlite"];
	[NIFilesystemIO makeFolderPath:p];
	return p;
}

/**
 Returns path to the root folder used by NIFilesystemPaths class
 
 @return NSString Path
 */
+ (NSString *)getSQLiteFilePath:(NSString *)databaseName {
	return [NSString stringWithFormat:@"%@%@.sqlite", [self getSQLiteDirectoryPath], databaseName];
}


@end
