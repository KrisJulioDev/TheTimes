
//
//  BookShelfViewController.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//


#import "BookShelfViewController.h"
#import "TheTimesAppDelegate.h"
#import "RDPDFViewController.h"
#import "Constants.h"
#import "TTEditionManager.h"
#import "TTWebService.h"
#import "TTMagazineView.h"
#import "Edition.h"
#import "SubscriptionHandler.h"
#import "SPDownloader.h"
#import "SettingsTableViewController.h"
#import "TheTimesAppDelegate.h"
#import "configOptions.h"
#import "ConfigHudson.h"

#import "NI_reachabilityService.h"
#import "trackingClass.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "CJSONDeserializer.h"
#import "TrackingUtil.h"
#import "IGCache.h"
#import "NSDate+NIMisc.h"
#import "HelperUtility.h"

@interface BookShelfViewController ()

@end

@implementation BookShelfViewController 
{
	NSString *parsingError;
	NSManagedObjectContext *context;
	NSURLConnection *myConnection;
    
	NSMutableArray *papersArray;
	NSMutableArray *dummyPapersArray;
    
    UIView *activityIndicatorView;
    
    /** Extraction Objects */
	UIActivityIndicatorView *activityIndicator;
    UIActivityIndicatorView *extractionIndicator;
    UIView *indicatorBg;
    UILabel *extractionLabel;
    
	BOOL hasDownloadedJSON;
	NSTimer *globalJSONTimer;
    id<GAITracker> appTracker;
    
    SettingsTableViewController *settingsVC;
}

//------------------------------------------------------------
#pragma mark RADAEE PROPERTIES
//------------------------------------------------------------
NSMutableString *pdfName;
NSMutableString *pdfPath;
NSString *pdfFullPath;
NSUserDefaults *userDefaults;

int g_PDF_ViewMode = 0 ;
float g_Ink_Width = 2.0f;
float g_rect_Width = 2.0f;
float g_swipe_speed = 0.5f;
float g_swipe_distance=5.0f;
int g_render_quality = 1;
bool g_CaseSensitive = false;
bool g_MatchWholeWord = false;
bool g_DarkMode     = false;
bool g_sel_right    = false;
bool g_ScreenAwake  = false;
uint g_ink_color    = 0xFF000000;
uint g_rect_color   = 0xFF000000;

static NSDateFormatter *dateFormatter;

static int landscapePaperWidth = 675/2;
static int landscapePaperHeight = 871/2;
static int landscapeGap = 42;
static int landscapeVGap = 99;

static int portraitPaperWidth = 374/2;
static int portraitPaperHeight = 480/2;
static int portraitVGap = 70;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Set Global Reference for this Class */
    TheTimesAppDelegate *appDel = (TheTimesAppDelegate*)[UIApplication sharedApplication].delegate;
    appDel.bookShelfVC = self;
    
    /* Set region to Ireland since i dont know the default region, this doesnt cause anything on the app, just default value */
    [[NSUserDefaults standardUserDefaults] setObject:REGION_IRELAND forKey:PAPER_REGION_KEY];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^ {
        [self fetchTimesData];
    });
    
    
    /* initializer RADAEE Configurations */
    [self loadSettingsWithDefaults];
} 

- (void) viewDidAppear:(BOOL)animated
{
    
    /* call method to fix UI elements */
    /*[self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    
    if(![NI_reachabilityService isNetworkAvailable] || [NI_reachabilityService isNetworkAvailable] == NO) {
         [_splashScreen removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^ {
        [self fetchTimesData];
    });
    
    [self.view setNeedsDisplay];
    */
    
    blackScreen = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [blackScreen setBackgroundColor:[UIColor blackColor]];
    [blackScreen.layer setOpacity:0.6f ];
    [blackScreen setHidden:YES];
    
    [self.view addSubview:blackScreen];
    
}

/**
 *  Called once app open.
 */
