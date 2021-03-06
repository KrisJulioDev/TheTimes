//
//  TheTimesFirstViewController.m
//  TheTimes
//
//  Created by KrisMraz on 8/20/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TheTimesFirstViewController.h"
#import "RDPDFViewController.h"

@interface TheTimesFirstViewController ()

@end

@implementation TheTimesFirstViewController

NSMutableString *pdfName;
NSMutableString *pdfPath;
NSString *pdfFullPath;
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
NSUserDefaults *userDefaults;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
}
 
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

- (IBAction) openPDF:(id)sender
{
    int pdf_tag = [(UIButton*)sender tag];
    
    [self loadSettingsWithDefaults];
    RDPDFViewController *m_pdf;
    if( m_pdf == nil )
    {
        m_pdf = [[RDPDFViewController alloc] initWithNibName:@"RDPDFViewController"bundle:nil];
    }
    
    pdfName = [NSMutableString stringWithFormat:@"pdf_%i" , pdf_tag];
    
    pdfFullPath = [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"];
    
    int result = [m_pdf PDFOpen:pdfFullPath withPassword:@""];
    if(result == 1)
    {
        m_pdf.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:m_pdf animated:YES];
        
        int pageNo = 1;
        [m_pdf PDFThumbNailinit:pageNo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
