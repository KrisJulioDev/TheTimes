//
//  SemiModalAnimatedTransition.h
//  TheTimes
//
//  Created by KrisMraz on 10/17/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SemiModalAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@end
