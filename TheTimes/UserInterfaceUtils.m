//
//  UserInterfaceUtils.m
//  The Sun
//
//  Created by Daniel on 20/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "UserInterfaceUtils.h"
#import "Constants.h"
#import "Edition.h"

#define kStyle          @"Style"
#define kTheMagazine    @"The Magazine"

@implementation UserInterfaceUtils
{
    
}

+ (NSString *) getPaperRegion
{
    NSString * region = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
    if (region == nil || [REGION_ENGLAND isEqual:region]) { region = @"National"; }
    if (region == nil) { region = REGION_ENGLAND; }

    return region;
}

+ (void) setLogo:(UIImageView *)imageView
{
    NSString *regionImage = nil;
    NSString * region = [[NSUserDefaults standardUserDefaults] objectForKey:PAPER_REGION_KEY];
    
    if ([REGION_IRELAND isEqual:region]) { regionImage = @"irish_logo.png"; }
    else if ([REGION_SCOTLAND isEqual:region]) { regionImage = @"scottish_logo.png"; }
    else { regionImage = @"thesun_logo.png"; }
    
    imageView.image = [UIImage imageNamed:regionImage];
}

+ (NSString *) getRegion
{
    NSString *overriddenRegion = [[NSUserDefaults standardUserDefaults] objectForKey:OVERRIDDEN_REGION_KEY];
    if (overriddenRegion != nil && ![@"" isEqualToString:overriddenRegion])
    {
        return overriddenRegion;
    }
    
    NSLocale *theLocale = [NSLocale currentLocale];
    NSString *code = [theLocale objectForKey:NSLocaleCurrencyCode];
    return code;
}

+ (NSString *) getRegionSaveText
{
    NSString *text = @"SAVE OVER €25 A YEAR";
    
    if ([UserInterfaceUtils isAustralia]) text = @"SAVE OVER $29 A YEAR";
    else if ([UserInterfaceUtils isCanada]) text = @"SAVE OVER $23 A YEAR";
    else if ([UserInterfaceUtils isUK]) text = @"SAVE OVER £13 A YEAR";
    else if ([UserInterfaceUtils isUS]) text = @"SAVE OVER $23 A YEAR";
    else text = @"SAVE OVER €25 A YEAR";
    
    return text;
}

+ (UIImage *) getPerWeekResource
{
    NSString *image = nil;
    
    if ([UserInterfaceUtils isAustralia]) image = @"text_price_week_aus.png";
    else if ([UserInterfaceUtils isCanada]) image = @"text_price_week_can.png";
    else if ([UserInterfaceUtils isUK]) image = @"text_price_week_uk.png";
    else if ([UserInterfaceUtils isUS]) image = @"text_price_week_us.png";
    else image = @"text_Price269_perweek.png";
    
    return [UIImage imageNamed:image];
}

+ (UIImage *) getPerMonthResource
{
    NSString *image = nil;
    
    if ([UserInterfaceUtils isAustralia]) image = @"text_price_month_aus.png";
    else if ([UserInterfaceUtils isCanada]) image = @"text_price_month_can.png";
    else if ([UserInterfaceUtils isUK]) image = @"text_price_month_uk.png";
    else if ([UserInterfaceUtils isUS]) image = @"text_price_month_us.png";
    else image = @"text_Price999_.png";
    
    return [UIImage imageNamed:image];
}

+ (UIImage *) getPriceResource
{
    NSString *image = nil;
    
    if ([UserInterfaceUtils isAustralia]) image = @"text_price_aus.png";
    else if ([UserInterfaceUtils isCanada]) image = @"text_price_can.png";
    else if ([UserInterfaceUtils isUK]) image = @"text_price_uk.png";
    else if ([UserInterfaceUtils isUS]) image = @"text_price_us.png";
    else image = @"text_Price269_.png";
    
    return [UIImage imageNamed:image];
}

/**
 *  Merge all pdf data, we downloaded seperate pdf pages but we need 1 whole pdf per edition 
 *  for RADAEE
 *
 *  @param listOfPath array of PDF path to merge
 *  @param edition      file name for the pdf
 *
 *  @return filepath for the merged pdf
 */
+ (NSString *)joinPDF:(NSArray *)listOfPath withEdition:(Edition*) edition{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/mergepdf/pdf",[paths objectAtIndex:0]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // File paths
    NSString *fileName = edition.dateString;
    NSString *pdfPathOutput = [layOutPath stringByAppendingPathComponent:fileName];
    CFURLRef pdfURLOutput = (__bridge CFURLRef)[NSURL fileURLWithPath:pdfPathOutput];
    NSInteger numberOfPages = 0;
    // Create the output context
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);

    //Special Handling for SundayTimes
    int styleStartingPage = 0;
    int theMagazineStartingPage = 0;
    float styleAdjustment = 0;
    float theMagazineAdjustment = 0;
    float xSpace = 0;
    float ySpace = 0;
    int counter = 1;
    
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* component = [calender components:NSWeekdayCalendarUnit fromDate:[edition date]];
    
    for (EditionSection *section in edition.sections) {
        if ([section.name isEqualToString:kStyle]) {
            styleStartingPage = section.pageNumber;
            styleAdjustment = 114;
        }
        
        if ([section.name isEqualToString:kTheMagazine]) {
            theMagazineStartingPage = section.pageNumber;
            theMagazineAdjustment = 31;
        }
    }
    
