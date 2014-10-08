//
//  PaperEditionView.h
//  TheTimes
//
//  Created by KrisMraz on 10/8/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperEditionData.h"


@protocol SPEditionPaperViewDelegate;


@interface PaperEditionView : UIView
{
    id <SPEditionPaperViewDelegate> delegate;
	PaperEditionData *managedEditionPaper;
	NSDate *paperDate;
	NSString *paperURL;
	UIButton *launchPaperButton;
	BOOL needsOverlay;
	UILabel *fullDate;
	UILabel *dayOfWeek;
	NSString *dayOfWeekString;
	UIProgressView *progressBar;
	UIButton *deleteButton;
	UIImageView *thumbBackground;
	UIImageView *highlight;
	UIActivityIndicatorView *activityIndicator;
	NSString *downloadImgPath;
	UIImageView *downloadImage;
}

@property (nonatomic, retain) PaperEditionData *managedEditionPaper;
@property (assign) id <SPEditionPaperViewDelegate> delegate;
@property (nonatomic, retain) NSDate *paperDate;
@property (nonatomic, retain) NSString *paperURL;
@property (nonatomic) BOOL needsOverlay;

- (id) initWithDictionary:(NSDictionary*)properties andOrigin:(CGPoint)origin;
- (void) buttonTaped:(id)sender;
- (void) showProgessBar;
- (void) hideProgressBarShowOverlay:(BOOL)overlay;
- (void) updateProgressBar:(float)sizeReceived;
- (void) startWobbling;
- (void) stopWobbling;

@end


@protocol SPEditionPaperViewDelegate <NSObject>
- (void) didSelectEditionPaper:(PaperEditionView*)editionPaper;
- (void) pressedDeleteEditionPaper:(PaperEditionView*)editionPaper forView:(PaperEditionView*)editionPaperView;

@end
