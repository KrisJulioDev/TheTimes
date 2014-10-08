//
//  IGSettingsUser.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGSettingsUser.h"


@implementation IGSettingsUser

/**
 Stores an object in NSUserDefaults with specific Key
 
 @param object id Object that's going to be stored in the NSUserDefaults
 @param key NSString Key / Identifier for the object
 */
+ (void)setObject:(id)object forKey:(NSString *)key {
	if (object) {
		[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

/**
 Stores an NSString in NSUserDefaults with specific Key
 
 @param object NSString String that's going to be stored in the NSUserDefaults
 @param key NSString Key / Identifier for the object
 */
+ (void)setString:(NSString *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Stores an NSArray in NSUserDefaults with specific Key
 
 @param object NSArray Array that's going to be stored in the NSUserDefaults
 @param key NSString Key / Identifier for the object
 */
+ (void)setArray:(NSArray *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Stores an NSDictionary in NSUserDefaults with specific Key
 
 @param object NSDictionary Dictionary that's going to be stored in the NSUserDefaults
 @param key NSString Key / Identifier for the object
 */
+ (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key {
	[self setObject:object forKey:key];
}

/**
 Returns an Object from NSUserDefaults with specific Key
 
 @param key NSString Key / Identifier for the object
 
 @return id Object
 */
+ (id)getObjectForKey:(NSString *)key {
	return [[NSUserDefaults standardUserDefaults] objectForKey:key]; 
}

/**
 Returns an NSString from NSUserDefaults with specific Key
 
 @param key NSString Key / Identifier for the object
 
 @return NSString Object
 */
+ (NSString *)getStringForKey:(NSString *)key {
	NSString *ret = (NSString *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSString alloc] init] autorelease];
	return ret;
}

/**
 Returns an NSArray from NSUserDefaults with specific Key
 
 @param key NSString Key / Identifier for the object
 
 @return NSArray Object
 */
+ (NSArray *)getArrayForKey:(NSString *)key {
	NSArray *ret = (NSArray *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSArray alloc] init] autorelease];
	return ret;
}

/**
 Returns an NSDictionary from NSUserDefaults with specific Key
 
 @param key NSString Key / Identifier for the object
 
 @return NSDictionary Object
 */
+ (NSDictionary *)getDictionaryForKey:(NSString *)key {
	NSDictionary *ret = (NSDictionary *)[self getObjectForKey:key];
	if (!ret) ret = [[[NSDictionary alloc] init] autorelease];
	return ret;
}


@end
