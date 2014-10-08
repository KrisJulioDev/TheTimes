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

@interface BookShelfViewController : TheTimesBaseViewController <UIScrollViewDelegate,SPDownloaderDelegate>
{ 
    NSMutableString *m_pdfName;
    NSMutableString *m_pdfPath;
    NSString        *m_pdfFullPath;
    
	NSMutableData *receivedData;
    
    BOOL showingInfo;
    NSString *lastRegionSelected;
}

@property (nonatomic, retain) NSMutableArray        *portraitEditionViews;
@property (nonatomic, retain) NSMutableArray        *landscapeEditionViews;
@property (weak, nonatomic) IBOutlet UIScrollView   *sv_portraitScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView   *sv_landscapeScrollView;

@property (weak, nonatomic) IBOutlet UIView *m_landscapeView;
@property (weak, nonatomic) IBOutlet UIView *m_portraitView;

- (void) displayBooks;
- (void) refreshEditionViews;

@end
