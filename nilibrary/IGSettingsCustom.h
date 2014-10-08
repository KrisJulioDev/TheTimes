///
///  IGSettingsCustom.h
///  IGFrameworkProject
///
///  Created by Ondrej Rafaj on 1.4.10.
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>


@interface IGSettingsCustom : NSObject {
	
	NSString *internalIdentifier;
	
	NSMutableDictionary *data;
	
}

@property (nonatomic, retain) NSString *internalIdentifier;

@property (nonatomic, retain) NSMutableDictionary *data;


+ (NSString *)getPath:(NSString *)identifier;

- (IGSettingsCustom *)initWithIdentifier:(NSString *)identifier;

- (void)synchronize;

- (void)setObject:(id)object forKey:(NSString *)key;

- (void)setString:(NSString *)object forKey:(NSString *)key;

- (void)setArray:(NSArray *)object forKey:(NSString *)key;

- (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key;

- (id)getObjectForKey:(NSString *)key;

- (NSString *)getStringForKey:(NSString *)key;

- (NSArray *)getArrayForKey:(NSString *)key;

- (NSDictionary *)getDictionaryForKey:(NSString *)key;

+ (void)setObject:(id)object forKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (void)setString:(NSString *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (void)setArray:(NSArray *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (id)getObjectForKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (NSString *)getStringForKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (NSArray *)getArrayForKey:(NSString *)key withIdentifier:(NSString *)identifier;

+ (NSDictionary *)getDictionaryForKey:(NSString *)key withIdentifier:(NSString *)identifier;


@end