- (void) fetchTimesData
{
    /* 
     * Check for network, if there isn't get the last saved username and password to access the app offline
     * else if there is connection check the subscription if isn't expired yet, show login otherwise
     */
    if(![NI_reachabilityService isNetworkAvailable] || [NI_reachabilityService isNetworkAvailable] == NO){
        NSString *userName = [SubscriptionHandler returnUserName];
        NSString *password = [SubscriptionHandler returnPassword];
        
        if(userName.length>0 && password.length>0){
            dispatch_async(dispatch_get_main_queue(), ^{
                                [self displayMagazines];

            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showLoginScreen];
            });
        }
    }else{
        
        NSString *userName = [SubscriptionHandler returnUserName];
        NSString *password = [SubscriptionHandler returnPassword];
        
        if(!STORE_USER_DETAILS){
            [SubscriptionHandler storeUserDetails:@"" password:@""];
        }
        if(userName.length>0 && password.length >0){
            __block bool subsCheck;
            
            subsCheck= [SubscriptionHandler checkLoginValid:userName password:password];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^ {
                if(subsCheck){ 
                    
                    /*
                     * If connected Online, delete the previous editions 7days older
                     */
                    [IGCache deleteCacheFilesOlderThan:[[NSDate date] dateByAddingDays:(kDeleteCacheFilesAfter * -1)]];
                    [self displayMagazines];
                    
                }
                else{
                    [self showLoginScreen];
                }

            });
        } else
        {
            [self showLoginScreen];
        }
    }
}


/* Display thumbnails of magazines and default image if thumbnail failed to load */
- (void) displayMagazines
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("loadEditionQueue", 0);
    
    dispatch_async(backgroundQueue, ^{
        
            [self loadEditionPapers];
            //[self refreshEditionViews];
            
            [_splashScreen removeFromSuperview];
    });
}

/* INITIALIZE RADAE SETTINGS */
- (void) loadSettingsWithDefaults
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    g_CaseSensitive = [userDefaults boolForKey:@"CaseSensitive"];
    g_MatchWholeWord = [userDefaults boolForKey:@"MatchWholeWord"];
    g_ScreenAwake = [userDefaults boolForKey:@"KeepScreenAwake"];
    [[UIApplication sharedApplication] setIdleTimerDisabled:g_ScreenAwake];
    g_MatchWholeWord = [userDefaults floatForKey:@"MatchWholeWord"];
    g_CaseSensitive = [userDefaults floatForKey:@"CaseSensitive"];
    userDefaults = [NSUserDefaults standardUserDefaults];
    g_render_quality = [userDefaults integerForKey:@"RenderQuality"];
    if(g_render_quality == 0)
    {
        g_render_quality =1;
    }
    renderQuality = g_render_quality;
    defView = [userDefaults integerForKey:@"ViewMode"];
    g_ink_color = [userDefaults integerForKey:@"InkColor"];
    if(g_ink_color ==0)
    {
        g_ink_color =0xFF000000;
    }
    g_rect_color = [userDefaults integerForKey:@"RectColor"];
    if(g_rect_color==0)
    {
        g_rect_color =0xFF000000;
    }
    annotUnderlineColor = [userDefaults integerForKey:@"UnderlineColor"];
    if (annotUnderlineColor == 0) {
        annotUnderlineColor = 0xFF000000;
    }
    annotStrikeoutColor = [userDefaults integerForKey:@"StrikeoutColor"];
    if (annotStrikeoutColor == 0) {
        annotStrikeoutColor = 0xFF000000;
    }
    annotHighlightColor = [userDefaults integerForKey:@"HighlightColor"];
    if(annotHighlightColor ==0)
    {
        annotHighlightColor =0xFFFFFF00;
    }
    
    if (!appTracker) {
        appTracker = [HelperUtility trackingClass];
    }
    
    [paperBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [paperBtn.layer setBorderWidth:2];
}

// download latest automatically.
- (void) downloadLatest
{
    Edition *latest = [[TTEditionManager sharedInstance].LatestEditions objectAtIndex:0];
    
     if ( latest != nil )
    {
        Edition *downloadedLatest = [[TTEditionManager sharedInstance] getDownloadedEdition:latest];
        if (downloadedLatest == nil && ![SPDownloader mySPDownloader].isDownloading)
        {
            [[SPDownloader mySPDownloader] startDownload:latest isAutomated:YES];
        }
    }
}

// refresh UI data of editions displayed
- (void) refreshEditionViews
{
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    [self setupInterface:[UIApplication sharedApplication].statusBarOrientation];
}

