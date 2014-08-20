//
//  PDFVCanvas.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFVCanvas.h"

@implementation PDFVCanvas
-(id)init:(CGContextRef)ctx :(float)scale
{
    if( self = [super init] )
    {
        m_ctx = ctx;
        m_scale = scale;
    }
    return self;
}
-(void)DrawBmp:(PDFDIB *)dib :(int)x :(int)y
{
	Byte *data = (Byte *)[dib data];
	int w = [dib width];
	int h = [dib height];
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, w * h * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( w, h, 8, 32, w<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);
    
    CGContextSaveGState(m_ctx);
    CGContextTranslateCTM(m_ctx, x/m_scale, (y + h)/m_scale);
    CGContextScaleCTM(m_ctx, 1/m_scale, -1/m_scale);
    CGContextDrawImage(m_ctx, CGRectMake(0, 0, w, h), img);
    CGContextRestoreGState(m_ctx);
    CGImageRelease(img);
}
-(void)DrawBmp:(PDFDIB *)dib :(int)x :(int)y :(int)w :(int)h
{
	Byte *data = (Byte *)[dib data];
	int dw = [dib width];
	int dh = [dib height];
    CGDataProviderRef provider = CGDataProviderCreateWithData( NULL, data, dw * dh * 4, NULL );
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGImageRef img = CGImageCreate( dw, dh, 8, 32, dw<<2, cs, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst, provider, NULL, FALSE, kCGRenderingIntentDefault );
    CGColorSpaceRelease(cs);
    CGDataProviderRelease(provider);

    CGContextSaveGState(m_ctx);
    CGContextTranslateCTM(m_ctx, x/m_scale, (y + h)/m_scale);
    CGContextScaleCTM(m_ctx, 1/m_scale, -1/m_scale);
    CGContextDrawImage(m_ctx, CGRectMake(0, 0, w, h), img);
    CGContextRestoreGState(m_ctx);
    CGImageRelease(img);
}

-(void)FillRect:(CGRect) rect :(int) color
{
    CGFloat clr[4];
    clr[0] = ((Byte *)&color)[2] / 255.0f;
    clr[1] = ((Byte *)&color)[1] / 255.0f;
    clr[2] = ((Byte *)&color)[0] / 255.0f;
    clr[3] = ((Byte *)&color)[3] / 255.0f;
    rect.origin.x /= m_scale;
    rect.origin.y /= m_scale;
    rect.size.width /= m_scale;
    rect.size.height /= m_scale;
    CGContextSetFillColor(m_ctx, clr);
    CGContextFillRect(m_ctx, rect);
}
-(CGContextRef)context
{
    return m_ctx;
}
@end