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
@interface RDPDFViewController ()

@end


@implementation RDPDFViewController

@synthesize pageNumLabel;
@synthesize pagenow;
@synthesize pagecount;

#pragma mark DELEGATE METHODS
- (void)OnPageChanged :(int)pageno{
    
    [m_Thumbview vGoto:pageno];
    pageno++;
    // sliderBar.value = pageno;
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
    float hi = self.navigationController.navigationBar.bounds.size.height;
    m_view = [[PDFView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-20-hi)];
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
    
    if (IS_RETINA) {
        cheight *= 1.4f;
    }
    
    float hi = self.navigationController.navigationBar.bounds.size.height;
    CGRect rect;
    rect = [[UIApplication sharedApplication] statusBarFrame];
    
    
    NSString *iosversion =[[UIDevice currentDevice]systemVersion];
    if([[iosversion substringToIndex:1] isEqualToString:@"7"])
    {
        m_Thumbview = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight-100, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20+hi+1, 65, 30)];
    }
    else{
        m_Thumbview = [[PDFVThumb alloc] initWithFrame:CGRectMake(0, cheight-hi-50-20, cwidth, 50)];
        pageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 65, 30)];
    }
    [m_Thumbview vOpenThumb:m_doc];
    //[m_Thumbview sizeThatFits:CGRectMake(0, cheight-180, cwidth, 110).size];
    [self.view addSubview:m_Thumbview];
    
    pagenow = pageno;
    
    
    pageNumLabel.backgroundColor = [UIColor colorWithRed:1.5 green:1.5 blue:1.5 alpha:0.2];
    
    pageNumLabel.textColor = [UIColor whiteColor];
    pageNumLabel.adjustsFontSizeToFitWidth = YES;
    pageNumLabel.textAlignment= UITextAlignmentCenter;
    pageNumLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pageNumLabel.layer.cornerRadius = 10;
    NSString *pagestr = [[NSString alloc]initWithFormat:@"%d/",pagecount];
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

@end