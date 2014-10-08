//
//  PaperEditionView.m
//  TheTimes
//
//  Created by KrisMraz on 10/8/14.
//  Copyright (c) 2014 TheCoapperative. All rights reserved.
//

#import "PaperEditionView.h"
#import "UIImageView+AFNetworking.h"
#import "Networking/NINetworkingConnection.h"
#import "NI_reachabilityService.h"
#import "configOptions.h"

#define kPaperURL @"paperUrl"
#define kPaperDate @"paperDate"
#define kPaperThumb @"paperThumb"
#define thumbOffsetH 12
#define thumbOffsetV 10
#define thumbWidth 203
#define thumbHeight 260
#define paperViewWidth 215	// total width = thumbWidth + offset width
#define paperViewHeight 340
#define dayOfWeekYPos 280
#define fullDateYPos 300
#define downloadImageHeight 77
#define downloadImageWidth 77

@implementation PaperEditionView

-(id) initWithDictionary:(NSDictionary*)properties andOrigin:(CGPoint)origin {
{
    if (!properties || (NSNull*)properties == [NSNull null]){
		return nil;
	}
    
    self = [ super init ];
    if (self) {
        
        NSArray *weekdays = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
		self.frame = CGRectMake(origin.x, origin.y, paperViewWidth, paperViewHeight);
		self.backgroundColor = [UIColor blackColor];
		highlight = [[UIImageView alloc] initWithFrame:CGRectMake(-30, 30, 275, 360)];	// playing with the position and alpha to have the custom higlight size/brightness
		highlight.image = [UIImage imageNamed:@"Highlight.png"];
		highlight.alpha = 0.8;
		[self addSubview:highlight];
		
		paperURL = [[NSString alloc] initWithString:[properties objectForKey:kPaperURL]];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyyMMdd"];
		paperDate = [dateFormatter dateFromString:[properties objectForKey:kPaperDate]];
		
		// ImageView for the background of the Thumb (right + bottom border)
		thumbBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbWidth + thumbOffsetH + 7, thumbHeight + thumbOffsetV + 7)];
        
		UIImageView* paperThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, thumbHeight)];
		//paperThumb.delegate = self;
        NSURL *thumbURL = [NSURL URLWithString:[properties objectForKey:kPaperThumb]];
        
        
        NSString *filename = [[paperURL lastPathComponent] stringByDeletingPathExtension];
        NSString* imagePath = [NSString stringWithFormat:@"%@/Caches/papers/%@/%@.jpg",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0],filename,filename];
        //NSLog(@"Checking local image from %@",imagePath);
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
        
        if(fileExists){
            [paperThumb setImage:[UIImage imageWithContentsOfFile:imagePath]];
        }else if([NI_reachabilityService isNetworkAvailable]){
            NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init] ;
            [request setURL:thumbURL];
            [request setHTTPMethod:@"GET"];
            
            [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [request setTimeoutInterval:10.0];
            
            NSString *contentType = [NSString stringWithFormat:@"application/jpeg;"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [request setValue:contentType forHTTPHeaderField: @"content-Type"];
            [request setValue:contentType forHTTPHeaderField:@"mime-Type"];
            [request setValue:[NSString stringWithFormat:@"%@",[defaults valueForKey:@"token"]] forHTTPHeaderField: @"ACS-Auth-TokenId"];
            
            
            [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
            
            [paperThumb setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [paperThumb setImage:image];
                                       }
             
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           UIImage *paperErrorImage;
                                           
                                           paperErrorImage = [UIImage imageNamed:@"paper-default.jpg"];
                                           [paperThumb setImage:paperErrorImage];
                                       }];
        }
        else{
            [paperThumb setImage:[UIImage imageNamed:@"paper-error.jpg"]];
        }
        
        
        
		[thumbBackground addSubview:paperThumb];

		[self addSubview:thumbBackground];
		
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.frame = CGRectMake(thumbWidth/2 - 37/2, thumbHeight/2 - 37/2, 37, 37);
		activityIndicator.hidesWhenStopped = YES;
		[self addSubview:activityIndicator];
		
		// button (the thumb image)
		// issue highlighted in 4.2 - using initWithFrame on previously allocated object
        
		launchPaperButton = [ UIButton buttonWithType:UIButtonTypeCustom] ;
		[launchPaperButton setFrame:CGRectMake(0, 0, thumbWidth, thumbHeight)];
		[launchPaperButton addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
		downloadImage = [[UIImageView alloc] initWithFrame:CGRectMake(launchPaperButton.frame.size.width/2 - downloadImageWidth/2,
																	  launchPaperButton.frame.size.height/2 - downloadImageHeight/2,
																	  downloadImageWidth, downloadImageHeight)];
		downloadImage.image = [UIImage imageNamed:@"download.png"];
		[launchPaperButton addSubview:downloadImage];
		[self addSubview:launchPaperButton];
		
		
		
		// Labels for dates
		dayOfWeek = [[UILabel alloc] initWithFrame:CGRectMake(0, dayOfWeekYPos, paperViewWidth, 20)];
		dayOfWeek.textAlignment = UITextAlignmentCenter;
		dayOfWeek.font = [UIFont boldSystemFontOfSize:14];
		dayOfWeek.textColor = [UIColor whiteColor];
		dayOfWeek.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
		int weekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:paperDate] weekday];
		dayOfWeek.text = [weekdays objectAtIndex:weekday - 1];
		dayOfWeekString = [ weekdays objectAtIndex:weekday - 1] ;
		[self addSubview:dayOfWeek];
		
		fullDate = [[UILabel alloc] initWithFrame:CGRectMake(0, fullDateYPos, paperViewWidth, 20)];
		fullDate.textAlignment = UITextAlignmentCenter;
		fullDate.font = [UIFont boldSystemFontOfSize:14];
		fullDate.textColor = [UIColor whiteColor];
		fullDate.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
		
		[dateFormatter setDateFormat:@"MMMM"];
		
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:paperDate];
        
        NSInteger day = [components day];
        NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
        NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
        NSString *suffix = [suffixes objectAtIndex:day];
        NSString *dateString = [NSString stringWithFormat:@"%ld%@ %@",(long)day ,suffix, [dateFormatter stringFromDate:paperDate]];
        fullDate.text = dateString;
        
		[self addSubview:fullDate];
		
		//Delete button
		deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[deleteButton addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
		[deleteButton setFrame:CGRectMake(-5, -5, 40, 40)];
		deleteButton.alpha = 0;
		deleteButton.showsTouchWhenHighlighted = YES;
		[self addSubview:deleteButton];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (needsOverlay) {
		highlight.hidden = YES;
		
		if (![activityIndicator isAnimating]) {
			downloadImage.hidden = NO;
		}
		
		thumbBackground.image = nil;
		thumbBackground.alpha = 0.4;
		fullDate.alpha = 0.4;
		dayOfWeek.alpha = 0.4;
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		highlight.hidden = NO;
		downloadImage.hidden = YES;
		thumbBackground.image = [UIImage imageNamed:@"BG_Editions_Wrapper.png"];
		thumbBackground.alpha = 1;
		fullDate.alpha = 1;
		dayOfWeek.alpha = 1;
		[UIView commitAnimations];
	}
}

