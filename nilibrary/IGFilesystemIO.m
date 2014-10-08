//
//  IGFilesystemIO.m
//  iPinchMedia
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGFilesystemIO.h"


@implementation IGFilesystemIO

/**
 Returns YES if path is a folder; NO if otherwise
 
 @param path NSStrig Path to the folder
 
 @return BOOL
 */
+ (BOOL)isFolder:(NSString *)path {
	BOOL isDir;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) return YES;
	else return NO;
}

/**
 Returns YES if path is a file; NO if otherwise
 
 @param path NSStrig Path to the file
 
 @return BOOL
 */
+ (BOOL)isFile:(NSString *)path {
	BOOL isDir;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
		if (isDir) return NO;
		else return YES;
	}
	else return NO;
}

/**
 Returns text content of the file
 
 @param filePath NSStrig Path to the file
 
 @return NSString Content of the file
 */
+ (NSString *)getContentsOfFile:(NSString *)filePath {
	NSError *error;
	return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
}

/**
 Returns file attributes
 
 @param path NSStrig Path to the file
 
 @return NSDictionary File attributes
 */
+ (NSDictionary *)getFileAttributes:(NSString *)path {
	NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError* error;
    
	NSDictionary *fileAttributes = [manager  attributesOfItemAtPath:path error:&error];
	return fileAttributes;
}

/**
 Returns NSArray with all files and folders on selected path
 
 @param path NSStrig Path to the folder
 
 @return NSArray File and folder list
 */
+ (NSArray *)getListAll:(NSString *)path {
	NSMutableArray *fileArray = [[[NSMutableArray alloc] init] autorelease];
	NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:path error:nil];
	for (NSString *file in fileList){
        if (![file isEqualToString:@"~"]) [fileArray addObject:file];
	}
	return fileArray;
}

/**
 Returns NSArray with all files on selected path
 
 @param path NSStrig Path to the folder
 
 @return NSArray File list
 */
+ (NSArray *)getListFiles:(NSString *)path {
	NSMutableArray *fileArray = [[[NSMutableArray alloc] init] autorelease];
	NSArray *fileList = [self getListAll:path];
	for (NSString *file in fileList){
        if (![file isEqualToString:@"~"] ) if ([self isFile:[NSString stringWithFormat:@"%@%@", path, file]]) [fileArray addObject:file];
	}
	return fileArray;
}

/**
 Returns NSArray with all folders on selected path
 
 @param path NSStrig Path to the folder
 
 @return NSArray Folder list
 */
+ (NSArray *)getListFolders:(NSString *)path {
	NSMutableArray *fileArray = [[[NSMutableArray alloc] init] autorelease];
	NSArray *fileList = [self getListAll:path];
	for (NSString *file in fileList){
        if (![file isEqualToString:@"~"] ) if ([self isFolder:[NSString stringWithFormat:@"%@%@", path, file]]) [fileArray addObject:file];
	}
	return fileArray;
}

/**
 Returns filesize in bytes
 
 @param path NSStrig Path to the file
 
 @return int Filesize in bytes
 */
+ (int)getFileSize:(NSString *)path {
	NSDictionary *fileAttributes = [self getFileAttributes:path];
	int ret = [[fileAttributes objectForKey:NSFileSize] intValue];
	return ret;
}

/**
 Returns file extension
 
 @param path NSStrig Path to the file
 
 @return NSString File extension
 */
+ (NSString *)getFileExtension:(NSString *)path {
	NSString *ret = [path pathExtension];
	return ret;
}

/**
 Returns formated file size with bytes / Kb / Mb
 
 @param path NSStrig Path to the file
 
 @return NSString Formated file size
 */
+ (NSString *)getFormatedFileSize:(NSString *)path {
	int fileSize = [self getFileSize:path];
	NSString *extension;
	NSString *formatedFileSize;
	float ff;
	if (fileSize < 1024) {
		formatedFileSize = [NSString stringWithFormat:@"%d", fileSize];
		extension = @"bytes";
	}
	else if (fileSize < 1048576) {
		ff = fileSize / 1024;
		formatedFileSize = [NSString stringWithFormat:@"%.2f", ff];
		extension = @"Kb";
	}
	else {
		ff = fileSize / 1048576;
		formatedFileSize = [NSString stringWithFormat:@"%.2f", ff];
		extension = @"Mb";
	}
	return [NSString stringWithFormat:@"%@ %@", formatedFileSize, extension];
}

/**
 Returns NSDate when the file has been created
 
 @param path NSStrig Path to the file
 
 @return NSDate File created
 */
+ (NSDate *)getFileCreated:(NSString *)path {
	NSDictionary *fileAttributes = [self getFileAttributes:path];
	return [fileAttributes objectForKey:NSFileCreationDate];
}

/**
 Returns NSDate when the file has been modified
 
 @param path NSStrig Path to the file
 
 @return NSDate File modified
 */
+ (NSDate *)getFileModified:(NSString *)path {
	NSDictionary *fileAttributes = [self getFileAttributes:path];
	return [fileAttributes objectForKey:NSFileModificationDate];
}

/**
 Creates full folder path if doesn't exists
 
 @param path NSStrig Path to the file
 */
+ (void)makeFolderPath:(NSString *)path {
	if (![self isFolder:path]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager createDirectoryAtPath:path attributes:nil];
	}
}

/**
 Deletes file or folder on specified path
 
 @param path NSStrig Path to the file or folder
 
 @return BOOL
 */
+ (BOOL)deleteFile:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager removeItemAtPath:path error:nil];
}

/**
 Deletes files on selected path, that are older than selected date
 
 @param date NSDate Limiting date
 @param dir NSStrig Path to the folder
 */
+ (void)deleteFilesOlderThan:(NSDate *)date inDirectory:(NSString *)dir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:dir error:nil];
	NSDictionary *currentFileAttributes;
	NSDate *currentFileDate;
	NSString *path;
	for (NSString *fname in contents) {
		path = [NSString stringWithFormat:@"%@%@", dir, fname];
        NSError* error;
		currentFileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
        
        
        
		currentFileDate = [currentFileAttributes objectForKey:NSFileModificationDate];
		if([currentFileDate compare:date] == NSOrderedAscending) [self deleteFile:path];
	}
}



@end
