//
//  RDPDFViewController.m
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))


#import "RDPDFViewController.h"
#import "PDFVThumb.h"
#import "HeaderView.h" 
#import "SectionPopUpVC.h"
#import "SemiModalAnimatedTransition.h"
#import "TheTimesAppDelegate.h"
#import "Constants.h"
#import "TrackingUtil.h"

@interface RDPDFViewController ()

@property (nonatomic, strong) SectionPopUpVC *transition;

@end


@implementation RDPDFViewController
{
    float thumbHeight;
}

@synthesize pageNumLabel;
@synthesize pagenow;
@synthesize pagecount;

#pragma mark VIEWDIDLOAD
- (void) viewDidLoad
{
   //ADD THUMB NAVIGATION
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
    HeaderView *headerView   = [topLevelObjects objectAtIndex:0];
    
    
    self.transition = [SectionPopUpVC new];
    
    [self.view addSubview:headerView];
}

#pragma mark DELEGATE METHODS
- (void)OnPageChanged :(int)pageno{
    
    [m_Thumbview vGoto:pageno];
    
    pageno++;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pageno];
    pagestr           = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
}

- (void)OnLongPressed:(float)x :(float)y{}
- (void)OnSingleTapped:(float)x :(float)y :(NSString *)text{ }
- (void)OnTouchDown: (float)x :(float)y{
    [m_Thumbview setHidden:YES];
}
- (void)OnTouchUp:(float)x :(float)y{ }
- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2{ }
- (void)OnOpenURL:(NSString*)url{}
- (void)OnFound:(bool)found{}
- (void)OnMovie:(NSString *)fileName{}
- (void)OnSound:(NSString *)fileName{}

- (int)PDFOpen:(NSString *)path withPassword:(NSString *)pwd
{
    [self PDFClose];
    const char *cpath = [path UTF8String];
    PDF_ERR err = 0;
    m_doc = [[PDFDoc alloc] init];
    err = [m_doc open:path :pwd];
    
    if( m_doc == NULL )
    {
        switch( err )
        {
            case err_password:
                return 2;
                break;
            default: return 0;
        }
    }
    
    pagecount =[m_doc pageCount];
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    //GEAR
    if (![self isPortrait] && rect.size.width < rect.size.height) {
        float height     = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width  = height;
    }
    //END
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    if([iosversion integerValue]>=7)
    {
        float hi = self.navigationController.navigationBar.bounds.size.height;
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-80-hi)];
    }
    else
    {
        m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-44)];
    }
    
    m_view.edition = _pageEdition; 
    [m_view vOpen:m_doc: self];
    [self.view addSubview:m_view];
    
    return 1;
}


-(void)PDFThumbNailinit:(int)pageno
{ 
    CGRect boundsc = [[UIScreen mainScreen]bounds];
    if (![self isPortrait] && boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    float hi            = self.navigationController.navigationBar.bounds.size.height;
    thumbHeight         = 200;
    
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    
    if([[iosversion substringToIndex:1] isEqualToString:@"7"] || [[iosversion substringToIndex:1] isEqualToString:@"8"])
    {
        m_Thumbview  = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight - thumbHeight - 30, cwidth , 180)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];

    } else {
        m_Thumbview  = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 100)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 65, 30)];
    }
    
    [m_Thumbview vOpenThumb:m_doc];
    [m_Thumbview sizeThatFits:CGRectMake(0, cheight - thumbHeight, cwidth, 150).size];
    
    m_Thumbview.backgroundColor = [UIColor clearColor];
    
    //ADD ThumbView on PDFREADER Screen
    [self.view addSubview:m_Thumbview];
    [m_Thumbview setHidden:YES];
    
    NSString *pagestr                      = [[NSString alloc]initWithFormat:@"%d/",pagecount];
    pagenow                                = pageno;

    pageNumLabel.backgroundColor           = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    pageNumLabel.textColor                 = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    pageNumLabel.baselineAdjustment        = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius        = 10;
    pagestr                                = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text                      = pagestr;
    pageNumLabel.font                      = [UIFont boldSystemFontOfSize:16];
    pageNumLabel.shadowColor               = [UIColor grayColor];
    pageNumLabel.shadowOffset              = CGSizeMake(1.0,1.0);
    
    [pageNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:pageNumLabel];
    //pageNumLabel.setNeedsDisplay;
    [m_Thumbview vSetDelegate:self];
    [pageNumLabel setHidden:NO];
    
}

