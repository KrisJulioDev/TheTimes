//
//  PDFView.m
//  PDFReader
//
//  Created by Radaee on 12-7-30.
//  Copyright (c) 2012 Radaee. All rights reserved.
//
#import "PDFView.h"
#import <QuartzCore/QuartzCore.h>
#import "UserInterfaceUtils.h"

extern int g_PDF_ViewMode;
extern float g_Ink_Width;
extern float g_rect_Width;
extern uint g_ink_color;
extern uint g_rect_color;
extern uint g_ellipse_color;
extern uint annotOvalColor;
extern NSMutableString *pdfName;
extern NSMutableString *pdfPath;

@implementation PDFView

-(void)OnPageRendered:(PDFVCache *)cache
{
    [self refresh];
}

-(void)OnFound:(PDFVFinder *)finder
{
    [m_view vFindGoto];
    [self refresh];
    if( m_delegate )
        [m_delegate OnFound:([finder find_get_page] < 0)];
}
-(void)OnPageDisplayed :(CGContextRef)ctx : (PDFVPage *)page
{
    //uncomment these lines to get information of PDF page.
    //all values are in physical screen coordinate, use m_scale to translate back to logic screen coordinate
    //int x = [page GetVX:[m_view vGetX]];
    //float logicx = x/m_scale;
    //int y = [page GetVY:[m_view vGetY]];
    //float logicy = y/m_scale;
    //int w = [page GetWidth];
    //float logicw = w/m_scale;
    //int h = [page GetHeight];
    //float logich = h/m_scale;
    //bool finished = [page IsFinished];
}
-(void)vOpen:(PDFDoc *)doc :(id<PDFVDelegate>)delegate
{
    //GEAR
    [self vClose];
    //END
    m_doc = doc;
    g_PDF_ViewMode =2;
    
    defView = 3;

    bool *verts = (bool *)calloc( sizeof(bool), [doc pageCount] );
 
    NSMutableArray *firstPages = [NSMutableArray new];
    
    for (int x = 0; x < [_edition.sections count]; x++) {
        
        EditionSection *section = [_edition.sections objectAtIndex:x];
        [firstPages addObject:[NSNumber numberWithInt:section.pageNumber]];
    }
    
    verts = [UserInterfaceUtils split:firstPages totalNumber:[doc pageCount]];
    
    switch(defView)
    {
        case 1:
            m_view = [[PDFVHorz alloc] init:false];
            break;
        case 2:
            m_view = [[PDFVHorz alloc] init:true];
            break;
        case 3:
            //for dual view
            m_view = [[PDFVDual alloc] init:false :NULL :0 :verts :[doc pageCount] ];
            break;
        case 4:
            //for dual view
            
            m_view = [[PDFVDual alloc] init:true :NULL :0 :NULL :0];
            //for single view
            //m_view = [[PDFVDual alloc] init:true :NULL :0 :verts :Document_getPageCount(doc)];
            break;
        default:
            m_view = [[PDFVVert alloc] init];
            break;
    }
    
    free( verts );
    m_type = defView;
    struct PDFVThreadBack tback;
    tback.OnPageRendered = @selector(OnPageRendered:);
    tback.OnFound = @selector(OnFound:);
    self.backgroundColor = [UIColor blackColor];
    
    [m_view vOpen:doc :4 :self: &tback];
    [m_view vResize:m_w :m_h];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                               target:self selector:@selector(timerFireMethod:)
                                             userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:m_timer forMode:NSDefaultRunLoopMode];
    m_status = sta_none;
    m_ink = NULL;
    m_modified = false;
    
    m_rects = NULL;
    m_rects_cnt = 0;
    m_rects_max = 0;
    
    m_ellipse = NULL;
    m_ellipse_cnt = 0;
    m_ellipse_max = 0;
    
    m_cur_page = -1;
    m_delegate = delegate;
}

-(void)vGoto:(int)pageno
{
    struct PDFV_POS pos;
    
    pos.x = 0;
    pos.y = [m_doc pageHeight:pageno];

    pos.pageno = pageno;
    PDFVPage *vpage = [m_view vGetPage:pos.pageno];
    
    [m_view vSetPos:&pos :0 :0];
    [m_view vGetDeltaToCenterPage:pos.pageno :&m_swipe_dx :&m_swipe_dy];
    
    [self refresh];
}

-(void)vOpenPage:(PDFDoc *)doc :(int)pageno :(float)x :(float)y :(id<PDFVDelegate>)delegate
{
    [self vOpen:doc:delegate];
    struct PDFV_POS pos;
    pos.pageno = pageno;
    pos.x = x;
    pos.y = y;
    [m_view vSetPos:&pos :0 :0];
}

