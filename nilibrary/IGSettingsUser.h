///
///  IGSettingsUser.h
///  IGFrameworkProject
///
///  Created by Ondrej Rafaj on 1.4.10.
///  Copyright 2010 Home. All rights reserved.
///

#import <Foundation/Foundation.h>


@interface IGSettingsUser : NSObject {

}

+ (void)setObject:(id)object forKey:(NSString *)key;

+ (void)setString:(NSString *)object forKey:(NSString *)key;

+ (void)setArray:(NSArray *)object forKey:(NSString *)key;

+ (void)setDictionary:(NSDictionary *)object forKey:(NSString *)key;

+ (id)getObjectForKey:(NSString *)key;

+ (NSString *)getStringForKey:(NSString *)key;

+ (NSArray *)getArrayForKey:(NSString *)key;

+ (NSDictionary *)getDictionaryForKey:(NSString *)key;



@end
