//
//  NIPreloaderRotating.m
//  NILibrary
//
//  Created by Ondrej Rafaj on 18.6.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NIPreloaderRotating.h"


@implementation NIPreloaderRotating

@synthesize preloaderImage;


- (id)initWithImage:(UIImage *)image andRotationTime:(NSInteger)time {
	UIImageView *iv = [[UIImageView alloc] initWithImage:image];
	self.preloaderImage = iv;
	[iv release];
	if (self = [self initWithFrame:preloaderImage.frame]) {
		[self addSubview:preloaderImage];
	}
	return self;
}

- (void)rotateToAngle:(float)angle {
	CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0f);
	self.preloaderImage.transform = transform;
}

- (void)startRotatingElement {
	if (enableRotation) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:(rotationTime / 2)];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidFinishRotating)];
		[self rotateToAngle:180];
		[UIView commitAnimations];
	}
}

- (void)animationDidFinishRotating {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:(rotationTime / 2)];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startRotatingElement)];
	[self rotateToAngle:0];
	[UIView commitAnimations];
}

- (void)startRotating {
	enableRotation = YES;
	[self startRotatingElement];
}

- (void)stopRotating:(BOOL)finishRotation {
	enableRotation = NO;
	if (!finishRotation) {
		[self rotateToAngle:0];
	}
}

- (void)dealloc {
	[preloaderImage release];
    [super dealloc];
}


@end