-(void)vClose
{
   
    if( m_modified && m_doc != NULL )
    {
        [m_doc save];
    }
    if( m_view != nil )
    {
        [m_view vClose];
        m_view = nil;
        [m_timer invalidate];
        m_timer = NULL;
    }
    m_view = NULL;
    m_doc = NULL;
    m_status = sta_none;
    if( m_ink )
    {
        m_ink = NULL;
    }
    if( m_rects )
    {
        free( m_rects );
        m_rects = NULL;
        m_rects_cnt = 0;
        m_rects_max = 0;
    }
    if(m_ellipse)
    {
        free(m_ellipse);
        m_ellipse = NULL;
        m_ellipse_cnt = 0;
        m_ellipse_max = 0;
    }
    m_cur_page = -1;
    m_delegate = nil;
    
    
    //do not close Document object in View class.
    //this shall be closed in Controller class.
    //this means: close Document in creator.
    //GEAR
    //Document_close(m_doc);
    //END
}

-(void)refresh
{
    [self setNeedsDisplay];
}

-(void)draw:(CGContextRef)context
{
    PDFVCanvas *canvas = [[PDFVCanvas alloc] init: context: m_scale];
    [m_view vDraw:canvas:(m_status == sta_zoom)];
    canvas = nil;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos : m_w/2 : m_h/2];
    if( m_cur_page != pos.pageno )
    {
        m_cur_page = pos.pageno;
        if( m_delegate )
            [m_delegate OnPageChanged:m_cur_page];
    }

    if( m_status == sta_ink && m_ink )
    {
        int cnt = [m_ink nodesCount];
        int cur = 0;
        CGContextSetLineWidth(context, g_Ink_Width);
        float red = ((g_ink_color>>16)&0xFF)/255.0f;
        float green = ((g_ink_color>>8)&0xFF)/255.0f;
        float blue = (g_ink_color&0xFF)/255.0f;
        float alpha = ((g_ink_color>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        CGContextBeginPath( context );
        while( cur < cnt )
        {
            PDF_POINT pt;
            PDF_POINT pt2;
            int type = [m_ink node: cur: &pt];
            switch( type )
            {
                case 1:
                    CGContextAddLineToPoint(context, pt.x/m_scale, pt.y/m_scale);
                    cur++;
                    break;
                case 2:
                    [m_ink node: cur + 1: &pt2];
                    CGContextAddCurveToPoint(context, pt.x/m_scale, pt.y/m_scale,
                                             pt.x/m_scale, pt.y/m_scale,
                                             pt2.x/m_scale, pt2.y/m_scale );
                    cur += 2;
                    break;
                default:
                    CGContextMoveToPoint(context, pt.x/m_scale, pt.y/m_scale);
                    cur++;
                    break;
            }
        }
        CGContextStrokePath( context );
    }
    if( m_status == sta_rect && (m_rects_cnt || m_rects_drawing) )
    {
        CGContextSetLineWidth(context, g_rect_Width);
        float red = ((g_rect_color>>16)&0xFF)/255.0f;
        float green = ((g_rect_color>>8)&0xFF)/255.0f;
        float blue = (g_rect_color&0xFF)/255.0f;
        float alpha = ((g_rect_color>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_rects;
        PDF_POINT *pt_end = m_rects + (m_rects_cnt<<1);
        if( m_rects_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            if( pt_cur->x > pt_cur[1].x )
            {
                rect.right = pt_cur->x;
                rect.left = pt_cur[1].x;
            }
            else
            {
                rect.left = pt_cur->x;
                rect.right = pt_cur[1].x;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y;
                rect.top = pt_cur[1].y;
            }
            else
            {
                rect.top = pt_cur->y;
                rect.bottom = pt_cur[1].y;
            }
            CGRect rect1 = CGRectMake(rect.left/m_scale, rect.top/m_scale,
                                      (rect.right - rect.left)/m_scale,
                                      (rect.bottom - rect.top)/m_scale);
            CGContextStrokeRect(context, rect1);
            pt_cur += 2;
        }
    }
    if( m_status == sta_ellipse && (m_ellipse_cnt || m_ellipse_drawing) )
    {
        CGContextSetLineWidth(context, g_rect_Width);
        float red = ((annotOvalColor>>16)&0xFF)/255.0f;
        float green = ((annotOvalColor>>8)&0xFF)/255.0f;
        float blue = (annotOvalColor&0xFF)/255.0f;
        float alpha = ((annotOvalColor>>24)&0xFF)/255.0f;
        CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
        PDF_POINT *pt_cur = m_ellipse;
        PDF_POINT *pt_end = m_ellipse + (m_ellipse_cnt<<1);
        if( m_ellipse_drawing ) pt_end += 2;
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            if( pt_cur->x > pt_cur[1].x )
            {
                rect.right = pt_cur->x;
                rect.left = pt_cur[1].x;
            }
            else
            {
                rect.left = pt_cur->x;
                rect.right = pt_cur[1].x;
            }
            if( pt_cur->y > pt_cur[1].y )
            {
                rect.bottom = pt_cur->y;
                rect.top = pt_cur[1].y;
            }
            else
            {
                rect.top = pt_cur->y;
                rect.bottom = pt_cur[1].y;
            }
            CGRect rect1 = CGRectMake(rect.left/m_scale, rect.top/m_scale,
                                      (rect.right - rect.left)/m_scale,
                                      (rect.bottom - rect.top)/m_scale);
           // CGContextStrokeRect(context, rect1);
           // CGContextAddEllipseInRect(context, rect1);
            CGContextStrokeEllipseInRect(context, rect1);
            
            pt_cur += 2;
        }
    }
}

- (void)timerFireMethod:(NSTimer *)sender
{
    if( m_swipe_dx || m_swipe_dy )
    {
        int speedx;
        if( m_swipe_dx > 0 )
        {
            if( m_swipe_dx < 3 ) speedx = m_swipe_dx;
            else speedx = sqrtl(m_swipe_dx<<2);
        }
        else
        {
            if( m_swipe_dx > -3 ) speedx = m_swipe_dx;
            else speedx = -sqrtl(-m_swipe_dx<<2);
        }
        m_swipe_dx -= speedx;

        int speedy;
        if( m_swipe_dy > 0 )
        {
            if( m_swipe_dy < 3 ) speedy = m_swipe_dy;
            else speedy = sqrtl(m_swipe_dy<<2);
        }
        else
        {
            if( m_swipe_dy > -3 ) speedy = m_swipe_dy;
            else speedy = -sqrtl(-m_swipe_dy<<2);
        }
        m_swipe_dy -= speedy;

        [m_view vMoveDelta:speedx :speedy];
        [self refresh];
    }
    else if( [m_view vNeedRefresh] )
    {
        [self refresh];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_doc = NULL;
        m_view = nil;
        m_scale = [[UIScreen mainScreen] scale];
        m_w = frame.size.width * m_scale;
        m_h = frame.size.height * m_scale;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        [self resignFirstResponder];
        m_swipe_dx = 0;
        m_swipe_dy = 0;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self draw:UIGraphicsGetCurrentContext()];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :m_w :m_h ];
    m_w = size.width * m_scale;
    m_h = size.height * m_scale;
    [m_view vResize:m_w :m_h];
    [m_view vSetScale:0.1f];//set scale to min
    [m_view vSetPos:&pos :m_w :m_h];
    [self refresh];
    return size;
}

-(void)swipe_init:(float) x :(float) y :(NSTimeInterval) ts
{
    m_swx[0] = x;
    m_swx[1] = x;
    m_swx[2] = x;
    m_swx[3] = x;
    m_swx[4] = x;
    m_swx[5] = x;
    m_swx[6] = x;
    m_swx[7] = x;
    m_swy[0] = y;
    m_swy[1] = y;
    m_swy[2] = y;
    m_swy[3] = y;
    m_swy[4] = y;
    m_swy[5] = y;
    m_swy[6] = y;
    m_swy[7] = y;
    m_tstamp_swipe[0] = ts;
    m_tstamp_swipe[1] = ts;
    m_tstamp_swipe[2] = ts;
    m_tstamp_swipe[3] = ts;
    m_tstamp_swipe[4] = ts;
    m_tstamp_swipe[5] = ts;
    m_tstamp_swipe[6] = ts;
    m_tstamp_swipe[7] = ts;
}

-(void)swipe_rec:(float) x :(float) y :(NSTimeInterval) ts
{
    m_swx[0] = m_swx[1];
    m_swx[1] = m_swx[2];
    m_swx[2] = m_swx[3];
    m_swx[3] = m_swx[4];
    m_swx[4] = m_swx[5];
    m_swx[5] = m_swx[6];
    m_swx[6] = m_swx[7];
    m_swx[7] = x;
    m_swy[0] = m_swy[1];
    m_swy[1] = m_swy[2];
    m_swy[2] = m_swy[3];
    m_swy[3] = m_swy[4];
    m_swy[4] = m_swy[5];
    m_swy[5] = m_swy[6];
    m_swy[6] = m_swy[7];
    m_swy[7] = y;
    m_tstamp_swipe[0] = m_tstamp_swipe[1];
    m_tstamp_swipe[1] = m_tstamp_swipe[2];
    m_tstamp_swipe[2] = m_tstamp_swipe[3];
    m_tstamp_swipe[3] = m_tstamp_swipe[4];
    m_tstamp_swipe[4] = m_tstamp_swipe[5];
    m_tstamp_swipe[5] = m_tstamp_swipe[6];
    m_tstamp_swipe[6] = m_tstamp_swipe[7];
    m_tstamp_swipe[7] = ts;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_swipe_dx = 0;
    m_swipe_dy = 0;
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( m_status == sta_none )
        {
            [m_view vOnTouchDown:point.x * m_scale: point.y * m_scale];
            m_tstamp = touch.timestamp;
            m_tstamp_tap = m_tstamp;
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            m_px = m_tx;
            m_py = m_ty;
            [self swipe_init:m_tx :m_ty :m_tstamp];
            m_status = sta_hold;
           
            if( m_delegate )
                [m_delegate OnTouchDown: m_tx :m_ty];
        }
        if( m_status == sta_sel )
        {
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            if( m_delegate )
                [m_delegate OnTouchDown: m_tx :m_ty];
        }
        if( m_status == sta_ink )
        {
            if( !m_ink )
            {
                //(宽度，颜色)
                m_tx = point.x * m_scale;
                m_ty = point.y * m_scale;
                m_ink = [[PDFInk alloc] init:g_Ink_Width * m_scale: g_ink_color];
            }
            [m_ink onDown:point.x * m_scale: point.y * m_scale];
        }
        if( m_status == sta_rect )
        {
            if( m_rects_cnt >= m_rects_max )
            {
                m_rects_max += 8;
                m_rects = (PDF_POINT *)realloc(m_rects, (m_rects_max<<1) * sizeof(PDF_POINT));
            }
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
            pt_cur->x = m_tx;
            pt_cur->y = m_ty;
            pt_cur[1].x = m_tx;
            pt_cur[1].y = m_ty;
            m_rects_drawing = true;
        }
        //**ellipse
        if( m_status == sta_ellipse )
        {
            if( m_ellipse_cnt >= m_ellipse_max )
            {
                m_ellipse_max += 8;
                m_ellipse = (PDF_POINT *)realloc(m_ellipse, (m_ellipse_max<<1) * sizeof(PDF_POINT));
            }
            m_tx = point.x * m_scale;
            m_ty = point.y * m_scale;
            PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
            pt_cur->x = m_tx;
            pt_cur->y = m_ty;
            pt_cur[1].x = m_tx;
            pt_cur[1].y = m_ty;
            m_ellipse_drawing = true;
        }
        if( m_status == sta_zoom )
        {
            m_status = sta_none;
        }
    }
    else if( cnt == 2 )
    {
        UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point1 = [touch1 locationInView:[touch1 view]];
        UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
        CGPoint point2 = [touch2 locationInView:[touch2 view]];
        if( m_status == sta_hold || m_status == sta_none )
        {
            [m_view vZoomStart];
            m_zoom_dis = sqrt((point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y) * (point1.y-point2.y)) * m_scale;
            m_zoom_ratio = [m_view vGetScale];
            m_zoom_x = (point1.x + point2.x) * m_scale/2;
            m_zoom_y = (point1.y + point2.y) * m_scale/2;
            [m_view vGetPos:&m_zoom_pos :m_zoom_x :m_zoom_y];
            m_status = sta_zoom;
        }
    }
    else
    {
        if( m_status == sta_zoom )
        {
            m_status = sta_none;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        if( m_status == sta_hold )
        {
            [m_view vOnTouchMove:point.x * m_scale: point.y * m_scale];
            NSTimeInterval del = touch.timestamp - m_tstamp;
            if( del > 0 )
            {
                float dx = point.x * m_scale - m_px;
                float dy = point.y * m_scale - m_py;
                float vx = dx/del;
                float vy = dy/del;
                dx = 0;
                dy = 0;
                if( vx > 50 || vx < -50 )
                    dx = vx;
                if( vy > 50 || vy < -50 )
                    dy = vy;
                else if( touch.timestamp - m_tstamp_tap > 1 )//single tap
                {
                    dx = point.x * m_scale - m_tx;
                    dy = point.y * m_scale - m_ty;
                    if( dx < 10 && dx > -10 && dy < 10 && dy > -10 )
                    {
                        m_status = sta_none;
                        if( m_delegate )
                            [m_delegate OnLongPressed:point.x * m_scale :point.y * m_scale];
                    }
                }
            }
            m_px = point.x * m_scale;
            m_py = point.y * m_scale;
            [self swipe_rec:m_px :m_py :touch.timestamp];
        }
        if( m_status == sta_sel )
        {
            [m_view vSetSel:m_tx: m_ty: point.x * m_scale: point.y * m_scale];
        }
        if( m_status == sta_ink )
        {
            [m_ink onMove:point.x * m_scale: point.y * m_scale];
        }
        if( m_status == sta_rect )
        {
            PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
            pt_cur[1].x = point.x * m_scale;
            pt_cur[1].y = point.y * m_scale;
        }
        //***ellipse
        if( m_status == sta_ellipse )
        {
            PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt << 1];
            pt_cur[1].x = point.x * m_scale;
            pt_cur[1].y = point.y * m_scale;
        }
        [self refresh];
    }
    else if( cnt == 2 && m_status == sta_zoom )
    {
        UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point1 = [touch1 locationInView:[touch1 view]];
        UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
        CGPoint point2 = [touch2 locationInView:[touch2 view]];
        float dis = sqrt((point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y) * (point1.y-point2.y)) * m_scale;
        
        [m_view vSetScale:m_zoom_ratio * dis / m_zoom_dis];
        [m_view vSetPos:&m_zoom_pos :m_zoom_x :m_zoom_y];
        [self refresh];
    }
    else if( m_status == sta_zoom )
    {
        m_status = sta_none;
        [self refresh];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    int cnt = [allTouches count];
    if( cnt == 1 )
    {
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint point=[touch locationInView:[touch view]];
        switch (m_status)
        {
            case sta_hold:
            {
                m_status = sta_none;
                NSTimeInterval del = touch.timestamp - m_tstamp;
                float dx = point.x * m_scale - m_tx;
                float dy = point.y * m_scale - m_ty;
                float vx = 0;
                float vy = 0;
                if( del > 0 )//fling?
                {
                    vx = dx/del;
                    vy = dy/del;
                }
                
                dx = 0;
                dy = 0;
                
                if( vx > 400 || vx < -400 ) dx = vx;
                if( vy > 400 || vy < -400 ) dy = vy;
                
                float sdel = m_tstamp_swipe[7] - m_tstamp_swipe[0];
                float sdx = (m_swx[7] - m_swx[0])/(del * m_scale);
                float sdy = (m_swy[7] - m_swy[0])/(del * m_scale);
                
                int threshold = 1500;
                if (    (vx > threshold || vx < -threshold)
                    ||  (vy > threshold || vy < -threshold) )
                {
                    // if( m_long_pressed )
                    //    [self vSelEnd];
                    if( sdel < 0.8 && (sdx > 20 || sdx < -20 || dy > 20 || sdy < -20) )//swipe
                        [self onSwipe: sdx :sdy];
                    else if( touch.timestamp - m_tstamp_tap < 0.15 )//single tap
                    {
                        bool single_tap = true;
                        if( dx > 5 || dx < -5 )
                            single_tap = false;
                        if( dy > 5 || dy < -5 )
                            single_tap = false;
                        if( single_tap )
                            [self onSingleTap:point.x * m_scale :point.y * m_scale:nil];
                    }
                    else
                    {
                        if( m_type == 3 || m_type == 4 )
                        {
                            struct PDFV_POS pos;
                            [m_view vGetPos:&pos :m_w/2 :m_h/2];
                            
                            if( sdel < 0.8 && (sdx > 20 || sdx < -20 || dy > 20 || sdy < -20) )//swipe
                                [m_view vGetDeltaToCenterPage:pos.pageno :&m_swipe_dx :&m_swipe_dy];
                        }
                        if( m_delegate )
                        {
                            //[m_view vGetPos:&pos: m_tx: m_ty];
                            [m_delegate OnTouchUp:point.x * m_scale :point.y * m_scale ];
                        }
                    }
                }
                break;
            }
            case sta_sel:
            {
                [m_view vSetSel:m_tx: m_ty: point.x * m_scale: point.y * m_scale];
                if( m_delegate )
                    [m_delegate OnSelEnd:m_tx: m_ty:point.x * m_scale :point.y * m_scale];
                break;
            }
            case sta_ink:
                [m_ink onUp:point.x * m_scale: point.y * m_scale];
                break;
            case sta_rect:
            {
                PDF_POINT *pt_cur = &m_rects[m_rects_cnt<<1];
                pt_cur[1].x = point.x * m_scale;
                pt_cur[1].y = point.y * m_scale;
                m_rects_cnt++;
                if( m_rects_drawing )
                {
                    m_rects_drawing = false;
                    [self refresh];
                }
                break;
            }
            case sta_ellipse:
            {
                PDF_POINT *pt_cur = &m_ellipse[m_ellipse_cnt<<1];
                pt_cur[1].x = point.x * m_scale;
                pt_cur[1].y = point.y * m_scale;
                m_ellipse_cnt++;
                if( m_ellipse_drawing )
                {
                    m_ellipse_drawing = false;
                    [self refresh];
                }
                break;
            }
            default:
            {
            }
                break;
        }
    }
    else if( cnt == 2 && m_status == sta_zoom )
    {
        m_status = sta_none;
    }
    [self refresh];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)onSwipe:(float)dx :(float)dy
{
    if( m_type == 3 || m_type == 4 )
    {
        struct PDFV_POS pos;
        [m_view vGetPos:&pos :m_w/2 :m_h/2];
        if( abs(dx) > abs(dy) )
        {
            if( m_type == 3 )
            {
                if( dx > 0 && pos.pageno > 0 )
                    [m_view vGetDeltaToCenterPage:pos.pageno - 1 :&m_swipe_dx :&m_swipe_dy];
                else if( dx < 0 && pos.pageno < [m_doc pageCount] - 1)
                    [m_view vGetDeltaToCenterPage:pos.pageno + 1 :&m_swipe_dx :&m_swipe_dy];
                else
                {
                    m_swipe_dx = -dx * m_scale / 2;
                    m_swipe_dy = -dy * m_scale / 2;
                }
            }
            else
            {
                if( dx < 0 && pos.pageno > 0 )
                    [m_view vGetDeltaToCenterPage:pos.pageno - 1 :&m_swipe_dx :&m_swipe_dy];
                else if( dx > 0 && pos.pageno < [m_doc pageCount] - 1)
                    [m_view vGetDeltaToCenterPage:pos.pageno + 1 :&m_swipe_dx :&m_swipe_dy];
                else
                {
                    m_swipe_dx = -dx * m_scale / 2;
                    m_swipe_dy = -dy * m_scale / 2;
                }
            }
        }
        else
        {
            [m_view vGetDeltaToCenterPage:pos.pageno :&m_swipe_dx :&m_swipe_dy];
        }
    }
    else
    {
        m_swipe_dx = -dx * m_scale / 2;
        m_swipe_dy = -dy * m_scale / 2;
    }
}

-(void)vSelStart
{
    if( m_status == sta_none )
        m_status = sta_sel;
}
-(void)vGetPos:(struct PDFV_POS*)pos
{
    [m_view vGetPos:pos :0 :0];
}
-(void)vSelEnd
{
    if( m_status == sta_sel )
    {
        m_status = sta_none;
    }
}

-(NSString *)vSelGetText
{
    if( m_status != sta_sel ) return nil;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos : m_tx: m_ty];
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        return [vpage GetSel];
    }
    return nil;
}