//    EditionSection* section 
    
    for (NSString *source in listOfPath) {
        //        CFURLRef pdfURL = (__bridge CFURLRef)[NSURL fileURLWithPath:source];
        
        CFURLRef pdfURL =  CFURLCreateFromFileSystemRepresentation(NULL, [source UTF8String],[source length], NO);
        
        //file ref
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL(pdfURL);
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);
        
        // Loop variables
        CGPDFPageRef page;
        CGRect mediaBox;
        
        
        // Read the first PDF and generate the output pages
        for (int i=1; i<=numberOfPages; i++) {
           
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(writeContext, &mediaBox);
            
            if ([component weekday] == 1) {
                
                page = CGPDFDocumentGetPage(pdfRef, i);
                mediaBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
                
                CGAffineTransform pdfTransform;
                CGSize newsize;
                newsize = mediaBox.size;
                
                float percentage =  styleAdjustment / mediaBox.size.width;
                
                newsize.width += percentage * newsize.width;
                newsize.height += percentage * newsize.height;
                
                ySpace = -(percentage * newsize.height / 2);
                
                if (counter >= theMagazineStartingPage) {
                    xSpace = (counter % 2) == 1 ? theMagazineAdjustment : 85;
                    
                    pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, CGRectMake(-xSpace, ySpace, newsize.width, newsize.height), 0, true);
                    CGContextConcatCTM(writeContext, pdfTransform);
                    
                } else if (counter >= styleStartingPage) {
                    xSpace = (counter % 2) == 0 ? styleAdjustment * 2 : 0;
                    
                    pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, CGRectMake(-xSpace, ySpace, newsize.width, newsize.height), 0, true);
                    CGContextConcatCTM(writeContext, pdfTransform);
                }
            }
            
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
            
            /*
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
            
            CGSize newsize;
            newsize = mediaBox.size;
            
            float percentage =  styleAdjustment / mediaBox.size.width;
            
            newsize.width += percentage * newsize.width;
            newsize.height += percentage * newsize.height;
            
            ySpace = -(percentage * newsize.height / 2);
            
            CGContextBeginPage(writeContext, &mediaBox);
            CGAffineTransform pdfTransform;
            
            
            if (counter >= theMagazineStartingPage && [component weekday] == 1) {
                xSpace = (counter % 2) == 1 ? theMagazineAdjustment : 85;
                
            } else if ( counter >= styleStartingPage && [component weekday] == 1) {
                
                xSpace = (counter % 2) == 0 ? styleAdjustment * 2 : 0;
                
            }
            
            pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, CGRectMake(-xSpace, ySpace, newsize.width, newsize.height), 0, true);
            CGContextConcatCTM(writeContext, pdfTransform);
            
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
            
            /*
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox );
            

            //UIGraphicsBeginPDFPageWithInfo(styleCutLeft, nil);
            CGContextBeginPage(writeContext, &mediaBox);
            
            
            CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, newrect, 0, true);
            // And apply the transform.
            CGContextConcatCTM(writeContext, pdfTransform);
            
//            CGContextClearRect(writeContext, CGRectMake(0, 0, 200, 300));
            CGContextScaleCTM(writeContext, newsize.width / mediaBox.size.width, newsize.height / mediaBox.size.height);
            
            // Flip Context to render PDF correctly
            CGContextTranslateCTM(writeContext, 0.0, mediaBox.size.height);
            CGContextScaleCTM(writeContext, 1.0, 1.0);
            
            CGContextDrawPDFPage(writeContext, page);
            
            CGContextEndPage(writeContext);*/
        }
        
        counter++;
        
        CGPDFDocumentRelease(pdfRef);
        CFRelease(pdfURL);
    }
    
    //    // Finalize the output file
    CGPDFContextClose(writeContext);
    CGContextRelease(writeContext);
    
    return pdfPathOutput;
}

/**
 *  Split pages for sections 
 *  eg: page 1 must be single page because this will be the magazine cover. 
 *  The first page of every section must be single page also and the last page of every section will sometimes be single page
 *
 *  @param firstPages         number of sections
 *  @param totalNumberOfPages total number of pages in the pdf
 *
 *  @return array of booleans of first pages
 */
