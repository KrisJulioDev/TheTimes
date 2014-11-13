//
//  BookShelfViewController.h
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheTimesBaseViewController.h"
#import "SPDownloader.h"
#import "TTMagazineView.h"

@interface BookShelfViewController : TheTimesBaseViewController <UIScrollViewDelegate,SPDownloaderDelegate, UIAlertViewDelegate, UIWebViewDelegate>
{ 
    NSString *m_pdfName;
    NSString *m_pdfPath;
    NSString        *m_pdfFullPath;
    
	NSMutableData *receivedData;
    
    BOOL showingInfo;
    NSString *lastRegionSelected;
    
    UIWebView   *webView;
    UIButton    *webViewCloseBtn;
    UIActivityIndicatorView *webSpinner;
    
    IBOutlet UIButton *portraitDoneButton;
    IBOutlet UIButton *landscapeDoneButton;
    
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *paperBtn;
}

@property (nonatomic, retain) NSMutableArray        *portraitEditionViews;
@property (nonatomic, retain) NSMutableArray        *landscapeEditionViews;

@property (nonatomic, retain) NSMutableArray        *portraitMagazineViews;
@property (nonatomic, retain) NSMutableArray        *landscapeMagazineViews;

@property (weak, nonatomic) IBOutlet UIScrollView   *sv_portraitScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView   *sv_landscapeScrollView;

@property (weak, nonatomic) IBOutlet UIView *m_landscapeView;
@property (weak, nonatomic) IBOutlet UIView *m_portraitView;
@property (strong, nonatomic) IBOutlet UIView *splashScreen;
@property (strong, nonatomic) IBOutlet UIView *barrier;


@property (atomic) BOOL isDeleting;

- (void) downloadLatest;
- (void) displayBooks;
- (void) refreshEditionViews;
- (void) openPDF:(Edition*)edition;
- (void) fetchTimesData;
- (void) closeSettingPopUP;
- (void) openSettingsWebView:(NSString*)url;
- (void) closeSettingWebView;
- (void) stopAllMagazineDownload;
- (void) showLoginScreen;
- (void) changeStatusForMagazine:(TTMagazineView*)magz : (enum Status ) status;
- (void) extractionOnProcess:(BOOL) isExtracting;
@end