-(BOOL)vSelMarkup:(int)color :(int)type
{
    if( m_status != sta_sel ) return false;
    struct PDFV_POS pos;
    [m_view vGetPos:&pos: m_tx: m_ty];
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        m_modified = [vpage SetSelMarkup:type];
        [m_view vRenderPage:pos.pageno];
        [self refresh];
        return true;
    }
    [self refresh];
    return false;
}

-(void)vLockSide:(bool)lock
{
    /*if( lock )
        PDFV_lock(m_view, 1);
    else
        PDFV_lock(m_view, 0);*/
}

-(bool)vFindStart:(NSString *)pat :(bool)match_case :(bool)whole_word
{
    if( !pat ) return false;
    [m_view vFindStart:pat :match_case :whole_word];
    [self refresh];
    return true;
}

-(void)vFind:(int)dir
{
    if( [m_view vFind:dir] < 0 )
        if( m_delegate ) [m_delegate OnFound:false];
    [self refresh];
}
-(void)vFindEnd
{
    [m_view vFindEnd];
    [self refresh];
}

-(bool)vInkStart
{
    if( ![m_doc canSave] ) return false;
    if( m_status == sta_none )
    {
        
        m_ink = NULL;
        m_status = sta_ink;
        return true;
    }
    return false;
}

