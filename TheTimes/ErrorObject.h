//
//  ErrorObject.h
//  Pointless
//
//  Created by Daniel on 19/11/2013.
//  Copyright (c) 2013 Jam. All rights reserved.
//
//  Allows us to return an error and associated object if required.

#import <Foundation/Foundation.h>

@interface ErrorObject : NSObject

@property (nonatomic, retain) id object;
@property (nonatomic, retain) NSString *errorText;

@end
