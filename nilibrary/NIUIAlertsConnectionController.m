    //
//  NIUIAlertsConnectionController.m
//  TheSun
//
//  Created by Ondrej Rafaj on 30.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "NIUIAlertsConnectionController.h"
#import "NINetworkingConnection.h"


@implementation NIUIAlertsConnectionController

@synthesize ccCenteredView, ccShadowView;

#pragma mark Creating view

- (void)createShadow {
	self.ccShadowView = [[UIView alloc] initWithFrame:self.view.frame];
	self.ccShadowView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	if (!ccShadowColor) ccShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.ccShadowView.backgroundColor = ccShadowColor;
	self.ccShadowView.alpha = 0;
	
	[self.view addSubview:self.ccShadowView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	self.ccShadowView.alpha = 1;
	[UIView commitAnimations];
}

- (void)removeBlocker {
	NSLog(@"removeBlocker");
	[self.ccCenteredView removeFromSuperview];
	[self.ccShadowView removeFromSuperview];
}

- (void)fadeOutBlocker {
	NSLog(@"fadeOutBlocker");
	ccIsBlocker = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeBlocker)];
	self.ccCenteredView.alpha = 0;
	self.ccShadowView.alpha = 0;
	[UIView commitAnimations];
}

- (void)createBlocker {
	NSLog(@"createBlocker");
	ccIsBlocker = YES;
	[self createShadow];
	CGSize v = self.view.frame.size;
	CGSize c = self.ccCenteredView.frame.size;
	int leftPos = ((v.width / 2) - (c.width / 2));
	int rightPos = ((v.height / 2) - (c.height / 2));
	self.ccCenteredView.alpha = 0;
	self.ccCenteredView.frame = CGRectMake(leftPos, rightPos, self.ccCenteredView.frame.size.width, self.ccCenteredView.frame.size.height);
	[self.view addSubview:self.ccCenteredView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	self.ccCenteredView.alpha = 1;
	[UIView commitAnimations];
}

#pragma mark Connection check

- (BOOL)checkForConnection {
	NSLog(@"checkForConnection");
	if (![NINetworkingConnection isAnyConnectionAvailable]) {
//		if (!ccIsBlocker) [self createBlocker];
		return NO;
	}
	else {
//		if (ccIsBlocker) [self fadeOutBlocker];
		return YES;
	}
}

- (BOOL)checkForConnectionTo: (NSString*) hostName {
	if (![NINetworkingConnection isConnectionAvailable: hostName]) {
		if (!ccIsBlocker) [self createBlocker];
		NSLog(@"NO - checkForConnectionTo %@", hostName);
		return NO;
	}
	else {
		if (ccIsBlocker) [self fadeOutBlocker];
		NSLog(@"YES - checkForConnectionTo %@", hostName);
		return YES;
	}
}

#pragma mark Set properties

- (void)setShadowColor:(UIColor *)color {
	ccShadowColor = color;
}

- (void)startConstantConnectionCheckWithTimeInterval:(NSTimeInterval)interval {
	ccConnectionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(checkForConnection) userInfo:nil repeats:YES];
}
							  
#pragma mark Initialization

- (id)initWithCenteredView:(UIView *)centeredView andFrame:(CGRect)frame {
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.frame = frame;
	ccCenteredView = centeredView;
	[self checkForConnection];
	return self;
}

- (id)initWithCenteredImage:(UIImage *)centeredImage andFrame:(CGRect)frame {
	UIImageView *iv = [[UIImageView alloc] initWithImage:centeredImage];
	return [self initWithCenteredView:iv andFrame:frame];
}

#pragma mark View methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
	[ccShadowView release];
    [super dealloc];
}


@end
