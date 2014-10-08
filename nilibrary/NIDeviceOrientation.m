//
//  NIDeviceOrientation.m
//  NILibrary
//
//  Created by Ondrej Rafaj on 24.5.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NIDeviceOrientation.h"
#import <UIKit/UIKit.h>


@implementation NIDeviceOrientation

+ (BOOL)isLandscape {
	return UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

+ (BOOL)isPortrait {
	return ![self isLandscape];
}


@end