-(void)vInkCancel
{
    if( m_status == sta_ink )
    {
        m_status = sta_none;
        m_ink = NULL;
        [self refresh];
    }
}

-(void)vInkEnd
{
    if( m_status == sta_ink )
    {
        if( m_ink )
        {
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :m_tx :m_ty];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                PDFMatrix *mat = [vpage CreateMatrix2: [vpage GetVX:[m_view vGetX]]: [vpage GetVY:[m_view vGetY]]];
                PDFPage *page = [vpage GetPage];
                [mat invert];
                [mat transformInk:m_ink];
                [page addAnnotInk:m_ink];
                [m_view vRenderPage:pos.pageno];
            }
            m_modified = true;
        }
        m_status = sta_none;
        m_ink = NULL;
        [self refresh];
        
        //GEAR
        //Save Annotations
        [m_doc save];
        //END
        
    }
}
-(bool)vEllipseStart
{
    if( ![m_doc canSave] ) return false;
    if( m_status == sta_none )
    {
        m_status = sta_ellipse;
        m_ellipse_drawing = false;
        return true;
    }
    return false;
}
-(void)vEllipseCancel
{
    if( m_status == sta_ellipse )
    {
        m_ellipse_cnt = 0;
        m_ellipse_drawing = false;
        m_status = sta_none;
        [self refresh];
    }

}

