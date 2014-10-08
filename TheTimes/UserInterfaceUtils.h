//
//  UserInterfaceUtils.h
//  The Sun
//
//  Created by Daniel on 20/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInterfaceUtils : NSObject
/*
extern NSString * const OVERRIDDEN_REGION_KEY;
extern NSString * const PAPER_REGION_KEY;
extern NSString * const PAPER_REGION_ENGLAND;
*/

+ (UIImageView *)getLoadingImage;
+ (UIView *) addLoadingCover:(UIView *)loadingView parent:(UIView *)parent;
+ (UIView *) addLoadingCoverWithMsg:(UIView *)loadingView parent:(UIView *)parent message:(NSString *)msg;
+ (void) showPopupWithTitle:(NSString *)title text:(NSString *)text;

+ (NSString *) getPaperRegion;
+ (NSString *) getRegion;
+ (UIImage *) getPerWeekResource;
+ (UIImage *) getPerMonthResource;
+ (UIImage *) getPriceResource;

+ (NSString *) getRegionSaveText;

+ (void) removeAllSubviews:(UIView *)parentView;

+ (void) setX:(int)x forView:(UIView *)view;

+ (void) setY:(int)y forView:(UIView *)view;
+ (void) setHeight:(int)height forView:(UIView *)view;

+ (void) setLogo:(UIImageView *)imageView;

@end
