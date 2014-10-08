//
//  IGUINoConnectionController.h
//  TheSun
//
//  Created by Ondrej Rafaj on 30.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NIUIAlertsConnectionController : UIViewController {
	
	NSTimer *ccConnectionCheckTimer;
	
	UIColor *ccShadowColor;
	
	UIView *ccCenteredView;
	UIView *ccShadowView;
	
	BOOL ccIsBlocker;
	
}

@property (nonatomic, retain) UIView *ccCenteredView;
@property (nonatomic, retain) UIView *ccShadowView;

- (id)initWithCenteredImage:(UIImage *)centeredImage andFrame:(CGRect)frame;

- (id)initWithCenteredView:(UIView *)centeredView andFrame:(CGRect)frame;

- (void)setShadowColor:(UIColor *)color;

- (void)startConstantConnectionCheckWithTimeInterval:(NSTimeInterval)interval;

- (BOOL)checkForConnection;

- (BOOL)checkForConnectionTo: (NSString*) hostName;

@end