-(void)vEllipseEnd
{
    if( m_status == sta_ellipse )
    {
        PDFVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_ellipse;
        PDF_POINT *pt_end = pt_cur + (m_ellipse_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :pt_cur->x :pt_cur->y];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                cur = 0;
                end = pages_cnt;
                while( cur < end )
                {
                    if( pages[cur] == vpage ) break;
                    cur++;
                }
                if( cur >= end )
                {
                    pages[cur] = vpage;
                    pages_cnt++;
                }
                if( pt_cur->x > pt_cur[1].x )
                {
                    rect.right = pt_cur->x;
                    rect.left = pt_cur[1].x;
                }
                else
                {
                    rect.left = pt_cur->x;
                    rect.right = pt_cur[1].x;
                }
                if( pt_cur->y > pt_cur[1].y )
                {
                    rect.bottom = pt_cur->y;
                    rect.top = pt_cur[1].y;
                }
                else
                {
                    rect.top = pt_cur->y;
                    rect.bottom = pt_cur[1].y;
                }
                PDFPage *page = [vpage GetPage];
                PDFMatrix *mat = [vpage CreateMatrix];
                rect.left -= [vpage GetVX:[m_view vGetX]];
                rect.right -= [vpage GetVX:[m_view vGetX]];
                rect.top -= [vpage GetVY:[m_view vGetY]];
                rect.bottom -= [vpage GetVY:[m_view vGetY]];
                [mat invert];
                [mat transformRect:&rect];
                [page addAnnotEllipse:&rect:g_rect_Width:annotOvalColor:0];
            }
            pt_cur += 2;
        }
        m_modified = (m_ellipse_cnt != 0);
        m_ellipse_cnt = 0;
        m_ellipse_drawing = false;
        m_status = sta_none;
        
        cur = 0;
        end = pages_cnt;
        while( cur < end )
        {
            [m_view vRenderPage:[pages[cur] GetPageNo]];
            cur++;
        }
        [self refresh];
        [m_doc save];
    }
}
-(bool)vRectStart
{
    if( ![m_doc canSave] ) return false;
    if( m_status == sta_none )
    {
        m_status = sta_rect;
        m_rects_drawing = false;
        return true;
    }
    return false;
}
-(void)vRectCancel
{
    if( m_status == sta_rect )
    {
        m_rects_cnt = 0;
        m_rects_drawing = false;
        m_status = sta_none;
        [self refresh];
    }
}
-(void)vRectEnd
{
    if( m_status == sta_rect )
    {
        PDFVPage *pages[128];
        int cur;
        int end;
        int pages_cnt = 0;
        PDF_POINT *pt_cur = m_rects;
        PDF_POINT *pt_end = pt_cur + (m_rects_cnt<<1);
        while( pt_cur < pt_end )
        {
            PDF_RECT rect;
            struct PDFV_POS pos;
            [m_view vGetPos:&pos :pt_cur->x :pt_cur->y];
            if( pos.pageno >= 0 )
            {
                PDFVPage *vpage = [m_view vGetPage:pos.pageno];
                cur = 0;
                end = pages_cnt;
                //PDFVPage *vpage2;
                while( cur < end )
                {
                    if( pages[cur] == vpage ) break;
                    cur++;
                }
                if( cur >= end )
                {
                    pages[cur] = vpage;
                    pages_cnt++;
                }
                if( pt_cur->x > pt_cur[1].x )
                {
                    rect.right = pt_cur->x;
                    rect.left = pt_cur[1].x;
                }
                else
                {
                    rect.left = pt_cur->x;
                    rect.right = pt_cur[1].x;
                }
                if( pt_cur->y > pt_cur[1].y )
                {
                    rect.bottom = pt_cur->y;
                    rect.top = pt_cur[1].y;
                }
                else
                {
                    rect.top = pt_cur->y;
                    rect.bottom = pt_cur[1].y;
                }
                PDFPage *page = [vpage GetPage];
                PDFMatrix *mat = [vpage CreateMatrix];
                rect.left -= [vpage GetVX:[m_view vGetX]];
                rect.right -= [vpage GetVX:[m_view vGetX]];
                rect.top -= [vpage GetVY:[m_view vGetY]];
                rect.bottom -= [vpage GetVY:[m_view vGetY]];
                [mat invert];
                [mat transformRect:&rect];
                [page addAnnotRect:&rect: g_rect_Width: g_rect_color: 0];
            }
            pt_cur += 2;
        }
        m_modified = (m_rects_cnt != 0);
        m_rects_cnt = 0;
        m_rects_drawing = false;
        m_status = sta_none;
        
        cur = 0;
        end = pages_cnt;
        while( cur < end )
        {
            [m_view vRenderPage:[pages[cur] GetPageNo]];
            cur++;
        }
        [self refresh];

        //GEAR
        //Save Annotations
       // Document_save(m_doc);
        //END
    }
}