-(void)PDFVThumbOnPageClicked:(int)pageno
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"navigation : thumbnail"                                                       forKey:@"event_navigation_action"];
    [trackingDict setObject:@"click"                                                            forKey:@"event_navigation_browsing_method"];
    [trackingDict setObject:[NSString stringWithFormat:@"bottom nav: %i", pageno]        forKey:@"event_navigation_name"];
    
    [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
    
    [m_view vGoto:pageno];
}

-(void)PDFVGotoSection:(int)sectionpage
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"navigation"                                                       forKey:@"event_navigation_action"];
    [trackingDict setObject:@"click"                                                            forKey:@"event_navigation_browsing_method"];
    [trackingDict setObject:[NSString stringWithFormat:@"bottom nav: %i", sectionpage]        forKey:@"event_navigation_name"];
    
    [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
    
    [m_view vGoto:sectionpage];
}


-(void)PDFClose
{
    if( m_view != nil )
    {
        [m_view vClose];
        [m_view removeFromSuperview];
        m_view = NULL;
    }
    m_doc = NULL;
}

- (IBAction)backToEditions:(id)sender
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"navigation"                           forKey:@"event_navigation_action"];
    [trackingDict setObject:@"click"                                forKey:@"event_navigation_browsing_method"];
    [trackingDict setObject:@"back to edition selection"            forKey:@"event_navigation_name"];
    
    [TrackingUtil trackEvent:@"access option:sign in" fromView:self.view eventName:@"access option:sign in" eventAction:@"navigation" eventMethod:@"click" eventRegistrationAction:nil customerId:nil customerType:@"guest"];
 
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark BOTTOM NAVIGATION CALLBACKS
- (IBAction) quickNavPressed {
    [m_Thumbview setHidden:!m_Thumbview.isHidden];
}


- (IBAction) showSection:(id)sender
{
    SectionPopUpVC *spu                 = [[SectionPopUpVC alloc] initWithNibName:@"SectionPopUpVC" bundle:nil];
    spu.rdDelegate                      = self;
    spu.transitioningDelegate           = self.transition;
    spu.modalPresentationStyle          = UIModalPresentationCustom;
//    spu.view.backgroundColor            = [UIColor clearColor];
//    spu.view.superview.backgroundColor  = [UIColor clearColor];
    
    spu.edition = _pageEdition;
    
    [self presentViewController:spu animated:YES completion:nil];
} 

#pragma mark ROTATE METHOD
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
    TheTimesAppDelegate *appD = [UIApplication sharedApplication].delegate;
    [appD.bookShelfVC willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    
}
/* Fix Thumbnail and PDF View's Frame on orientation change
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    float h     = self.navigationController.navigationBar.bounds.size.height;
    int cwidth  = SCREEN_WIDTH;
    int cheight = SCREEN_HEIGHT;
    
    float height     = SCREEN_HEIGHT - 20 - h;
    rect.size.height = height;
    rect.size.width  = cwidth;
    
    [m_view setFrame:rect];
    [m_view sizeThatFits:rect.size];
    //[self.toolBar sizeToFit];
    
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    
    if([[iosversion substringToIndex:1] isEqualToString:@"7"] || [[iosversion substringToIndex:1] isEqualToString:@"8"])
    {
        [m_Thumbview setFrame:CGRectMake(0, rect.size.height - 170, cwidth, 180)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-thumbHeight, cwidth, 150).size];
        //[m_searchBar setFrame:CGRectMake(0,hi+20,cwidth,41)];
    }
    else
    {
        [m_Thumbview setFrame:CGRectMake(0, cheight-h-50-20, cwidth, 50)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-h-50-20, cwidth, 50).size];
        //[m_searchBar setFrame:CGRectMake(0, 0, cwidth, 41)];
    }
    
    [m_view vGoto:[m_view vGetCurrentPage]];
    [m_Thumbview refresh];
    
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

@end
