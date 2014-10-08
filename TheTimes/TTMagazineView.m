 //
//  TTMagazineView.m
//  TheTimes
//
//  Created by KrisMraz on 9/1/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "TTMagazineView.h"
#import "TTEditionManager.h"
#import "TheTimesAppDelegate.h"
#import "UserInterfaceUtils.h"
#import "SPDownloader.h"
#import "SPUnzipper.h"
#import "JSONKit.h"
#import "UIImageView+AFNetworking.h"

@implementation TTMagazineView

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"TTMagazineView" bundle:nil];
    TTMagazineView *magazineView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    self.backgroundColor = [UIColor clearColor];
    
    magazineView.frame = frame; 
    
    _iv_frontPage.frame = [magazineView bounds];
    _viewButton.frame = [magazineView bounds];
    _downloadButton.frame = [magazineView bounds];
    
    _iv_frontPage.layer.masksToBounds = NO;
    _iv_frontPage.layer.cornerRadius = 8;
    _iv_frontPage.layer.shadowOffset = CGSizeMake(5, 5);
    _iv_frontPage.layer.shadowRadius = 15;
    _iv_frontPage.layer.shadowOpacity = 0.7;
    _iv_frontPage.layer.shadowPath = [UIBezierPath bezierPathWithRect:_iv_frontPage.bounds].CGPath;
    
    [_progressView setProgressImage:[[UIImage imageNamed:@"downloadbar_Top.png"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
    [_progressView setTrackImage:[[UIImage imageNamed:@"downloadbar_Base.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] ];
    [_progressView setProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0,0,124,10);
    _progressView.tintColor = [UIColor clearColor];
    
    _downloadingView.center = _iv_frontPage.center;
    _textLabel.center       = _iv_frontPage.center;
    _textLabel2.center      = _iv_frontPage.center;
    
    [UserInterfaceUtils setY:magazineView.frame.size.height+5  forView:_textLabel];
    [UserInterfaceUtils setY:magazineView.frame.size.height+25 forView:_textLabel2];
    
    [self setupCustomProgress];
      
    return magazineView;
}

- (void) setupCustomProgress
{
    //Style the progress to match the designs.
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
}

static NSDateFormatter *dateFormatter;
static NSDateFormatter *dayFormatter;

/** SETUP MAGAZINE VIEW DATA**/
- (void) setUpMagazine: (Edition*) newEdition
{
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    }
    if (dayFormatter == nil)
    {
        dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"EEEE"];
    }
    
    self.edition = newEdition;
    _textLabel.text = [dayFormatter stringFromDate:_edition.date];
    _textLabel2.text = [dateFormatter stringFromDate:_edition.date];
 
    [self setThumbImageFromURL];
    
    _viewButton.hidden = YES;
    if ([[TTEditionManager sharedInstance] downloadedEdition:_edition])
    {
        //Already downloaded
        _viewButton.hidden = NO;
        _iv_frontPage.alpha = 1.0;
        _downloadButton.hidden = YES;
        _cornerImage.hidden = YES;
        _downloadingView.hidden = YES;
        _buyButton.hidden = YES;
    }
    else
    {
        _iv_frontPage.alpha = 0.5;
        if ([[SPDownloader mySPDownloader] isDownloading] && [[SPDownloader mySPDownloader].myURL isEqualToString:_edition.paperUrl])
        {
            //Currently downloading
            _viewButton.hidden = NO;
            [SPDownloader mySPDownloader].delegate = self;
            _downloadingView.hidden = NO;
            _downloadButton.hidden = YES;
            _cornerImage.hidden = YES;
        }
        else
        {
            //Not downloading or downloaded
            _progressView.progress = 0;
            [self setProgress:0];
            _downloadingView.hidden = YES;
            _downloadButton.hidden = NO;
            _cornerImage.hidden = NO;
            _buyButton.hidden = YES;
        }
    }
}

- ( void ) setThumbImageFromURL
{
    NSString *contentType = [NSString stringWithFormat:@"application/jpeg;"];
    
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:_edition.paperThumb]];
    [request setHTTPMethod:@"GET"];
    
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setTimeoutInterval:10.0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [request setValue:contentType forHTTPHeaderField: @"content-Type"];
    [request setValue:contentType forHTTPHeaderField:@"mime-Type"];
    [request setValue:[NSString stringWithFormat:@"%@",[defaults valueForKey:@"token"]] forHTTPHeaderField: @"ACS-Auth-TokenId"];
    [_iv_frontPage setImageWithURLRequest:request
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      [_iv_frontPage setImage:image];
                                  }
     
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      UIImage *paperErrorImage;
                                      
                                      paperErrorImage = [UIImage imageNamed:@"paper-default.jpg"];
                                      [_iv_frontPage setImage:paperErrorImage];
                                  }];
}

