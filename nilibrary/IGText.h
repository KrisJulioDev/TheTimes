//
//  IGText.h
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGTextEncoding.h"


@interface IGText : NSObject {

}

+ (NSString *)removeNewLines:(NSString *)text;

+ (NSString *)replaceNewLinesWithEscapes:(NSString *)text;

+ (NSString *)getSafeText:(NSString *)text;

+ (NSString *)convertText:(NSString *)text fromEncoding:(NSStringEncoding)from toEncoding:(NSStringEncoding)to;

@end
