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
#import "UserInterfaceUtils.h"
#import "UIImageView+AFNetworking.h"
#import "TrackingUtil.h"
#import "HelperUtility.h"

#define DOWNLOAD_TAG 1000
#define PLAYPAUSE_TAG 1001

@implementation TTMagazineView

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"TTMagazineView" bundle:nil];
    TTMagazineView *magazineView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    self.backgroundColor = [UIColor clearColor];
    
    magazineView.frame = frame; 
    
    _iv_frontPage.frame     = [magazineView bounds];
    _viewButton.frame       = [magazineView bounds];
    _downloadButton.frame   = [magazineView bounds];
    
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
    
    [self.playPauseBtn setImage:[UIImage imageNamed:@"dl_pause"] forState:UIControlStateNormal];
    [self.playPauseBtn setImage:[UIImage imageNamed:@"dl_play"] forState:UIControlStateSelected];
    
    [self setupCustomProgress];
    
      
    return magazineView;
}

/* SETUP PROGRESS BAR */
- (void) setupCustomProgress
{
    //Style the progress to match the designs.
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
}

/* UPDATE PROGRESS BAR ON DOWNLOAD */
- (void) setProgress:(float)newProgress
{
    _progressTop.frame = CGRectMake(_progressBottom.frame.origin.x, _progressBottom.frame.origin.y, _progressBottom.frame.size.width*newProgress, _progressBottom.frame.size.height);
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
 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setThumbImageFromURL];
    });

    
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.bookShelfVC.isDeleting)
    {
        if ([[TTEditionManager sharedInstance] downloadedEdition:_edition])
        {
            [self startWobbling];
        }
        else
        {
            [self stopWobbling];
        }
    }
    else
    {
        [self stopWobbling];
    }
    
    _viewButton.hidden = YES;
    if ([[TTEditionManager sharedInstance] downloadedEdition:_edition])
    {
        //Already downloaded
        _viewButton.hidden = NO;
        _playPauseBtn.hidden = YES;
        _deleteBtn.hidden = YES;
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
            _viewButton.hidden = YES;
            _playPauseBtn.hidden = NO;
            _deleteBtn.hidden = NO;
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
            _downloadingView.hidden = magazineStatus    == paused ? NO : YES;
            _playPauseBtn.hidden    = magazineStatus    == paused ? NO : YES;
            _deleteBtn.hidden       = magazineStatus    == paused ? NO : YES;;
            _downloadButton.hidden  = magazineStatus    == stopped ? NO : YES;
            [_playPauseBtn setSelected: magazineStatus  == paused ? YES: NO ];
            _cornerImage.hidden = NO;
            _buyButton.hidden = YES;
        }
    }
}

/* FETCH AND SET THE THUMB IMAGE OF THE MAGAZINE */
- ( void ) setThumbImageFromURL
{
    NSString *contentType = [NSString stringWithFormat:@"application/jpeg;"];
    
    UIImage *paperErrorImage;
    paperErrorImage = [UIImage imageNamed:@"paper-error.jpg"];
    
    Edition *downloadedEdition = [[TTEditionManager sharedInstance] getDownloadedEdition:_edition];
   
    NSString *defaultRegion = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
    NSString *filename = [[[downloadedEdition paperUrl] lastPathComponent] stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@/Caches/papers/%@/%@/%@.jpg",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0],defaultRegion, filename, filename];
    
    if (downloadedEdition) {
        UIImage *editionThumbImage = [UIImage imageWithContentsOfFile:imagePath];
        if (!
            editionThumbImage) {
            [_iv_frontPage setImage: paperErrorImage];
        } else  {
            [_iv_frontPage setImage: editionThumbImage];
        }
        
        
    } else {
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
                                          
                                          [_iv_frontPage setImage:paperErrorImage];
                                      }];

    }
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
        
        [appDelegate.bookShelfVC openPDF:downloadedEdition];
    }
    
    /*
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
    }*/
}

#pragma mark PLAY PAUSE FUNCTIONALITY
- (IBAction)playPauseDownload:(id)sender {
    UIButton *btnSender = (UIButton*)sender;
    
    if ([btnSender isSelected]) {
        //PLAY
        magazineStatus = playing;
        [btnSender setSelected:NO];

        [self downloadThisEdition:sender];
        
        //Track unpaused edition
        [appTracker sendEventWithCategory:@"Unpause Edition" withAction:@"Unpause" withLabel:self.edition.dateString withValue:0];
        
    }else  {
        //PAUSE
        if ([[SPDownloader mySPDownloader] isDownloading] && [[SPDownloader mySPDownloader].myURL isEqualToString:_edition.paperUrl])
        {
            magazineStatus = paused;
            [btnSender setSelected:YES];
            
            [[SPDownloader mySPDownloader] pauseDownload];
            
            NSString *title = NSLocalizedString(@"Download", nil);
            NSString *text = NSLocalizedString(@"DOWNLOAD_PAUSED", nil);
            [UserInterfaceUtils showPopupWithTitle:title text:text];
            
            NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
            [trackingDict setObject:@"engagement" forKey:@"event_engagement_action"];
            [trackingDict setObject:[NSString stringWithFormat:@"sun edition:%@:download:abort", [_edition getTrackingDateString]] forKey:@"event_engagement_name"];
            [trackingDict setObject:@"click" forKey:@"event_engagement_browsing_method"];
            
        }
        
        //Track paused edition
        [appTracker sendEventWithCategory:@"Pause Edition" withAction:@"Pause" withLabel:self.edition.dateString withValue:0];
    }

}