- (void) setProgress:(float)newProgress
{
    _progressTop.frame = CGRectMake(_progressBottom.frame.origin.x, _progressBottom.frame.origin.y, _progressBottom.frame.size.width*newProgress, _progressBottom.frame.size.height);
}

- (IBAction) viewEdition
{
    Edition *downloadedEdition = [[TTEditionManager sharedInstance] getDownloadedEdition:_edition];
    if (downloadedEdition != nil)
    {
        TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
        [trackingDict setObject:@"navigation" forKey:@"event_navigation_action"];
        [trackingDict setObject:@"click" forKey:@"event_navigation_browsing_method"];
        [trackingDict setObject:[NSString stringWithFormat:@"sun edition:open:%@", [_edition getTrackingDateString]] forKey:@"event_navigation_name"];
        /*
        EditionViewController *editionViewController = [[EditionViewController alloc] init];
        editionViewController.edition = downloadedEdition;
        [appDelegate.navigationController pushViewController:editionViewController animated:YES]; */
        
    }
    else if ([[SPDownloader mySPDownloader] isDownloading] && [[SPDownloader mySPDownloader].myURL isEqualToString:_edition.paperUrl])
    {
        [[SPDownloader mySPDownloader] pauseDownload];
        
        NSString *title = NSLocalizedString(@"Download", nil);
        NSString *text = NSLocalizedString(@"DOWNLOAD_CANCELLED", nil);
        [UserInterfaceUtils showPopupWithTitle:title text:text];
        
        NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
        [trackingDict setObject:@"engagement" forKey:@"event_engagement_action"];
        [trackingDict setObject:[NSString stringWithFormat:@"sun edition:%@:download:abort", [_edition getTrackingDateString]] forKey:@"event_engagement_name"];
        [trackingDict setObject:@"click" forKey:@"event_engagement_browsing_method"];
    }
}

- (void) downloadStoppedForURL:(NSString*)url toPath:(NSString*)path file:(NSString*)fileFullPath success:(BOOL)isSuccess
{
    if (isSuccess)
    {
        NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
        [trackingDict setObject:@"download complete" forKey:@"event_download_action"];
        [trackingDict setObject:[NSString stringWithFormat:@"sun edition:%@", [_edition getTrackingDateString]] forKey:@"event_download_name"];
        
        //Unzip the file on success
        if ([[SPUnzipper mySPUnzipper] unzipFile:fileFullPath inDirectory:path])
        {
            // Parse the JSON
            NSString *jsonPath = [_edition getConfigFile];
            NSString *jsonString = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *infoDict = [jsonString objectFromJSONString];
            
            Edition *newEdition = [[Edition alloc] init];
            newEdition.region = _edition.region;
            newEdition.type = _edition.type;
            newEdition.date = _edition.date;
            newEdition.dateString = _edition.dateString;
            newEdition.paperThumb = _edition.paperThumb;
            newEdition.paperUrl = _edition.paperUrl;
            newEdition.pages = [[NSMutableArray alloc] init];
            newEdition.sections = [[NSMutableArray alloc] init];
            
            NSArray *pages = [infoDict objectForKey:@"paperPages"];
            for (NSDictionary *page in pages)
            {
                EditionPage *newPage = [[EditionPage alloc] init];
                
                newPage.relativePdfUrl = [NSString stringWithFormat:@"%@", [page objectForKey:@"pdfUrl"]];
                newPage.relativeThumbnailUrl = [NSString stringWithFormat:@"%@", [page objectForKey:@"thumbUrl"]];
                
                [newEdition.pages addObject:newPage];
            }
            
            NSArray *sections = [infoDict objectForKey:@"paperMenu"];
            for (NSDictionary *section in sections)
            {
                EditionSection *newSection = [[EditionSection alloc] init];
                newSection.name = [section objectForKey:@"title"];
                newSection.pageNumber = [[section objectForKey:@"page"] intValue];
                
                [newEdition.sections addObject:newSection];
            }
            
            // Add the edition to our cache and save
            [[TTEditionManager sharedInstance].downloadedEditions addObject:newEdition];
            [[TTEditionManager sharedInstance] snapshot];
        }
    }
    
    // Refresh our view
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bookShelfVC refreshEditionViews];
}