//------------------------------------------------------------
#pragma mark SHOW ALL EDITIONS AVAILABLE
//------------------------------------------------------------
- (void) setupInterface:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_landscapeEditionViews == nil)
    {
        self.landscapeEditionViews = [[NSMutableArray alloc] init];
        self.portraitEditionViews = [[NSMutableArray alloc] init];
        
        self.landscapeMagazineViews = [[NSMutableArray alloc] init];
        self.portraitMagazineViews = [[NSMutableArray alloc] init];
    }
 
    NSArray *editions = [TTEditionManager sharedInstance].LatestEditions;
    if (editions != nil)
    {
        int i = 0;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            for (Edition *edition in editions)
            {
                TTMagazineView *magazineView = nil;
                if ([_landscapeEditionViews count] > i)
                {
                    magazineView = [_landscapeEditionViews objectAtIndex:i];
                }
                else
                {
                    magazineView = [[TTMagazineView alloc] initWithFrame:CGRectMake(i*(landscapePaperWidth+landscapeGap)+landscapeGap/2, landscapeVGap, landscapePaperWidth, landscapePaperHeight)];
                }
                
                if ([_portraitEditionViews count] > 0) {
                    magazineView.magazineStatus = [(TTMagazineView*)_portraitEditionViews[i] magazineStatus];
                    [magazineView.circularProgressView setProgress: [(TTMagazineView*)_portraitEditionViews[i] circularProgressView].progress];
                }
                
                if (![_landscapeEditionViews containsObject:magazineView]) {
                    magazineView.paperNumber = i;
                    [_sv_landscapeScrollView addSubview:magazineView];
                    [self addLongPressRecogniser:magazineView];
                    [_landscapeEditionViews addObject:magazineView];
                }
                
                [magazineView setUpMagazine:edition];
                i++;
            }
            

            _sv_landscapeScrollView.contentSize = CGSizeMake((landscapePaperWidth+landscapeGap)*i+1024-landscapePaperWidth, landscapePaperHeight);
        
        }
        else
        {
            int row = 0;
            int column = 0;
            
            for (Edition *edition in editions)
            {
                
                row = i/3;
                column = i%3;
                
                int portraitHGap = (768-portraitPaperWidth*3)/4;
                
                TTMagazineView *magazineView = nil;
                if ([_portraitEditionViews count] > i)
                {
                    TTMagazineView *mag = [_portraitEditionViews objectAtIndex:i];
                    magazineView = mag;
                    magazineView.magazineStatus = mag.magazineStatus;
                }
                else
                {
                    magazineView = [[TTMagazineView alloc] initWithFrame:CGRectMake(column*(portraitPaperWidth+portraitHGap)+portraitHGap, row*(portraitPaperHeight+portraitVGap)+30, portraitPaperWidth, portraitPaperHeight)];
                }
                
                if ([_landscapeEditionViews count] > 0) {
                    magazineView.magazineStatus = [(TTMagazineView*)_landscapeEditionViews[i] magazineStatus];
                    [magazineView.circularProgressView setProgress: [(TTMagazineView*)_landscapeEditionViews[i] circularProgressView].progress];
                }
                
                if (![_portraitEditionViews containsObject:magazineView]) {
                    magazineView.paperNumber = i;
                    [_sv_portraitScrollView addSubview:magazineView];
                    [self addLongPressRecogniser:magazineView];
                    [_portraitEditionViews addObject:magazineView];
                }
                
                [magazineView setUpMagazine:edition];
                i++;
            }
            
            _sv_portraitScrollView.contentSize = CGSizeMake(768, (row+1)*(portraitPaperHeight+portraitVGap)+30);
        }
    }
}

#pragma mark OPEN SETTINGS PANEL
- (IBAction) showSettingsPanel:(id)sender
{
    if (settingsVC == nil) {
        
        settingsVC = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" bundle:nil];
        float xPos =  SCREEN_WIDTH - settingsVC.view.frame.size.width/2 - 40; //isLandscape ? rect.size.height - settingsVC.view.frame.size.width/2 - 40: rect.size.width - settingsVC.view.frame.size.width/2 - 40;
        
        [settingsVC.view setCenter:CGPointMake(xPos, settingsBtn.frame.origin.y+40 + settingsVC.view.frame.size.height/2)];
        
        [self.view addSubview:settingsVC.view];
        
        [appTracker trackEventWithCategory:@"Top menu : settings" withAction:@"navigation" withLabel:@"click" withValue:0];
    }
    else
    {
        [self closeSettingPopUP];
    }
}

/**
 *  close webview setting popup
 */
