//
//  TTLoginViewController.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTLoginViewController.h" 
#import "BookShelfViewController.h"
#import "TTEditionManager.h"
#import "TheTimesAppDelegate.h"
#import "CookieService.h"
#import "SubscriptionHandler.h"
#import "Reachability.h"
#import "configOptions.h"
#import "User.h"
#import "trackingClass.h"
#import "GAITrackedViewController.h"
#import <sys/utsname.h>
#import "NI_reachabilityService.h"
#import "TrackingUtil.h"
#import "Constants.h"

@interface TTLoginViewController () <UIWebViewDelegate>
{
    UIWebView *webView;
    UIButton *webViewCloseBtn;
}
@end

@implementation TTLoginViewController

NSString *const SIGNIN_SCHEME = @"signin";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark VIEW DID LOAD - VIEW DID APPEAR
- (void)viewDidLoad
{
    //UPDATE EDITIONS BEFORE ANYTHING ELSE
    //[[TTEditionManager sharedInstance] updateEditions];
    
    NSLog(@"TYPE --- %@",[[[NSProcessInfo processInfo] environment] objectForKey:@"TYPE"]);
    dispatch_queue_t tracking = dispatch_queue_create("tracking", NULL);
    dispatch_async(tracking, ^{
        [[trackingClass getInstance] firePageLoad];

    });
    
    [TrackingUtil trackPageView:@"access option page" fromView:self.view pageName:@"access option page" pageType:@"app launch and login" pageSection:@"launch and login" pageNumber:nil articleParent:nil customerId:nil customerType:@"guest"];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("mainLoad", NULL);
    dispatch_async(downloadQueue, ^{
        id<GAITracker> tracker = [[trackingClass getInstance] returnInstance];
        self.trackedViewName = @"Login Screen";
        
        struct utsname systemInfo;
        uname(&systemInfo);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if(![[defaults objectForKey:@"loadedPreviously"] isEqualToString:@"YES"]){
            if(showMarioLink){
                NSString *deviceID = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
                if(![deviceID isEqualToString:@"iPad1,1"]){
                    if(![deviceID isEqualToString:@"iPad1,1"] && ![[defaults objectForKey:@"loadedPreviously"] isEqualToString:@"YES"] && showMarioLink){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Newer App"
                                                                            message:@"Would you like to try our new app?..... marketing text here"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"No"
                                                                  otherButtonTitles:@"Yes",nil];
                            [alert setTag:16];
                            [alert show];
                        });
                    }
                }
                
            }
        }
        
        originalFrame = [self.view frame];
        [defaults setObject:STORE_FIRST_LOAD forKey:@"loadedPreviously"];
        
        [passwordEntry setDelegate:self];
        [userNameEntry setDelegate:self];
        
        //DEBUG - if FORCELOGIN IS SET TO 1
        if(FORCELOGIN==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                mScreenBarrier.hidden = NO;
            });
        }
        else if(![NI_reachabilityService isNetworkAvailable] || [NI_reachabilityService isNetworkAvailable] == NO){
            NSString *userName = [SubscriptionHandler returnUserName];
            NSString *password = [SubscriptionHandler returnPassword];
            
            if(userName.length>0 && password.length>0){
                
                [tracker sendEventWithCategory:@"Login Event" withAction:@"Login Offline" withLabel:@"Offline Previous User" withValue:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    mScreenBarrier.hidden = YES;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    mScreenBarrier.hidden = NO;
                });
                [tracker sendEventWithCategory:@"Login Event" withAction:@"Login Offline" withLabel:@"New User Offline" withValue:0];
            }
        }else{
            
            NSString *userName = [SubscriptionHandler returnUserName];
            NSString *password = [SubscriptionHandler returnPassword];
            
            if(!STORE_USER_DETAILS){
                [SubscriptionHandler storeUserDetails:@"" password:@""];
            }
            if(userName.length>0 && password.length >0){
                __block bool subsCheck;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner setHidden:false];
                    [spinner startAnimating];
                    mScreenBarrier.hidden = YES;
                });
                subsCheck= [SubscriptionHandler checkLoginValid:userName password:password];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                    [spinner setHidden:true];
                    
                    if(subsCheck){
                        [self hideKeyboard:self];
                        
                        [self memberSignIn];
                        [tracker sendEventWithCategory:@"Login Event" withAction:@"Login Success" withLabel:@"Online Stored Details Login" withValue:0];
                    }
                    else{
                        mScreenBarrier.hidden = NO;
                        mScreenBarrierView.hidden = NO;
                    }
                });
            }
            else{
                mScreenBarrierView.hidden = NO;
            }
        }
    });
    
}

