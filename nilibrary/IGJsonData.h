//
//  IGJsonData.h
//  IGFramework
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGJson.h"
#import "NSObject+IGJson.h"
#import "NSString+IGJson.h"


@interface IGJsonData : NSObject {

}

+ (id)getDataFromString:(NSString *)string;

+ (id)getDataFromFile:(NSString *)filePath;

+ (id)getDataFromUrl:(NSString *)urlPath;

+ (id)getDataFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension;

+ (id)getDataFromBundleFile:(NSString *)fileName;

+ (NSDictionary *)getDictionaryFromString:(NSString *)string;

+ (NSDictionary *)getDictionaryFromFile:(NSString *)filePath;

+ (NSDictionary *)getDictionaryFromUrl:(NSString *)urlPath;

+ (NSDictionary *)getDictionaryFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension;

+ (NSDictionary *)getDictionaryFromBundleFile:(NSString *)fileName;

+ (NSDictionary *)getDictionaryFromString:(NSString *)string;

+ (NSArray *)getArrayFromString:(NSString *)string;

+ (NSArray *)getArrayFromFile:(NSString *)filePath;

+ (NSArray *)getArrayFromUrl:(NSString *)urlPath;

+ (NSArray *)getArrayFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension;

+ (NSArray *)getArrayFromBundleFile:(NSString *)fileName;

+ (NSArray *)getArrayFromString:(NSString *)string;



@end