- (void)onSingleTap:(float)x :(float)y :(NSString *)text
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos :x :y];
    //bool ret;
    if( pos.pageno >= 0 )
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return;
        float pdf_x = [vpage ToPDFX:x :[m_view vGetX]];
        float pdf_y = [vpage ToPDFY:y :[m_view vGetY]];
        PDFPage *page = [vpage GetPage];
        if( !page ) return;
        PDFAnnot *annot = [page annotAtPoint:pdf_x: pdf_y];
        if( annot )
        {
            NSString *nuri = [annot getURI];
            if(nuri)//open url
            {
                if( m_delegate )
                    [m_delegate OnOpenURL:nuri];
                return ;
            }
            int pageno = [annot getDest];
            if( pageno >= 0 )//goto page
            {
                struct PDFV_POS pos;
                pos.pageno = pageno;
                pos.x = 0;
                pos.y = [m_doc pageHeight:pageno];
                [m_view vSetPos:&pos :0 :0];
                return ;
            }
            nuri = [annot getMovie];
            if( nuri )
            {
                nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
                [annot getMovieData:nuri];
                if(m_delegate)
                    [m_delegate OnMovie:nuri];
                return;
            }
            nuri = [annot getSound];
            if( nuri )
            {
                int spara[4];
                nuri = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:nuri];
                [annot getSoundData:spara :nuri];
                if(m_delegate)
                    [m_delegate OnSound:nuri];
                return;
            }
           /*
           
            nuri = [annot getEditText];
            if (nuri)
            {
                [annot setEditText:@"test"];
                [m_view vRenderPage:pos.pageno];
                return ;
            }
            */
            nuri = [annot getPopupText];
            if( nuri )
            {
                //[annot setPopupSubject:@"test"];
                //[annot setPopupText:@"test"];
                NSString *subj = [annot getPopupSubject];
                //popup dialog to show text and subject.
                //nuri is text content.
                //subj is subject string.
                if( m_delegate )
                    [m_delegate OnSingleTapped: x: y :nuri];
                return;
            }
            
            
        }
        if( m_delegate )
            [m_delegate OnSingleTapped: x: y :nil];
        return;
    }
}
-(void)vAddTextAnnot:(int)x :(int)y :(NSString *)text
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos:x:y];
    if(pos.pageno>=0)
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return;
        PDFPage *page = [vpage GetPage];
        if( page != NULL )
        {
            PDFMatrix *mat = [vpage CreateMatrix];
            [mat invert];
            PDF_POINT pt;
            pt.x = [vpage ToDIBX:pos.x];
            pt.y = [vpage ToDIBY:pos.y];
            [mat transformPoint:&pt];
            [page addAnnotNote:&pt];
            PDFAnnot *annot = [page annotAtIndex: [page annotCount] - 1];
            [annot setPopupText:text];
            [m_view vRenderPage:pos.pageno];
            [m_doc save];

            [self refresh];

        }
    }
}
-(NSString *)vGetTextAnnot :(int)x :(int)y
{
    struct PDFV_POS pos;
    [m_view vGetPos:&pos:x:y];
    if(pos.pageno>=0)
    {
        PDFVPage *vpage = [m_view vGetPage:pos.pageno];
        if( !vpage ) return NULL;
        PDFPage *page = [vpage GetPage];
        if( !page ) return NULL;
        PDFAnnot *annot = [page annotAtPoint:pos.x: pos.y];
        NSString *ns = [annot getPopupText];
        return ns;
    }
    return nil;
}
@end