- (void) closeSettingWebView
{
    [webView removeFromSuperview];
    [webViewCloseBtn removeFromSuperview];
    [blackScreen setHidden:YES];
    
    webView = nil;
    webViewCloseBtn = nil;
}


- (void) closeSettingPopUP
{
    [settingsVC.view removeFromSuperview];
    settingsVC = nil;
}

#pragma mark SETTINGS WEBVIEW
- (void) openSettingsWebView:(NSString*)url
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float x,y, w, h, squareFrame;
    
    w = SCREEN_WIDTH * 0.8f;
    h = SCREEN_HEIGHT * 0.8f;
    x = SCREEN_WIDTH / 2 - ( w / 2);
    y = SCREEN_HEIGHT / 2 - ( h / 2 );
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    webView.layer.borderColor = [UIColor whiteColor].CGColor;
    webView.delegate = self;
    webView.layer.cornerRadius = 5;
    
    //add close btn
    webViewCloseBtn = [[UIButton alloc] init];
    squareFrame = 40;
    [webViewCloseBtn setFrame:CGRectMake(x + w - squareFrame / 2, y - squareFrame / 2, squareFrame, squareFrame)];
    [webViewCloseBtn setImage:[UIImage imageNamed:@"btn_Delete_Pressed"] forState:UIControlStateNormal];
    [webViewCloseBtn addTarget:self action:@selector(closeSettingWebView) forControlEvents:UIControlEventTouchUpInside];
    
    webSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(webView.frame.size.width/2 - 25, webView.frame.size.height/2 - 25, 50, 50)];
    webSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [webSpinner setColor:[UIColor grayColor]];
    webSpinner.hidesWhenStopped = YES;
    [webSpinner stopAnimating];
    
    NSURL* nsUrl = [NSURL URLWithString:url];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [webView loadRequest:request];
    
    [webView sizeToFit];
    
    [blackScreen setHidden:NO];
    
    [self.view addSubview:blackScreen];
    
    [webView addSubview:webSpinner];
    [self.view addSubview:webView];
    [self.view addSubview:webViewCloseBtn];
}

//------------------------------------------------------------
#pragma mark WEBVIEW DELEGATE METHODS
//------------------------------------------------------------
- (void) webViewDidStartLoad:(UIWebView *)webView{
    [webSpinner startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [webSpinner stopAnimating];
}

//------------------------------------------------------------
#pragma mark LOAD EDITIONS
//------------------------------------------------------------
- (void)loadEditionPapers {
    dispatch_queue_t downloadQueue = dispatch_queue_create("tracking", NULL);
    dispatch_async(downloadQueue, ^{
        
        parsingError=@"NO";
        [SPDownloader mySPDownloader].delegate = self;
        context = [(TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        TheTimesAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSString *stringPathURL =  delegate.config.getFeed.url; //kWebServicePath;//
        
        if ( [NI_reachabilityService isNetworkAvailable]) {
            
            @try {
                NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
                [request setURL:[NSURL URLWithString:stringPathURL]];
                [request setHTTPMethod:@"GET"];
                
                [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
                [request setTimeoutInterval:5.0];
                
                NSString *contentType = [NSString stringWithFormat:@"application/json;"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [request setValue:contentType forHTTPHeaderField: @"content-Type"];
                [request setValue:contentType forHTTPHeaderField:@"mime-Type"];
                [request setValue:[NSString stringWithFormat:@"%@",[defaults valueForKey:@"token"]] forHTTPHeaderField: @"ACS-Auth-TokenId"];
                [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                });
                hasDownloadedJSON = NO;
                globalJSONTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkIfJSONDownloaded) userInfo:nil repeats:NO];
 
            }
            @catch (NSException *exception) {
                NSLog(@"Error On Getting Json data");
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[buildingView setHidden:YES];
            });
            if (!papersArray) {
                NSDictionary *jsonDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON];
                if (jsonDic) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self createPapersArrayFromJsonDic:jsonDic];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"Oops! Your device is offline and you have no available editions. Please connect to the internet E001"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        
                        [appTracker sendEventWithCategory:@"Error Event" withAction:@"E001" withLabel:@"Error" withValue:0];
                        [alert show];
                    });
                }
            }
        }
    });
}


