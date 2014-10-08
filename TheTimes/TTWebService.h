//
//  TTWebService.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

@interface TTWebService : NSObject

@property (nonatomic, retain) NSArray *paper_editions;
+ (instancetype) sharedInstance;

- (NSMutableArray*) getEditions;

- (Config *) getConfig; 
+ (NSString *) getUrl;

@end
