//
//  PDFView.h
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "PDFV.h"
#import "RDPDFViewController.h"

@protocol PDFVDelegate <NSObject>
- (void)OnPageChanged :(int)pageno;
- (void)OnLongPressed:(float)x :(float)y;
- (void)OnSingleTapped:(float)x :(float)y :(NSString *)text;
- (void)OnTouchDown: (float)x :(float)y;
- (void)OnTouchUp:(float)x :(float)y ;
- (void)OnSelEnd:(float)x1 :(float)y1 :(float)x2 :(float)y2;
- (void)OnOpenURL:(NSString*)url;
- (void)OnFound:(bool)found;
- (void)OnMovie:(NSString *)fileName;
- (void)OnSound:(NSString *)fileName;
@end

@interface PDFView : UIView <PDFVInnerDel>
{
    PDFDoc *m_doc;
    PDFV *m_view;
    PDFInk *m_ink;
    PDF_POINT *m_rects;
    PDF_POINT *m_ellipse;
    
    int m_rects_cnt;
    int m_rects_max;
    bool m_rects_drawing;
    
    int m_ellipse_cnt;
    int m_ellipse_max;
    bool m_ellipse_drawing;
    
    int m_type;
    
    NSTimer *m_timer;
    bool m_modified;
    int m_w;
    int m_h;
    int m_cur_page;
    
    enum STATUS
    {
        sta_none,
        sta_hold,
        sta_zoom,
        sta_sel,
        sta_ink,
        sta_rect,
        sta_ellipse,
    };
    enum STATUS m_status;
    NSTimeInterval m_tstamp;
    NSTimeInterval m_tstamp_tap;
    float m_tx;
    float m_ty;
    float m_px;
    float m_py;
    float m_swx[8];
    float m_swy[8];
    NSTimeInterval m_tstamp_swipe[8];
    float m_zoom_x;
    float m_zoom_y;
    struct PDFV_POS m_zoom_pos;
    float m_zoom_dis;
    float m_zoom_ratio;
    float m_scale;
    int m_swipe_dx;
    int m_swipe_dy;
    NSMutableArray* m_arrayTouch;
    id<PDFVDelegate> m_delegate;
}

-(void)vOpen:(PDFDoc *)doc :(id<PDFVDelegate>)delegate;
-(void)vOpenPage:(PDFDoc *)doc :(int)pageno :(float)x :(float)y :(id<PDFVDelegate>)delegate;
-(void)vGoto:(int)pageno;

-(void)vClose;
//invoke this method to set select mode, once you set this mode, you can select texts by touch and moving.
-(void)vSelStart;
//you should invoke this method in select mode.
-(NSString *)vSelGetText;
//you should invoke this method in select mode.
-(BOOL)vSelMarkup:(int)color :(int)type;
//invoke this method to leave select mode
-(void)vSelEnd;

-(void)vGetPos :(struct PDFV_POS*)pos;
//invoke this method to set ink mode, once you set this mode, you can draw ink by touch and moving.

-(bool)vInkStart;
-(void)vInkCancel;
//invoke this method to leave ink mode.
-(void)vInkEnd;

-(bool)vRectStart;
-(void)vRectCancel;
-(void)vRectEnd;

-(bool)vEllipseStart;
-(void)vEllipseCancel;
-(void)vEllipseEnd;


-(void)vLockSide:(bool)lock;
-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word;
-(void)vFind:(int)dir;
-(void)vFindEnd;
-(void)vAddTextAnnot :(int)x :(int)y :(NSString *)text;
-(NSString *)vGetTextAnnot :(int)x :(int)y;
@end