//------------------------------------------------------------
#pragma mark METHOD CALLED when JSON data is already downloaded
//------------------------------------------------------------
- (void)checkIfJSONDownloaded {
    if (globalJSONTimer != nil) {
        [globalJSONTimer invalidate];
        globalJSONTimer = nil;
    }
    
    [myConnection cancel];
    
	if (!hasDownloadedJSON) {
		if (!papersArray) {
			NSDictionary *jsonDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON];
			if (jsonDic) {
				// we kill the connection and get the JSON from the cache
				[self createPapersArrayFromJsonDic:jsonDic];
			}
			else if(![parsingError isEqualToString:@"YES"]){
                
                [appTracker sendEventWithCategory:@"Error Event" withAction:@"E002" withLabel:@"Error" withValue:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"Sorry, it looks like we have a system issue. Please try again later E002"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
			}
		}
	}
}


- (void)refreshPapers {
    [self performSelector:@selector(refreshPapers) withObject:nil afterDelay:3600];
    [self loadEditionPapers];
    
}

#pragma mark -
#pragma mark NSURLConnection interface
#pragma mark -
-(void) connection:(NSURLConnection *) connection didReceiveResponse: (NSURLResponse *)response {
    
    // cast the response to NSHTTPURLResponse so we can look for 404 etc
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] >= 400) {
        // do error handling here
        NSLog(@"remote url returned error %d %@",[httpResponse statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
        @try{
            
        }
        @catch (NSError *err) {
            NSLog(@"Failed to hide building screen");
        }
    }
	receivedData = [[NSMutableData alloc] initWithLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
	[receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
	// we convert the total data we received into a string
	NSString *jsonString = [[ NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] ;

    NSError *error = nil;
        @try{
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        NSDictionary *papersDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
        if ([[papersDictionary objectForKey:availablePapersKey] count]>0) {
            //NSLog([papersDictionary description]);
            // caching global.json
            [[NSUserDefaults standardUserDefaults] setObject:papersDictionary forKey:kCachedGlobalJSON];
            
            if (error == nil) {
                hasDownloadedJSON = YES;
                [self createPapersArrayFromJsonDic:papersDictionary];
             }
        }
        else{
            parsingError = @"YES";
            if (!papersArray && [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON]) {
                NSDictionary *jsonDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON];
                [self createPapersArrayFromJsonDic:jsonDic];
             }
            else if(!papersArray){
                [appTracker sendEventWithCategory:@"Error Event" withAction:@"E007" withLabel:@"Error" withValue:0];
                NSString *errorMessage = [NSString stringWithFormat:@"Sorry, The edition is not available at present. Please try again later E007"];
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                                message:errorMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Retry" otherButtonTitles:nil];
                alert.tag = 15;
                [alert show];
            }
        }
    }
    @catch (NSException *ex) {
        [appTracker sendEventWithCategory:@"Error Event" withAction:@"E009" withLabel:@"Error" withValue:0];
        NSString *errorMessage = [NSString stringWithFormat:@"Sorry, it looks like we have a system issue. Please try again later E009"];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                        message:errorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Retry" otherButtonTitles:nil];
        alert.tag = 15;
        [alert show];
    }
}

/**
 *  Extract information from downloaded editions
 */
- (void)createPapersArrayFromJsonDic:(NSDictionary*)jsonDic
{
	NSArray *availablePapers = [NSArray arrayWithArray:[jsonDic objectForKey:availablePapersKey]];
    [TTWebService sharedInstance].paper_editions = availablePapers;
    [[TTEditionManager sharedInstance] updateEditions];
    
    [self.barrier setHidden:YES];
    
	NSMutableArray* mutablePapers = [NSMutableArray arrayWithCapacity:50];
	for(NSDictionary* dicPaper in availablePapers)
	{
		NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:dicPaper];
		[mutablePapers addObject:dic];
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSLog(@"Connection failed %@",[error localizedDescription]);
	
	// getting the cached global JSON
	if (!papersArray && [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON]) {
		NSDictionary *jsonDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedGlobalJSON];
		[self createPapersArrayFromJsonDic:jsonDic];
	}
    
    else if(!papersArray){
        parsingError =@"YES";
        [self.barrier setHidden:YES];
        
        [appTracker sendEventWithCategory:@"Error Event" withAction:@"E006" withLabel:@"Error" withValue:0];
        NSString *errorMessage = [NSString stringWithFormat:@"Please Check your internet connection and try again E006"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                        message:errorMessage
                                                       delegate:self cancelButtonTitle:@"Retry"otherButtonTitles:nil];
        alert.tag = 15;
        [alert show];

    }
}

#pragma mark ALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if (alertView.tag == 4) {
        if(buttonIndex==1){
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
		
	}
    else if (alertView.tag == 15) {
        [self performSelector:@selector(refreshPapers) withObject:nil afterDelay:5];
		
	}

}


#pragma mark SHOW LOGIN SCREEN IF NO USER LOGGED
- (void) showLoginScreen
{
    [self performSegueWithIdentifier:TO_LOGIN_SEGUE sender:self];
}



//------------------------------------------------------------
#pragma mark ADD LONG PRESS GESTURE
//------------------------------------------------------------
- (void) addLongPressRecogniser:(UIView *)thisView
{
    UILongPressGestureRecognizer *gestureLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [thisView addGestureRecognizer:gestureLong];
}

// Start deleting on long presses.
- (IBAction)handleLongPress:(UIGestureRecognizer *)sender
{
    // Start / stop delete papers view
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.isDeleting = !_isDeleting;
        portraitDoneButton.hidden = !_isDeleting;
        landscapeDoneButton.hidden = !_isDeleting;
        [self refreshEditionViews];
        
        NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
        [trackingDict setObject:@"navigation" forKey:@"event_navigation_action"];
        [trackingDict setObject:@"click" forKey:@"event_navigation_browsing_method"];
        if (_isDeleting)
        {
            [trackingDict setObject:@"delete mode:enable" forKey:@"event_navigation_name"];
            [TrackingUtil trackEvent:@"delete mode:enable" fromView:self.view extraData:trackingDict];
        }
        else
        {
            [trackingDict setObject:@"delete mode:disable" forKey:@"event_navigation_name"];
            [TrackingUtil trackEvent:@"delete mode:disable" fromView:self.view extraData:trackingDict];
        }
    }
}

