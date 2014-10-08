//
//  NIPreloaderRotating.h
//  NILibrary
//
//  Created by Ondrej Rafaj on 18.6.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NIPreloaderRotating : UIView {
	
	UIImageView *preloaderImage;
	
	NSInteger rotationTime;
	
	BOOL enableRotation;
	
}

@property (nonatomic, retain) UIImageView *preloaderImage;

- (id)initWithImage:(UIImage *)image andRotationTime:(NSInteger)time;

- (void)startRotating;

- (void)stopRotating:(BOOL)finishRotation;


@end