#pragma mark GET MAIN URL
- (NSString *) getMainUrl
{
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.config != nil)
    {
        NSString *url = [NSString stringWithFormat:@"https://%@%@", appDelegate.config.hostURL, @"/?r=1&s=0&l=0&gotoUrl=signin%3A%2F%2Fwww.thesun.co.uk%2F"];
        
        // handshaking code for later.
        //NSString *uuid = [[Tealium sharedInstance] retrieveUUID];
        //url = [url stringByAppendingString:@"&prevprod=the%20sun%20classic%20ios%20app&ILC=the%20sun%20classic%20ios%20app"];
        //url = [url stringByAppendingFormat:@"&vis_id=%@", uuid != nil ? uuid : @""];
        
        return url;
    }
    
    return nil;
}

#pragma mark ALERT VIEW DELEGATES
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self loadUrl];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark UITEXTFIELD DELEGATE
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(originalFrame.origin.x, originalFrame.origin.y - 200);
    
    if ( UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [UIView animateWithDuration:0.0f
                              delay:0
                            options: UIViewAnimationOptionTransitionNone
                         animations:^{
                            self.view.transform = transform;
                         }
                         completion:^(BOOL finished){
                             textFieldIsUp = YES;
                         }];
    }
}

/**
 *  editing textfield delegate method
 *
 *  @param textField currently editing textfield
 */
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(originalFrame.origin.x, originalFrame.origin.y);
    
    NSLog(@"Y :%f %f",self.view.frame.origin.y, originalFrame.origin.y);
    if ( UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ) {
        [UIView animateWithDuration:0.0f
                              delay:0
                            options: UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.view.transform = transform;
                         }
                         completion:^(BOOL finished){
                             textFieldIsUp = NO;
                         }];
    }
}

#pragma mark LOAD URL
- (void) loadUrl
{
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.config != nil)
    {
        [CookieService deleteCookiesForDomain:appDelegate.config.hostURL];
        [CookieService deleteCookiesForDomain:@".thesun.ie"];
        [CookieService deleteCookiesForDomain:@".thesun.co.uk"];
        [CookieService deleteCookiesForDomain:@".thescottishsun.co.uk"];
        
        NSString *url = [self getMainUrl];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

/**
 *  Method called after signing in. call updateEditions and dismiss view
 */
- (IBAction) memberSignIn
{
    [[TTEditionManager sharedInstance] updateEditions];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/**
 *  log in button callback
 *
 *  @param sender button
 */
- (IBAction)loginButtonPressed:(id)sender
{
    loginInProcess =true;
    NSString *userName, *password;
    userName = userNameEntry.text;
    password = passwordEntry.text;
    
    [self hideKeyboard:self];
    
    __block NSString *loginStatus;
    loginStatus = @"0";
    CGRect screenRect =CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    UIView *spinnerContainer = [[UIView alloc] initWithFrame:screenRect];
    spinnerContainer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    UIActivityIndicatorView *lspinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.view addSubview:spinnerContainer];
    
    lspinner.center = self.view.center;
    lspinner.hidesWhenStopped = YES;
    [spinnerContainer addSubview:lspinner];
    [lspinner startAnimating];
    
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // how we stop refresh from freezing the main UI thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue, ^{
        if(![[Reachability reachabilityForLocalWiFi] isReachableViaWiFi]){
            if(userName.length>0 && password.length>0){
                loginStatus = @"Login";
                //[tracker sendEventWithCategory:@"Login Event" withAction:@"Login Offline" withLabel:@"Offline Previous User" withValue:0];
                
                
            }else{
                loginStatus = @"Offline";
                //[tracker sendEventWithCategory:@"Login Event" withAction:@"Login Offline" withLabel:@"New User Offline" withValue:0];
            }
            
        } else if(userName.length>0 && password.length >0){
            if([SubscriptionHandler checkLoginValid:userName password:password])
            {
                loginStatus=@"ValidOnline";
                [appDelegate.bookShelfVC fetchTimesData];
                //[tracker sendEventWithCategory:@"Login Event" withAction:@"Login Success" withLabel:@"Online Login" withValue:0];
            }
            else{
                loginStatus = @"Invalid";
                //[tracker sendEventWithCategory:@"Login Event" withAction:@"Login Failure" withLabel:@"Online Login Failure" withValue:0];
            }
        }
        else{
            loginStatus = @"Blank";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinnerContainer removeFromSuperview];
            if([loginStatus isEqualToString:@"Login"]){
                
                [appDelegate.bookShelfVC fetchTimesData];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
            else if ([loginStatus isEqualToString:@"Offline"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Offline"
                                                                message:@"Please go online to login to the app"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show]; 

            }else if ([loginStatus isEqualToString:@"Invalid"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                                                message:@"Please check your email and password and try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if ([loginStatus isEqualToString:@"Blank"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                                                message:@"Username and password are required"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }else if([loginStatus isEqualToString:@"ValidOnline"]){
                if(STORE_USER_DETAILS){
                    [SubscriptionHandler storeUserDetails:userName password:password];
                }
                
                [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
                
                [appDelegate.bookShelfVC fetchTimesData];
                [self dismissViewControllerAnimated:YES completion:nil];

                mScreenBarrier.hidden = YES;
                
            }
            loginInProcess = false;
            
        });
    });
}

