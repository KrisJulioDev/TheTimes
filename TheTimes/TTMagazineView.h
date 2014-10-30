//
//  TTMagazineView.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "Edition.h"
#import "SPDownloader.h"
#import "trackingClass.h"

static int DOWNLOAD_FAILED_POPUP_TAG = 2;
static int DELETE_POPUP_TAG = 3;
static int CONNECTION_TYPE_POPUP = 4;
static int DELETE_INTERRUPT_POPUP_TAG = 5;

@interface TTMagazineView : UIView <SPDownloaderDelegate, UIAlertViewDelegate>
{
    enum Status {
        stopped,
        paused,
        playing,
        downloaded
    };
    
    enum Status magazineStatus;
    
    id<GAITracker> appTracker;
}
@property (weak, nonatomic) IBOutlet AsyncImageView *iv_frontPage;
@property (nonatomic, strong) Edition *edition;
@property (atomic) BOOL isMainEdition;
@property (nonatomic) NSInteger paperNumber;

@property (nonatomic, strong) IBOutlet UIButton *viewButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) IBOutlet UIView *downloadingView;
 
@property (nonatomic, strong) IBOutlet UIView *textBackground;
@property (nonatomic, strong) IBOutlet UIView *cornerImage;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UILabel *textLabel2;
@property (nonatomic, strong) IBOutlet UILabel *downloadingLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) IBOutlet UIImageView *progressBottom;
@property (nonatomic, strong) IBOutlet UIImageView *progressTop;

//PLAYPAUSE BTNS
@property (strong, nonatomic) IBOutlet UIButton *playPauseBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;


//METHODS
- (void) setUpMagazine: (Edition*) edition;
- (IBAction) downloadThisEdition : ( id ) sender;
- (IBAction) playPauseDownload:(id)sender;
- (IBAction) deleteInterruptedDownload:(id)sender;
@end
