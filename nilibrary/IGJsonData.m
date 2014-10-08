//
//  IGJsonData.m
//  IGFramework
//
//  Created by Ondrej Rafaj on 22.3.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGJsonData.h"
#import "NSString+URL.h"


@implementation IGJsonData

+ (id)getDataFromString:(NSString *)string {
	IGJson *parser = [[IGJson alloc] init];
	id data = [parser objectWithString:string error:nil];
	[parser release];
	return data;
}

+ (id)getDataFromFile:(NSString *)filePath {
	NSError *error;
	NSString *json_string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	id data = [self getDictionaryFromString:json_string];
	return data;
}

+ (id)getDataFromUrl:(NSString *)urlPath {
	NSURL *location = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
	NSString *json_string = [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:&error];
	if (error) NSLog(@"Something went wrong Error: %d; Message: %@", [error code], [error localizedDescription]);
	id data = [self getDictionaryFromString:json_string];
	return data;
}

+ (id)getDataFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension {
	NSError *error;
	NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
	NSString *json_string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	id data = [self getArrayFromString:json_string];
	[json_string release];
	return data;
}

+ (id)getDataFromBundleFile:(NSString *)fileName {
	return [self getDataFromBundleFile:fileName ofType:@""];
}

+ (NSDictionary *)getDictionaryFromString:(NSString *)string {
	return (NSDictionary *) [self getDataFromString:string];
}

+ (NSDictionary *)getDictionaryFromFile:(NSString *)filePath {
	return (NSDictionary *) [self getDataFromFile:filePath];
}

+ (NSDictionary *)getDictionaryFromUrl:(NSString *)urlPath {
	return (NSDictionary *) [self getDataFromUrl:urlPath];
}

+ (NSDictionary *)getDictionaryFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension {
	return (NSDictionary *) [self getDataFromBundleFile:fileName ofType:fileExtension];
}

+ (NSDictionary *)getDictionaryFromBundleFile:(NSString *)fileName {
	return (NSDictionary *) [self getDataFromBundleFile:fileName ofType:@""];
}

+ (NSArray *)getArrayFromString:(NSString *)string {
	return (NSArray *) [self getDataFromString:string];
}

+ (NSArray *)getArrayFromFile:(NSString *)filePath {
	return (NSArray *) [self getDictionaryFromFile:filePath];
}

+ (NSArray *)getArrayFromUrl:(NSString *)urlPath {
	return (NSArray *) [self getDataFromUrl:urlPath];
}

+ (NSArray *)getArrayFromBundleFile:(NSString *)fileName ofType:(NSString *)fileExtension {
	return (NSArray *) [self getDataFromBundleFile:fileName ofType:fileExtension];
}

+ (NSArray *)getArrayFromBundleFile:(NSString *)fileName {
	return (NSArray *) [self getDataFromBundleFile:fileName ofType:@""];
}

// TODO: finish this method and make it public
+ (NSString *)getJsonStringFromObject:(id)object {
	if (!object) return @"{ }";
	else if ([object isKindOfClass:[NSNumber class]]) return [NSString stringWithFormat:@"{ %@ }", object];
	else if ([object isKindOfClass:[NSString class]]) return [NSString stringWithFormat:@"{ \"%@\" }", object];
	else if ([object isKindOfClass:[NSDictionary class]]) return [NSString stringWithFormat:@"{ %@ }", object];
	else if ([object isKindOfClass:[NSArray class]]) return [NSString stringWithFormat:@"[ %@ ]", object];
	else return @"{ }";
}


@end
