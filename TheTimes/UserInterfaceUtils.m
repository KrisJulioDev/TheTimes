//
//  UserInterfaceUtils.m
//  The Sun
//
//  Created by Daniel on 20/01/2014.
//  Copyright (c) 2014 News International. All rights reserved.
//

#import "UserInterfaceUtils.h"
#import "Constants.h"

@implementation UserInterfaceUtils

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

+ (NSString *)joinPDF:(NSArray *)listOfPath withName:(NSString*) pname{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/mergepdf/pdf",[paths objectAtIndex:0]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // File paths
    NSString *fileName = pname;
    NSString *pdfPathOutput = [layOutPath stringByAppendingPathComponent:fileName];
    CFURLRef pdfURLOutput = (__bridge CFURLRef)[NSURL fileURLWithPath:pdfPathOutput];
    NSInteger numberOfPages = 0;
    // Create the output context
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
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
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
        }
        
        CGPDFDocumentRelease(pdfRef);
        CFRelease(pdfURL);
    }
    
    //    // Finalize the output file
    CGPDFContextClose(writeContext);
    CGContextRelease(writeContext);
    
    return pdfPathOutput;
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