#pragma mark DOWNLOAD EDITION USING NSURL
- (IBAction) downloadThisEdition : ( id ) sender
{
    int connectionType = [[HelperUtility sharedInstance] connectionType];
    NSString *title     = NSLocalizedString(@"3G_WARNING", nil);
    NSString *message   = NSLocalizedString(@"3G_MESSAGE", nil);
    
    if (connectionType == Wwan && ![SPDownloader mySPDownloader].isDownloading) {
        UIAlertView *wwanWarning = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        
        [wwanWarning setTag:CONNECTION_TYPE_POPUP];
        [wwanWarning show];
    }
    else
    {
        UIButton *btn = (UIButton*)sender;
        [self continueDownload:btn.tag];
    }
    
    //Track downloaded edition
    [appTracker sendEventWithCategory:@"Download Edition" withAction:@"Download" withLabel:self.edition.dateString withValue:0];
}

- (void) continueDownload:(int)tag
{
    if (![SPDownloader mySPDownloader].isDownloading)
    {
        if (![SPDownloader mySPDownloader].isPauseDownloadedManually || tag == PLAYPAUSE_TAG)
        {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:@"edition download start" forKey:@"product_size"];
            [dictionary setObject:@"download" forKey:@"product_sku"];
            [dictionary setObject:_edition.dateString forKey:@"webview_url"];
            
            _progressView.progress = 0;
            _downloadingLabel.text = [NSString stringWithFormat:@"Downloading... %i%%", 0];
            
            [self setProgress:0];
            [SPDownloader mySPDownloader].delegate = self;
            [[SPDownloader mySPDownloader] startDownload:_edition isAutomated:NO];
            
            TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.bookShelfVC refreshEditionViews];
            [self trackDownload];

        }
        else{
            NSString *title = NSLocalizedString(@"Downloading", nil);
            NSString *text = NSLocalizedString(@"SINGLE_DOWNLOAD_MESSAGE", nil);
            [UserInterfaceUtils showPopupWithTitle:title text:text];
        }
    }
    else
    {
        NSString *title = NSLocalizedString(@"Downloading", nil);
        NSString *text = NSLocalizedString(@"SINGLE_DOWNLOAD_MESSAGE", nil);
        [UserInterfaceUtils showPopupWithTitle:title text:text];
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
            NSMutableArray *listOfPath = [NSMutableArray new];
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
                
                [listOfPath addObject:[NSString stringWithFormat:@"%@%@", [newEdition getPDFDirectory], newPage.relativePdfUrl]];
                [newEdition.pages addObject:newPage];
            }
            
            NSArray *sections = [infoDict objectForKey:@"paperMenu"];
            for (NSDictionary *section in sections)
            {
                EditionSection *newSection = [[EditionSection alloc] init];
                newSection.name         = [section objectForKey:@"title"];
                newSection.pageNumber   = [[section objectForKey:@"page"] intValue];
                
                [newEdition.sections addObject:newSection];
            }
            
            //Merge all pdf's
            newEdition.fullPDFPath = [UserInterfaceUtils joinPDF:listOfPath withName:newEdition.dateString];
            
            // Add the edition to our cache and save
            [[TTEditionManager sharedInstance].downloadedEditions addObject:newEdition];
            [[TTEditionManager sharedInstance] snapshot];
            
        }
        
        //Edition download successful
        [appTracker sendEventWithCategory:@"Download Edition Success" withAction:@"Downloaded" withLabel:self.edition.dateString withValue:0];

    }
    else if ( [SPDownloader mySPDownloader].isPauseDownloadedManually == YES ) {
        NSLog(@"DOWNLOAD STOP FOR SOME REASON 111");
    }
    
    // Refresh our view
    TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.bookShelfVC refreshEditionViews];
}

- (void) downloadUpdatedProgress:(NSString*)url progress:(float)progress
{
    _progressView.progress = progress;
    [self setProgress:progress];
    
    int progressValue = (int)(progress*100) >= 100 ? 100 : (int)(progress*100);
    
    _downloadingLabel.text = [NSString stringWithFormat:@"Downloading... %i%%", progressValue];
}