- (IBAction)showWebView:(id)sender
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIButton *btnTapped = (UIButton*)sender;
    float x,y, w, h, squareFrame;
    
    w = SCREEN_WIDTH * 0.8f;
    h = SCREEN_HEIGHT * 0.8f;
    x = SCREEN_WIDTH / 2 - ( w / 2);
    y = SCREEN_HEIGHT / 2 - ( h / 2 );
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    webView.layer.borderColor = [UIColor blackColor].CGColor;
    webView.delegate = self;
    webView.layer.cornerRadius = 5;
    
    //add close btn
    webViewCloseBtn = [[UIButton alloc] init];
    squareFrame = 40;
    [webViewCloseBtn setFrame:CGRectMake(x + w - squareFrame / 2, y - squareFrame / 2, squareFrame, squareFrame)];
    [webViewCloseBtn setImage:[UIImage imageNamed:@"btn_Delete_Pressed"] forState:UIControlStateNormal];
    [webViewCloseBtn addTarget:self action:@selector(closeSettingWebView) forControlEvents:UIControlEventTouchUpInside];
    
    UIActivityIndicatorView *webSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(webView.frame.size.width/2 - 25, webView.frame.size.height/2 - 25, 50, 50)];
    webSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [webSpinner setColor:[UIColor grayColor]];
    webSpinner.hidesWhenStopped = YES;
    [webSpinner stopAnimating];
    
    TheTimesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString *url = @"";
    if (btnTapped.tag == 1001) {
        url = [delegate config].registrationURL;
    } else if (btnTapped.tag == 1002) {
        url = [delegate config].forgotPasswordURL;
    } 
    
    NSURL* nsUrl = [NSURL URLWithString:url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [webView loadRequest:request];
    
    [webView sizeToFit];
    
    [webView addSubview:webSpinner];
    [self.view addSubview:webView];
    [self.view addSubview:webViewCloseBtn];
}

 
- (IBAction)forgotPassword:(id)sender {
}

- (void) closeSettingWebView
{
    [webView removeFromSuperview];
    [webViewCloseBtn removeFromSuperview];
    
    webView = nil;
    webViewCloseBtn = nil;
}

- (IBAction)hideKeyboard:(id)sender{
    [passwordEntry resignFirstResponder];
    [userNameEntry resignFirstResponder];
}

- (IBAction)passwordEditingDidBegin:(id)sender{
    if (![[[self view]window]isKeyWindow]) {
        [[[self view] window] makeKeyAndVisible];
    }
    [passwordEntry setText:@""];
}

#pragma mark ROTATION DELEGATE
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    TheTimesAppDelegate *appD = [UIApplication sharedApplication].delegate;
    [appD.bookShelfVC willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
 
    [passwordEntry resignFirstResponder];
    [userNameEntry resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
