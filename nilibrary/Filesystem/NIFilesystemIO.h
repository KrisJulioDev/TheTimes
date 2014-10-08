//
//  NIFilesystemIO.h
//  NILibrary
//
//  Created by Ondrej Rafaj on 6.5.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NIFilesystemIO : NSObject {

}

+ (BOOL)isFolder:(NSString *)path;

+ (BOOL)isFile:(NSString *)path;

+ (NSString *)getContentsOfFile:(NSString *)filePath;

+ (NSDictionary *)getFileAttributes:(NSString *)path;

+ (NSArray *)getListAll:(NSString *)path;

+ (NSArray *)getListFiles:(NSString *)path;

+ (NSArray *)getListFolders:(NSString *)path;

+ (int)getFileSize:(NSString *)path;

+ (NSString *)getFileExtension:(NSString *)path;

+ (NSString *)getFormatedFileSize:(NSString *)path;

+ (NSDate *)getFileCreated:(NSString *)path;

+ (NSDate *)getFileModified:(NSString *)path;

+ (void)makeFolderPath:(NSString *)path;

+ (BOOL)deleteFile:(NSString *)path;

+ (void)deleteFilesOlderThan:(NSDate *)date inDirectory:(NSString *)dir;


@end