#pragma mark OPEN PDF CALLBACKS
/**
 *  Open PDF from edition parameter directory
 *
 *  @param edition Edition
 */
- (void) openPDF:(Edition*)edition
{
    [self loadSettingsWithDefaults];
    [self closeSettingPopUP];
    
    RDPDFViewController *pdf; 
    if( pdf == nil )
    {
        pdf = [[RDPDFViewController alloc] initWithNibName:@"RDPDFViewController"bundle:nil];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/mergepdf/pdf/%@",[paths objectAtIndex:0], edition.dateString];
    
    pdf.pageEdition = edition;
    m_pdfName       = edition.paperUrl;
    m_pdfFullPath   = layOutPath;
    
    int result = [pdf PDFOpen:m_pdfFullPath withPassword:@""];
    if(result == 1)
    {
        pdf.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdf animated:YES];
        
        int pageNo = 1;
        [pdf PDFThumbNailinit:pageNo];
    }
    
    //TRACKED EDITION OPENED with Label as date of the edition
    [appTracker sendEventWithCategory:@"Edition Opened" withAction:@"PDF_OPEN" withLabel:edition.dateString withValue:0];
}

//------------------------------------------------------------
#pragma mark SCROLL VIEW DELEGATES
//------------------------------------------------------------
static int pageWidth = 675/2+42;
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  [self lockScrollView:scrollView];
}


- (void) lockScrollView:(UIScrollView *)scrollView
{
    int x = scrollView.contentOffset.x;
    int xOff = x % pageWidth;
    if(xOff < pageWidth/2)
        x -= xOff;
    else
        x += pageWidth - xOff;
    
    [scrollView setContentOffset:CGPointMake(x, scrollView.contentOffset.y) animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self lockScrollView:scrollView];
}

/**
 *  Set stop state for all magazines, horizontal and vertical arrays
 *  Reset progress to 0
 */
- (void) stopAllMagazineDownload
{
    for (TTMagazineView *mag in self.landscapeEditionViews) {
        mag.magazineStatus = stopped;
        [mag.circularProgressView setProgress:0];
    }
    
    for (TTMagazineView *mag in self.portraitEditionViews) {
        mag.magazineStatus = stopped;
        [mag.circularProgressView setProgress:0];
    }
}

/* We have 2 arrays of TTMagazineView
 * Landscape and Portrait array 
 * So we need to change magazineStatus for both Containers
 */