+ (bool*) split :(NSMutableArray*)firstPages totalNumber:(int)totalNumberOfPages
{
    NSMutableArray *splits = [NSMutableArray new];
    int numOfSplits = 0;
    
    for (int i = 0; i < totalNumberOfPages; i++) {
        BOOL isSinglePage = false;
        
        for(int j = 0; j < firstPages.count; j++) {
            
            int firstPageVal = [[firstPages objectAtIndex:j] intValue];
            
            if((i+1) == firstPageVal - 1) {
                isSinglePage = true;
                break;
            }
            
            if((i+1) == firstPageVal ) {
                isSinglePage = true;
                break;
            }
        }
        
        if(i == totalNumberOfPages - 1) {
            
            isSinglePage = true;
            
        }
        
        if(!isSinglePage) {
            
            i++;
            
        }
         
        [splits addObject:[NSNumber numberWithBool:!isSinglePage]];
        numOfSplits++;
        
    }
    
    bool *returnSplits = (bool *)calloc( sizeof(bool), numOfSplits );
    
    int loop = 0;
    for (NSNumber *boolInt in splits) { 
        returnSplits[loop] = [boolInt boolValue] ;
        loop++;
    }
    
    return returnSplits;
}

+ (BOOL) isAustralia
{
    return [UserInterfaceUtils isCurrency:@"AUD"];
}

+ (BOOL) isCanada
{
    return [UserInterfaceUtils isCurrency:@"CAD"];
}

+ (BOOL) isUK
{
    return [UserInterfaceUtils isCurrency:@"GBP"];
}

+ (BOOL) isUS
{
    return [UserInterfaceUtils isCurrency:@"USD"];
}

+ (BOOL) isEuro
{
    return [UserInterfaceUtils isCurrency:@"EUR"];
}

+ (BOOL) isCurrency:(NSString *) currency
{
    NSString *code = [UserInterfaceUtils getRegion];
    return [[code lowercaseString] isEqualToString:[currency lowercaseString]];
}


+ (UIImageView *) getLoadingImage
{
    return nil;
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0,0,70,70);
    imageView.contentMode = UIViewContentModeCenter;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=1;i<=12;i++)
    {
        if (i < 10)
        {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_0%i.png", i]];
            [array addObject:image];
        }
        else
        {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%i.png", i]];
            [array addObject:image];
        }
    }

    imageView.animationImages = array;
    imageView.animationDuration = 1;
    imageView.animationRepeatCount = -1;
    [imageView startAnimating];
    return imageView;
}

+ (UIView *) addLoadingCover:(UIView *)loadingView parent:(UIView *)parent
{
    return [UserInterfaceUtils addLoadingCoverWithMsg:loadingView parent:parent message:@""];
}

+ (UIView *) addLoadingCoverWithMsg:(UIView *)loadingView parent:(UIView *)parent message:(NSString *)msg
{
    if (loadingView != nil)
    {
        if (loadingView.superview != parent)
        {
            [parent addSubview:loadingView];
        }
        loadingView.hidden = NO;
        ((UILabel *)[loadingView.subviews objectAtIndex:0]).text = msg;
        
        return loadingView;
    }
    
    UIView *newLoadingView = [[UIView alloc] initWithFrame:parent.frame];
    newLoadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    
    UILabel *label = [[UILabel alloc] initWithFrame:newLoadingView.frame];
    label.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:label.font.pointSize];
    label.center = CGPointMake(label.center.x, label.center.y+50);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = msg;
    [newLoadingView addSubview:label];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.center = CGPointMake(parent.frame.size.width/2, parent.frame.size.height/2);
    [newLoadingView addSubview:spinner];
    [spinner startAnimating];
    
    [parent addSubview:newLoadingView];
    return newLoadingView;
}

+ (void) showPopupWithTitle:(NSString *)title text:(NSString *)text
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

+ (void) removeAllSubviews:(UIView *)parentView
{
    NSArray *subviews = parentView.subviews;
    for (UIView *subview in subviews)
    {
        [subview removeFromSuperview];
    }
}

/** @brief Adjust x position of a given view
 Example usage:
 @code
 int    frontPageHeight;
 UIView *labelView;
 [UserInterfaceUtils setY:frontPageHeight forView:labelView];
 @endcode
 */
+ (void) setX:(int)x forView:(UIView *)view
{
    view.frame = CGRectMake(x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

/** @brief Adjust y position of a given view
    Example usage:
    @code
    int    frontPageY;
    UIView *labelView;
    [UserInterfaceUtils setY:frontPageY forView:labelView];
    @endcode
 */
+ (void) setY:(int)y forView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
}

/** @brief Adjust height of a given view
 Example usage:
 @code
 int    frontPageHeight;
 UIView *labelView;
 [UserInterfaceUtils setHeight:frontPageHeight forView:labelView];
 @endcode
 */
+ (void) setHeight:(int)height forView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}

@end
