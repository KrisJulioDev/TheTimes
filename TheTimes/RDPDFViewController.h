//
//  RDPDFViewController.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFView.h"
#import "PDFIOS.h"
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

@class OutLineViewController;
@class PDFView;
@class PopupMenu;
@class PDFVThumb;
@class PDFV;
@interface RDPDFViewController : UIViewController <UISearchBarDelegate>
{
    PDFView *m_view;
    PDFDoc *m_doc;
    PDFVThumb *m_Thumbview;
    
    UIView *thumbNavigation;
}


@property (strong,nonatomic)IBOutlet UILabel *pageNumLabel;
@property (assign, nonatomic)int pagenow;
@property (assign, nonatomic)int pagecount;
@property (weak, nonatomic) IBOutlet UITextField *m_searchField;
@property (weak, nonatomic) IBOutlet UIButton *m_searchBtn;

- (int)PDFOpen:(NSString *)path withPassword:(NSString *)pwd;
- (void)PDFThumbNailinit:(int)pageno;

//END
@end
