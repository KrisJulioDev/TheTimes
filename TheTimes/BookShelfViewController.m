
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

#import "configOptions.h"
#import "ConfigHudson.h"

#import "NI_reachabilityService.h"
#import "trackingClass.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "CJSONDeserializer.h"

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
	UIActivityIndicatorView *activityIndicator;
	BOOL hasDownloadedJSON;
	NSTimer *globalJSONTimer;
}

#pragma mark RADAEE PROPERTIES
NSMutableString *pdfName;
NSMutableString *pdfPath;
NSString *pdfFullPath;
NSUserDefaults *userDefaults;

int g_PDF_ViewMode = 0 ;
float g_Ink_Width = 2.0f;
float g_rect_Width = 2.0f;
float g_swipe_speed = 0.15f;
float g_swipe_distance=1.0f;
int g_render_quality = 1;
bool g_CaseSensitive = false;
bool g_MatchWholeWord = false;
bool g_DarkMode = false;
bool g_sel_right= false;
bool g_ScreenAwake = false;
uint g_ink_color = 0xFF000000;
uint g_rect_color = 0xFF000000;

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
    
    [self loadSettingsWithDefaults];
    
    /*
    
    if (appDel.config == nil) {
     
    }*/
    
    [self showLoginScreen];
    [self loadEditionPapers];
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
}

- (void) refreshEditionViews
{
    [self setupInterface:[UIApplication sharedApplication].statusBarOrientation];
}

#pragma mark SHOW ALL EDITIONS AVAILABLE 
- (void) setupInterface:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_landscapeEditionViews == nil)
    {
        self.landscapeEditionViews = [[NSMutableArray alloc] init];
        self.portraitEditionViews = [[NSMutableArray alloc] init];
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
                magazineView.paperNumber = i;
                [_sv_landscapeScrollView addSubview:magazineView];
                //[self addLongPressRecogniser:magazineView];
                [magazineView setUpMagazine:edition];
                [_landscapeEditionViews addObject:magazineView];
                
                i++;
            }
            [_sv_landscapeScrollView setHidden:NO];
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
                    magazineView = [_portraitEditionViews objectAtIndex:i];
                }
                else
                {
                    magazineView = [[TTMagazineView alloc] initWithFrame:CGRectMake(column*(portraitPaperWidth+portraitHGap)+portraitHGap, row*(portraitPaperHeight+portraitVGap)+30, portraitPaperWidth, portraitPaperHeight)];
                }
                
                magazineView.paperNumber = i;
                [_sv_portraitScrollView addSubview:magazineView];
                //[self addLongPressRecogniser:paperView];
                [magazineView setUpMagazine:edition];
                [_portraitEditionViews addObject:magazineView];
                i++;
            }
            
            [_sv_portraitScrollView setHidden:NO];
            _sv_portraitScrollView.contentSize = CGSizeMake(768, (row+1)*(portraitPaperHeight+portraitVGap)+30);
        }
    }
}

#pragma mark LOAD EDITIONS
- (void)loadEditionPapers {
    dispatch_queue_t downloadQueue = dispatch_queue_create("tracking", NULL);
    dispatch_async(downloadQueue, ^{
        
        [SubscriptionHandler checkLoginValid];
        parsingError=@"NO";
        [SPDownloader mySPDownloader].delegate = self;
        context = [(TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        if ( [NI_reachabilityService isNetworkAvailable]) {
            
            @try {
                
                NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
                [request setURL:[NSURL URLWithString:kWebServicePath]];
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
                        //[self createPapersArrayFromJsonDic:jsonDic];
                        NSLog(@"JSON DICT %@", jsonDic);
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"Oops! Your device is offline and you have no available editions. Please connect to the internet E001"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [[[trackingClass getInstance] returnInstance] sendEventWithCategory:@"Error Event" withAction:@"E001" withLabel:@"Error" withValue:0];
                        
                        [alert show];
                    });
                }
            }
        }
    });
}

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
                
                [[[trackingClass getInstance] returnInstance] sendEventWithCategory:@"Error Event" withAction:@"E002" withLabel:@"Error" withValue:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection problem" message:@"Sorry, it looks like we have a system issue. Please try again later E002"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
			}
		}
	}
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
                [[[trackingClass getInstance] returnInstance] sendEventWithCategory:@"Error Event" withAction:@"E007" withLabel:@"Error" withValue:0];
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
        [[[trackingClass getInstance] returnInstance] sendEventWithCategory:@"Error Event" withAction:@"E009" withLabel:@"Error" withValue:0];
        NSString *errorMessage = [NSString stringWithFormat:@"Sorry, it looks like we have a system issue. Please try again later E009"];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                        message:errorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Retry" otherButtonTitles:nil];
        alert.tag = 15;
        [alert show];
    }
    // [buildingView setHidden:YES];
    
}

- (void)createPapersArrayFromJsonDic:(NSDictionary*)jsonDic
{
	NSArray *availablePapers = [NSArray arrayWithArray:[jsonDic objectForKey:availablePapersKey]];
    [TTWebService sharedInstance].paper_editions = availablePapers;
    [[TTEditionManager sharedInstance] updateEditions];
    
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
        
        [[[trackingClass getInstance] returnInstance] sendEventWithCategory:@"Error Event" withAction:@"E006" withLabel:@"Error" withValue:0];
        NSString *errorMessage = [NSString stringWithFormat:@"Please Check your internet connection and try again E006"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                        message:errorMessage
                                                       delegate:self cancelButtonTitle:@"Retry"otherButtonTitles:nil];
        alert.tag = 15;
        [alert show];

    }
}


#pragma mark SHOW LOGIN SCREEN IF NO USER LOGGED
- (void) showLoginScreen
{
    [self performSegueWithIdentifier:TO_LOGIN_SEGUE sender:self];
}


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
    //portraitInfoButton.selected = NO;
    //landscapeInfoButton.selected = NO;
}

#pragma mark OPEN PDF CALLBACKS
- (IBAction) openPDF:(id)sender
{
    int pdf_tag = [(UIButton*)sender tag];
    
    [self loadSettingsWithDefaults];
    RDPDFViewController *pdf;
    if( pdf == nil )
    {
        pdf = [[RDPDFViewController alloc] initWithNibName:@"RDPDFViewController"bundle:nil];
    }
    
    m_pdfName = [NSMutableString stringWithFormat:@"pdf_%i" , pdf_tag];
    
    m_pdfFullPath = [[NSBundle mainBundle] pathForResource:m_pdfName ofType:@"pdf"];
    
    int result = [pdf PDFOpen:m_pdfFullPath withPassword:@""];
    if(result == 1)
    {
        pdf.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdf animated:YES];
        
        int pageNo = 1;
        [pdf PDFThumbNailinit:pageNo];
    }
}

static int pageWidth = 675/2+42;
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self lockScrollView:scrollView];
}

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

@end