- (void) changeStatusForMagazine:(TTMagazineView*)magz : (enum Status ) status
{
    
    for (TTMagazineView *mag in self.landscapeEditionViews) {
        
        if (magz.edition.dateString == mag.edition.dateString) {
            mag.magazineStatus = status;
        }
    }
    
    for (TTMagazineView *mag in self.portraitEditionViews) {
        if (magz.edition.dateString == mag.edition.dateString) {
            mag.magazineStatus = status;
        }
    }
    
    [self refreshEditionViews];
}

/* Check if isPortrait orientation */
- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) extractionOnProcess:(UIView*)sender extracting:(BOOL) isExtracting
{
    if ( extractionIndicator == nil) {
        indicatorBg = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 60,
                                                              SCREEN_HEIGHT/2 - 60,
                                                              120,
                                                              120)];
        [indicatorBg.layer setBorderWidth:3];
        [indicatorBg.layer setCornerRadius:10];
        [indicatorBg setBackgroundColor:[UIColor blackColor]];
        [indicatorBg setAlpha:0.7f];
        
        extractionIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorBg.frame.size.width/2 - 50,
                                                                                        indicatorBg.frame.size.height/2 - 50 ,
                                                                                        100,
                                                                                        50)];
        extractionIndicator.hidesWhenStopped = YES;
        [extractionIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        extractionLabel = [[UILabel alloc] initWithFrame:CGRectMake(extractionIndicator.frame.origin.x,
                                                                    extractionIndicator.frame.origin.y + 50 ,
                                                                    100,
                                                                    50)];
        [extractionLabel setTextColor:[UIColor whiteColor]];
        [extractionLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        
        [self.view addSubview:indicatorBg];
        [indicatorBg addSubview:extractionIndicator];
        [indicatorBg addSubview:extractionLabel];
    }
    
    if (isExtracting) {
        

        [extractionIndicator startAnimating];
        [extractionLabel setText:@"Extracting..."];
        [indicatorBg setHidden:NO];
        [blackScreen setHidden:NO];
        [self.view setUserInteractionEnabled:NO];
        
        [self closeSettingWebView];
        [self.view bringSubviewToFront:blackScreen];
        [self.view bringSubviewToFront:indicatorBg];
        
    } else {
        
        [extractionIndicator stopAnimating];
        [extractionLabel setText:@""];
        [indicatorBg setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        [blackScreen setHidden:YES];
        
    }
}

//------------------------------------------------------------
#pragma mark ROTATION CALLBACKS
//------------------------------------------------------------
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.m_portraitView.hidden = YES;
        self.m_landscapeView.hidden = NO;
        //tooltipView.frame = CGRectMake(1024-495, 340, tooltipView.frame.size.width, tooltipView.frame.size.height);
        
    }
    else
    {
        self.m_portraitView.hidden = NO;
        self.m_landscapeView.hidden = YES;
        //tooltipView.frame = CGRectMake(768-495, 340, tooltipView.frame.size.width, tooltipView.frame.size.height);
        
    }
    
    [self setupInterface:toInterfaceOrientation];
    
    showingInfo = NO;
    
    if (settingsVC) {
        [settingsVC.view removeFromSuperview];
        settingsVC = nil;
    }
    
}

/* Fix Objects size and position upon rotation */
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //SET UP WEB VIEW ON CHANGE ORIENTATION
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float x,y, w, h, squareFrame;
    
    squareFrame = 50;
    
    w = SCREEN_WIDTH * 0.8f;
    h = SCREEN_HEIGHT * 0.8f;
    x = SCREEN_WIDTH / 2 - ( w / 2);
    y = SCREEN_HEIGHT / 2 - ( h / 2 );
    
    [webView setFrame:CGRectMake(x, y, w, h)];
    [webViewCloseBtn setFrame:CGRectMake(x + w - squareFrame / 2, y - squareFrame / 2, squareFrame, squareFrame)];
    [webSpinner setFrame:CGRectMake(webView.frame.size.width/2 - 25, webView.frame.size.height/2 - 25, 50, 50)];
    
    [indicatorBg setFrame:CGRectMake(SCREEN_WIDTH/2 - 60,
                                    SCREEN_HEIGHT/2 - 60,
                                    120,
                                    120)];
    
    
    
    [blackScreen setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    //portraitInfoButton.selected = NO;
    //landscapeInfoButton.selected = NO;
}

@end
