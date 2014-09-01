//
//  TTWebService.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTWebService : NSObject


+ (TTWebService*) sharedInstance;
+ (NSString *) getUrl;
@end