- (void) downloadFailed:(Edition *)edition
{
    NSString *title     = NSLocalizedString(@"Download paper", nil);
    NSString *text      = NSLocalizedString(@"DOWNLOAD_FAILED", nil);
    NSString *retry     = NSLocalizedString(@"Retry", nil);
    NSString *cancel    = NSLocalizedString(@"Cancel", nil);
    
    [SPDownloader mySPDownloader].isPauseDownloadedManually = NO;
    magazineStatus = stopped;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:cancel otherButtonTitles:retry, nil];
    alertView.tag = DOWNLOAD_FAILED_POPUP_TAG;
    [alertView show];
     
    //Edition download failed
    [appTracker sendEventWithCategory:@"Download Edition Failed" withAction:@"Failed Download" withLabel:self.edition.dateString withValue:0];
}


- (void) trackDownload
{
    NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
    [trackingDict setObject:@"download" forKey:@"event_download_action"];
    [trackingDict setObject:@"sun edition" forKey:@"event_download_type"];
    [trackingDict setObject:[NSString stringWithFormat:@"sun edition:%@", [_edition getTrackingDateString]] forKey:@"event_download_name"];
}

#pragma mark DELETING METHODS
// For the option to delete an edition.
- (void) startWobbling
{
    // This delay is required to allow multiple UIView animations to take place at once
    [UIView setAnimationDelay:0.05];
    [UIView setAnimationDuration:0.3];
    _deleteButton.hidden = NO;
    _deleteButton.frame = CGRectMake(self.frame.size.width-_deleteButton.frame.size.width, 0, _deleteButton.frame.size.width, _deleteButton.frame.size.height);
    
    [UIView commitAnimations];
    
    int randomnum = (int)random()%5;
    float randomfloat = (float)randomnum/50.0;
    
    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    CGAffineTransform swirl = CGAffineTransformRotate(scale, -M_PI/(300));
    [self setTransform:swirl];
    
    [UIView beginAnimations:@"wobble" context:nil];
    [UIView setAnimationRepeatCount:HUGE_VALF];
    [UIView setAnimationRepeatAutoreverses:YES];
    
    [UIView setAnimationDuration:0.15+randomfloat];
    
    swirl = CGAffineTransformRotate(scale, M_PI/(300));
    [self setTransform:swirl];
    [UIView commitAnimations];
}

// Cancel and previous wobbling animations
- (void) stopWobbling
{
	CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	self.transform = scale;
	_deleteButton.hidden = YES;
	[UIView commitAnimations];
}

- (IBAction) deleteEdition
{
    NSString *title = NSLocalizedString(@"Delete Edition", nil);
    NSString *text = NSLocalizedString(@"CONFIRM_DELETE", nil);
    NSString *delete = NSLocalizedString(@"Delete", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:cancel otherButtonTitles:delete, nil];
    alertView.tag = DELETE_POPUP_TAG;
    [alertView show];
    
    //Edition deleted
    [appTracker sendEventWithCategory:@"Edition Deleted" withAction:@"Delete" withLabel:self.edition.dateString withValue:0];
}

- (IBAction) deleteInterruptedDownload:(id)sender
{
    NSString *title = NSLocalizedString(@"Delete Edition", nil);
    NSString *text = NSLocalizedString(@"CLEAR_DOWNLOAD", nil);
    NSString *delete = NSLocalizedString(@"Delete", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:cancel otherButtonTitles:delete, nil];
    alertView.tag = DELETE_INTERRUPT_POPUP_TAG;
    [alertView show];
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
            [[TTEditionManager sharedInstance] deleteEdition:_edition];
            TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.bookShelfVC refreshEditionViews];
            
            NSMutableDictionary *trackingDict = [[NSMutableDictionary alloc] init];
            [trackingDict setObject:@"navigation" forKey:@"event_navigation_action"];
            [trackingDict setObject:@"click" forKey:@"event_navigation_browsing_method"];
            [trackingDict setObject:[NSString stringWithFormat:@"sun edition:delete:%@", [_edition getTrackingDateString]] forKey:@"event_navigation_name"];
            [TrackingUtil trackEvent:@"edition delete" fromView:appDelegate.bookShelfVC.view extraData:trackingDict];
        }
    }
    else if (alertView.tag == CONNECTION_TYPE_POPUP)
    {
        if (buttonIndex == 1)
        {
            [self continueDownload:DOWNLOAD_TAG];
        }
    }
    else if (alertView.tag == DELETE_INTERRUPT_POPUP_TAG)
    {
        if (buttonIndex == 1)
        {
            [[SPDownloader mySPDownloader] clearDownloadOnDelete];
            magazineStatus = stopped;
            
            TheTimesAppDelegate *appDelegate = (TheTimesAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.bookShelfVC refreshEditionViews];
        }
    }
        
}

@end
