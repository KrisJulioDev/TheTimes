//
//  SemiModalAnimatedTransition.m
//  TheTimes
//
//  Created by KrisMraz on 10/17/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "SemiModalAnimatedTransition.h"

@implementation SemiModalAnimatedTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0;// self.presenting ? 0.6 : 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
    
    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = endFrame;
        startFrame.origin.y = endFrame.size.height;
        
        toViewController.view.frame = endFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        //endFrame.origin.y = endFrame.size.height;
        fromViewController.view.frame = endFrame;
        [transitionContext completeTransition:YES];
        
        
    }
}


@end