- (void) downloadUpdatedProgress:(NSString*)url progress:(float)progress
{
    _progressView.progress = progress;
    [self setProgress:progress];
    _downloadingLabel.text = [NSString stringWithFormat:@"Downloading... %i%%", (int)(progress*100)];
}

- (void) downloadFailed:(Edition *)edition
{
    NSString *title     = NSLocalizedString(@"Download paper", nil);
    NSString *text      = NSLocalizedString(@"DOWNLOAD_FAILED", nil);
    NSString *retry     = NSLocalizedString(@"Retry", nil);
    NSString *cancel    = NSLocalizedString(@"Cancel", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:cancel otherButtonTitles:retry, nil];
    alertView.tag = DOWNLOAD_FAILED_POPUP_TAG;
    [alertView show];
}


- (IBAction) downloadThisEdition : ( id ) sender
{
    if (![SPDownloader mySPDownloader].isDownloading)
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:@"edition download start" forKey:@"product_size"];
        [dictionary setObject:@"download" forKey:@"product_sku"];
        [dictionary setObject:_edition.dateString forKey:@"webview_url"];
        
        _progressView.progress = 0;
        _downloadingLabel.text = [NSString stringWithFormat:@"Downloading... %i%%", 0];
        
        [self setProgress:0];
        [SPDownloader mySPDownloader].delegate = self;
        [[SPDownloader mySPDownloader] startDownload:_edition];
        
        TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.bookShelfVC refreshEditionViews];
        [self trackDownload];
    }
    else
    {
        NSString *title = NSLocalizedString(@"Downloading", nil);
        NSString *text = NSLocalizedString(@"SINGLE_DOWNLOAD_MESSAGE", nil);
        [UserInterfaceUtils showPopupWithTitle:title text:text];
    }
}

- (void) trackDownload
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"download" forKey:@"event_download_action"];
    [trackingDict setObject:@"sun edition" forKey:@"event_download_type"];
    [trackingDict setObject:[NSString stringWithFormat:@"sun edition:%@", [_edition getTrackingDateString]] forKey:@"event_download_name"];
}

#pragma mark ALERT VIEW DELEGATE
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DOWNLOAD_FAILED_POPUP_TAG)
    {
        if (buttonIndex == 1)
        {
            [self downloadThisEdition:self];
        }
    }
    else if (alertView.tag == DELETE_POPUP_TAG)
    {
        if (buttonIndex == 1)
        {
           /* [[TTEditionManager sharedInstance] deleteEdition:_edition];
            TheSunAppDelegate *appDelegate = (TheSunAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.editionsViewController refreshEditionViews];
            
            NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
            [trackingDict setObject:@"navigation" forKey:@"event_navigation_action"];
            [trackingDict setObject:@"click" forKey:@"event_navigation_browsing_method"];
            [trackingDict setObject:[NSString stringWithFormat:@"sun edition:delete:%@", [_edition getTrackingDateString]] forKey:@"event_navigation_name"];
            [TrackingUtil trackEvent:@"edition delete" fromView:appDelegate.editionsViewController.view extraData:trackingDict];*/
        }
    }
}

@end
