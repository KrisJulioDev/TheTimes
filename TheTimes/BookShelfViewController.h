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

@interface BookShelfViewController : TheTimesBaseViewController <UIScrollViewDelegate,SPDownloaderDelegate, UIAlertViewDelegate>
{ 
    NSString *m_pdfName;
    NSString *m_pdfPath;
    NSString        *m_pdfFullPath;
    
	NSMutableData *receivedData;
    
    BOOL showingInfo;
    NSString *lastRegionSelected;
    
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

@property (atomic) BOOL isDeleting;

- (void) downloadLatest;
- (void) displayBooks;
- (void) refreshEditionViews;
- (void) openPDF:(Edition*)edition;

@end