- (void) startWobbling {
	if (!needsOverlay) {
		// Introduce some randomness, using random() because we don't care for any randomness really
		[UIView setAnimationDelay:0.05]; // This delay is required to allow multiple UIView animations to take place at once
		[UIView setAnimationDuration:0.3];
		deleteButton.alpha = 1;
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
}

-(void) showProgressBar {
	if (!progressBar) {
		progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		progressBar.frame = CGRectMake(0, fullDateYPos + 5, paperViewWidth, 20);
	}
	progressBar.hidden = NO;
	fullDate.frame = CGRectMake(0, fullDateYPos + 20, paperViewWidth, 20);
	dayOfWeek.text = @"Downloading...";
	[self addSubview:progressBar];
	progressBar.progress = 0;
	downloadImage.hidden = YES;
	[activityIndicator startAnimating];
	[self setNeedsDisplay];
}

-(void) hideProgressBarShowOverlay:(BOOL)overlay {
	needsOverlay = overlay;
	fullDate.frame = CGRectMake(0, fullDateYPos, paperViewWidth, 20);
	dayOfWeek.text = dayOfWeekString;
	[activityIndicator stopAnimating];
	progressBar.hidden = YES;
	[self setNeedsDisplay];
}

-(void) updateProgressBar:(float)sizeReceived {
	if (sizeReceived > 0.95) {
		progressBar.progress = 0.95;
	}
	else {
		progressBar.progress = sizeReceived;
	}
	
	[self setNeedsDisplay];
}

- (void) stopWobbling {
	CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	self.transform = scale;
	deleteButton.alpha = 0.0;
	[UIView commitAnimations];
}

- (void) deletePressed:(id)sender {
	UIAlertView *deleteConfirm = [[UIAlertView alloc] initWithTitle:@"Delete Edition" message:@"Are you sure you want to delete this edition?" delegate:self
												  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[deleteConfirm setDelegate:self];
	
	[deleteConfirm show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[delegate pressedDeleteEditionPaper:managedEditionPaper forView:self];
	}
}

@end
