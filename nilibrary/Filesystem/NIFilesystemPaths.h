///
///  IGFilesystemPaths.h
///
///  IGFrameworkProject
///
///  Created by Ondrej Rafaj on 22.3.10.
///
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>


@interface NIFilesystemPaths : NSObject {
    
}

+ (NSString *)getDocumentsDirectoryPath;

+ (NSString *)getDocumentsDirectoryPathAppending:(NSString *)path;

+ (NSString *)getRootDirectoryPath;

+ (NSString *)getTempDirectoryPath;

+ (NSString *)getConfigDirectoryPath;

+ (NSString *)getCacheDirectoryPath;

+ (NSString *)getImagesDirectoryPath;

+ (NSString *)getFilesDirectoryPath;

+ (NSString *)getSystemDirectoryPath;

+ (NSString *)getDatabaseDirectoryPath;

+ (NSString *)getSQLiteDirectoryPath;

+ (NSString *)getSQLiteFilePath:(NSString *)databaseName;






@end
