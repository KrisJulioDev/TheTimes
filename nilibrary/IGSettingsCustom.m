//
//  IGSettingsCustom.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGSettingsCustom.h"
#import "IGFilesystemPaths.h"
#import "IGFilesystemIO.h"


@implementation IGSettingsCustom

@synthesize internalIdentifier, data;

/**
 Returns a path to the settings file with specified identifier
 
 @param identifier NSString Identifier of the settings file
 
 @return NSString File path
 */
+ (NSString *)getPath:(NSString *)identifier {
	return [NSString stringWithFormat:@"%@%@.settings", [IGFilesystemPaths getSystemDirectoryPath], identifier];
}

/**
 Returns IGSettingsCustom class initiated with an identifier
 
 @param identifier NSString Identifier of the settings file
 
 @return IGSettingsCustom Object
 */
- (IGSettingsCustom *)initWithIdentifier:(NSString *)identifier {
	if (identifier && [identifier length] > 0) self.internalIdentifier = identifier;
	else return nil;
	NSString *path = [IGSettingsCustom getPath:identifier];
	if ([IGFilesystemIO isFile:path]) self.data = [NSMutableArray arrayWithObject:[[NSDictionary alloc] initWithContentsOfFile:path]];
	else {
		self.data = [[NSMutableDictionary alloc] init];
		[self.data setValue:[[[NSMutableDictionary alloc] init] autorelease] forKey:@"data"];
	}
	return self;
}

/**
 Synchronize the data variable with file
 Do synchronize always when changes were made
 */
- (void)synchronize {
	NSString *path = [IGSettingsCustom getPath:self.internalIdentifier];
	[self.data writeToFile:path atomically:YES];
}

/**
 Sets object for a specific key in initiated file
 
 @param object id Object to be stored
 @param key NSString Key for the object
 */
- (void)setObject:(id)object forKey:(NSString *)key {
	[[self.data objectForKey:@"data"] setValue:object forKey:key];
}

/**
 Sets NSString for a specific key in initiated file
 
 @param object NSString Object to be stored
 @param key NSString Key for the object
 */
- (void)setString:(NSString *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Sets NSArray for a specific key in initiated file
 
 @param object NSArray Object to be stored
 @param key NSString Key for the object
 */
- (void)setArray:(NSArray *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Sets NSDictionary for a specific key in initiated file
 
 @param object NSDictionary Object to be stored
 @param key NSString Key for the object
 */
- (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Returns object for a specific key in initiated file
 
 @param key NSString Key for the object
 
 @return id Object
 */
- (id)getObjectForKey:(NSString *)key {
	return [[self.data objectForKey:@"data"] objectForKey:key];
}

/**
 Returns NSString for a specific key in initiated file
 
 @param key NSString Key for the object
 
 @return NSString Object
 */
- (NSString *)getStringForKey:(NSString *)key {
	NSString *ret = (NSString *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSString alloc] init] autorelease];
	return ret;
}

/**
 Returns NSArray for a specific key in initiated file
 
 @param key NSString Key for the object
 
 @return NSArray Object
 */
- (NSArray *)getArrayForKey:(NSString *)key {
	NSArray *ret = (NSArray *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSArray alloc] init] autorelease];
	return ret;
}

/**
 Returns NSDictionary for a specific key in initiated file
 
 @param key NSString Key for the object
 
 @return NSDictionary Object
 */
- (NSDictionary *)getDictionaryForKey:(NSString *)key {
	NSDictionary *ret = (NSDictionary *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSDictionary alloc] init] autorelease];
	return ret;
}

/**
 Sets object for a specific key in specified file
 
 @param object id Object to be stored
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 */
+ (void)setObject:(id)object forKey:(NSString *)key withIdentifier:(NSString *)identifier {
	IGSettingsCustom *s = [[[IGSettingsCustom alloc] initWithIdentifier:identifier] autorelease];
	[s setObject:object forKey:key];
	[s synchronize];
}

/**
 Sets NSString for a specific key in specified file
 
 @param object NSString Object to be stored
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 */
+ (void)setString:(NSString *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier {
	[self setObject:object forKey:key withIdentifier:identifier];
}

/**
 Sets NSArray for a specific key in specified file
 
 @param object NSArray Object to be stored
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 */
+ (void)setArray:(NSArray *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier {
	[self setObject:object forKey:key withIdentifier:identifier];
}

/**
 Sets NSDictionary for a specific key in specified file
 
 @param object NSDictionary Object to be stored
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 */
+ (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier {
	[self setObject:object forKey:key withIdentifier:identifier];
}

/**
 Returns object for a specific key in initiated file
 
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 
 @return id Object
 */
+ (id)getObjectForKey:(NSString *)key withIdentifier:(NSString *)identifier {
	NSString *ret = (NSString *)[self getObjectForKey:key withIdentifier:identifier];
	if (!ret) ret = [[[NSString alloc] init] autorelease];
	return ret;
}

/**
 Returns NSString for a specific key in initiated file
 
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 
 @return NSString Object
 */
+ (NSString *)getStringForKey:(NSString *)key withIdentifier:(NSString *)identifier {
	NSString *ret = (NSString *)[self getObjectForKey:key withIdentifier:identifier];
	if (!ret) ret = [[[NSString alloc] init] autorelease];
	return ret;
}

/**
 Returns NSArray for a specific key in initiated file
 
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 
 @return NSArray Object
 */
+ (NSArray *)getArrayForKey:(NSString *)key withIdentifier:(NSString *)identifier {
	NSArray *ret = (NSArray *)[self getObjectForKey:key withIdentifier:identifier];
	if (!ret) ret = [[[NSArray alloc] init] autorelease];
	return ret;
}

/**
 Returns NSDictionary for a specific key in initiated file
 
 @param key NSString Key for the object
 @param identifier NSString Settings identifier
 
 @return NSDictionary Object
 */
+ (NSDictionary *)getDictionaryForKey:(NSString *)key withIdentifier:(NSString *)identifier {
	NSDictionary *ret = (NSDictionary *)[self getObjectForKey:key withIdentifier:identifier];
	if (!ret) ret = [[[NSDictionary alloc] init] autorelease];
	return ret;
}

- (void)dealloc {
	[internalIdentifier, data release];
	[super dealloc];
}


@end
