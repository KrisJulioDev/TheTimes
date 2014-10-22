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

@interface RDPDFViewController ()

@end


@implementation RDPDFViewController

@synthesize pageNumLabel;
@synthesize pagenow;
@synthesize pagecount;

#pragma mark VIEWDIDLOAD
- (void) viewDidLoad
{
   //ADD THUMB NAVIGATION
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
    HeaderView *headerView = [topLevelObjects objectAtIndex:0];
    
    [self.view addSubview:headerView];
}

#pragma mark DELEGATE METHODS
- (void)OnPageChanged :(int)pageno{
    
    [m_Thumbview vGoto:pageno];
    
    pageno++;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pageno];
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
}

- (void)OnLongPressed:(float)x :(float)y{}
- (void)OnSingleTapped:(float)x :(float)y :(NSString *)text{}
- (void)OnTouchDown: (float)x :(float)y{}
- (void)OnTouchUp:(float)x :(float)y{}
- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2{}
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
        float height = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = height;
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
    if ( boundsc.size.width < boundsc.size.height) {
        float height = boundsc.size.height;
        boundsc.size.height = boundsc.size.width;
        boundsc.size.width = height;
    }
    
    int cwidth = boundsc.size.width;
    int cheight = boundsc.size.height;
    
    float hi            = self.navigationController.navigationBar.bounds.size.height;
    float thumbHeight   = [self isPortrait] ? -100 : 150;
    
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    
    if([[iosversion substringToIndex:1] isEqualToString:@"7"])
    {
        m_Thumbview = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight - thumbHeight, cwidth, 100)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
        
    } else {
        m_Thumbview = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 100)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 65, 30)];
    }
    
    
    [m_Thumbview vOpenThumb:m_doc];
    //[m_Thumbview setFrame:CGRectMake(0, boundsc.size.height - 150, cwidth, 100)];
    [m_Thumbview sizeThatFits:CGRectMake(0, cheight-50, cwidth, 100).size];
    
    m_Thumbview.backgroundColor = [UIColor clearColor];
    
    //ADD ThumbView on PDFREADER Screen
    [self.view addSubview:m_Thumbview];
    [m_Thumbview setHidden:YES];
    
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagecount];
    pagenow = pageno;
    
    pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    
    pageNumLabel.textColor = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    [pageNumLabel setTextAlignment:NSTextAlignmentCenter];
    pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius = 10;
    pagestr = [pagestr stringByAppendingFormat:@"%d",pagecount];
    pageNumLabel.text = pagestr;
    pageNumLabel.font = [UIFont boldSystemFontOfSize:16];
    pageNumLabel.shadowColor = [UIColor grayColor];
    pageNumLabel.shadowOffset = CGSizeMake(1.0,1.0);
    [self.view addSubview:pageNumLabel];
    //pageNumLabel.setNeedsDisplay;
    [m_Thumbview vSetDelegate:self];
    [pageNumLabel setHidden:NO];
}

-(void)PDFVThumbOnPageClicked:(int)pageno
{
    [m_view vGoto:pageno];
}

-(void)PDFVGotoSection:(int)sectionpage
{
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

#pragma mark BOTTOM NAVIGATION CALLBACKS
- (IBAction) quickNavPressed {
    [m_Thumbview setHidden:!m_Thumbview.isHidden];
}

- (IBAction) showSection:(id)sender
{
    //[self removeFromParentViewController];
    
    SectionPopUpVC *spu                 = [[SectionPopUpVC alloc] initWithNibName:@"SectionPopUpVC" bundle:nil];
    spu.rdDelegate                      = self;
    spu.modalPresentationStyle          = UIModalPresentationCustom;
    spu.view.backgroundColor            = [UIColor clearColor];
    spu.view.superview.backgroundColor  = [UIColor clearColor];
    spu.transitioningDelegate = self;
    
    spu.edition = _pageEdition;
    
    [self presentViewController:spu animated:YES completion:nil];
}

#pragma TRANSITIONING DELEGATES
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
    semiModalAnimatedTransition.presenting = YES;
    return semiModalAnimatedTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
    return semiModalAnimatedTransition;
}

#pragma mark ROTATE METHOD
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = [[UIScreen mainScreen]bounds];
    float h     = self.navigationController.navigationBar.bounds.size.height;
    int cwidth  = rect.size.width;
    int cheight = rect.size.height;
    
    if ([self isPortrait])
    {
        float height = rect.size.height - 20 - h;
        rect.size.height = height;
        rect.size.width = rect.size.width;
    }
    else
    {
        float height = rect.size.height;
        
        cwidth = cheight;
        cheight = rect.size.width;
        
        rect.size.height = rect.size.width - 20 - h;
        rect.size.width = height;
    }
    
    [m_view setFrame:rect];
    [m_view sizeThatFits:rect.size];
    //[self.toolBar sizeToFit];
    
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    if([[iosversion substringToIndex:1] isEqualToString:@"7"])
    {
        [m_Thumbview setFrame:CGRectMake(0, rect.size.height - 100, cwidth, 100)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-50, cwidth, 100).size];
        //[m_searchBar setFrame:CGRectMake(0,hi+20,cwidth,41)];
    }
    else
    {
        [m_Thumbview setFrame:CGRectMake(0, cheight-h-50-20, cwidth, 50)];
        [m_Thumbview sizeThatFits:CGRectMake(0, cheight-h-50-20, cwidth, 50).size];
        //[m_searchBar setFrame:CGRectMake(0, 0, cwidth, 41)];
    }
    [m_Thumbview refresh];
}

- (BOOL)isPortrait
{
    return ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown);
}

@end
