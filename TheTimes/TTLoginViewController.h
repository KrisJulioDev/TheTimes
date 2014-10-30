//
//  TTLoginViewController.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface TTLoginViewController : GAITrackedViewController <UIWebViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITextField *passwordEntry, *userNameEntry;
    IBOutlet UIActivityIndicatorView *spinner;
    
    IBOutlet UIView *mScreenBarrier;
    IBOutlet UIView *mScreenBarrierView;
    BOOL loginInProcess;
    
    
    CGRect originalFrame;
    BOOL textFieldIsUp;
}

extern NSString *const SIGNIN_SCHEME;
@property (nonatomic, retain) UIWebView *webView;

@end
