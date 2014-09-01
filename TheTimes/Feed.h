//
//  Feed.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject <NSCoding>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *public_url;
@property (nonatomic, strong) NSString *region;

@end
