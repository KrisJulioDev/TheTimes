//
//  UIImagesTools.m
//  IGFrameworkProject
//
//  Created by Ondrej Rafaj on 1.4.10.
//  Copyright 2010 Home. All rights reserved.
//

#import "IGImagesTools.h"


@implementation IGImagesTools

/**
 Returns image resized to the given size with correct constrain proportion
 
 @todo Make that work :)
 
 @param myImage UIImage Working image
 @param width int New width for the image
 @param height int New height for the image
 
 @return UIImage Resized image
 */
+ (UIImage *)resizeImage:(UIImage *)myImage toWidth:(int)width andHeight:(int)height {
	
	// constrain proportion
	if (width < 0 || height < 0) return myImage;
	int oldW = myImage.size.width;
	int oldH = myImage.size.height;
	
	int thumbW = width;
	int thumbH = (oldH * width) / oldW;
	
	if (thumbH > height) {
		thumbW = (thumbW * height) / thumbH;
		thumbH = height;
	}
	
	CGRect thumbRect = CGRectMake(0, 0, thumbW, thumbH);
	CGImageRef imageRef = [myImage CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone) alphaInfo = kCGImageAlphaNoneSkipLast;
	
	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(NULL, thumbRect.size.width, thumbRect.size.height, CGImageGetBitsPerComponent(imageRef), 4 * thumbRect.size.width, CGImageGetColorSpace(imageRef), alphaInfo);
	
	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, thumbRect, imageRef);
	
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

/**
 Returns given UIImage with rounded corners
 
 @param img UIImage Working image
 @param radius int Radius for the rounded corners
 
 @return UIImage Image with rounded corners
 */
+ (UIImage *)roundCorners:(UIImage *)img withRadius:(int)radius {
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 5, 5);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    [img release];
	
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    img =  [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
    return img;
}



@end
