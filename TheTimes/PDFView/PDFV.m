//
//  PDFV.m
//  PDFViewer
//
//  Created by Radaee on 13-5-26.
//
//

#import "PDFV.h"

@implementation PDFV

-(id)init
{
    if( self = [super init] )
    {
		m_x = 0;
		m_y = 0;
		m_docw = 0;
		m_doch = 0;
		m_w = 0;
		m_h = 0;
		m_scale = 0;
		m_doc = NULL;
		m_pages = NULL;
		m_pages_cnt = 0;
		m_page_gap = 0;
		m_page_gap_half = 0;
        
		m_hold_vx = 0;
		m_hold_vy = 0;
		m_hold_x = 0;
		m_hold_y = 0;
		m_back_clr = 0xFFCCCCCC;
        m_pages = nil;
        m_thread = [[PDFVThread alloc] init];
        m_finder = [[PDFVFinder alloc] init];
        m_del = NULL;
    }
    return self;
}
-(void)dealloc
{
    [self vClose];
}
-(void)vResize:(int)w :(int) h;
{
    if( w <= 0 || h <= 0 ) return;
    m_w = w;
    m_h = h;
    [self vLayout];
}
-(void)vClose
{
    
    [m_thread destroy];
    if( m_pages )
    {
        [m_pages removeAllObjects];
        m_pages = nil;
        m_pages_cnt = 0;
    }
    m_x = 0;
    m_y = 0;
    m_docw = 0;
    m_doch = 0;
    m_w = 0;
    m_h = 0;
    m_scale = 0;
    m_scale_min = 0;
    m_scale_max = 0;
    m_doc = NULL;
    m_pages = NULL;
    m_pages_cnt = 0;
    m_del = NULL;
}
-(void)vOpen:(PDFDoc *) doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    m_doc = doc;
    //m_back_clr = back_clr;
    
    m_x = 0;
    m_y = 0;
    m_docw = 0;
    m_doch = 0;
    m_scale = 0;
    m_scale_min = 0;
    m_scale_max = 0;
    m_page_gap = page_gap&(~1);
    m_page_gap_half = (m_page_gap>>1);
    
    m_pages_cnt = [m_doc pageCount];
    m_pages = [[NSMutableArray alloc] init];
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = [[PDFVPage alloc] init:m_doc :cur];
        [m_pages addObject:vpage];
        cur++;
    }
    [m_thread create:notifier:disp];
    m_del = notifier;
    [self vLayout];
}
-(bool) vFindGoto
{
    if( m_pages == NULL ) return false;
    int pg = [m_finder find_get_page];
    if( pg < 0 || pg >= [m_doc pageCount] ) return false;
    PDF_RECT pos;
    if( ![m_finder find_get_pos:&pos] ) return false;
    PDFVPage *vpage = m_pages[pg];
    pos.left = [vpage ToDIBX:pos.left] + [vpage GetX];
    pos.top = [vpage ToDIBY:pos.top] + [vpage GetY];
    pos.right = [vpage ToDIBX:pos.right] + [vpage GetX];
    pos.bottom = [vpage ToDIBY:pos.bottom] + [vpage GetY];
    float x = m_x;
    float y = m_y;
    if( x > pos.left - m_w/8 ) x = pos.left - m_w/8;
    if( x < pos.right - m_w*7/8 ) x = pos.right - m_w*7/8;
    if( y > pos.top - m_h/8 ) y = pos.top - m_h/8;
    if( y < pos.bottom - m_h*7/8 ) y = pos.bottom - m_h*7/8;
    if( x > m_docw - m_w ) x = m_docw - m_w;
    if( x < 0 ) x = 0;
    if( y > m_doch - m_h ) y = m_doch - m_h;
    if( y < 0 ) y = 0;
    m_x = x;
    m_y = y;
    return true;
}
-(void)vSetPos:(const struct PDFV_POS *)pos :(int)x :(int) y
{
    if( m_w <= 0 || m_h <= 0 || !m_pages ) return;
    PDFVPage *cur = m_pages[pos->pageno];
    m_x = [cur GetX] + [cur ToDIBX:pos->x] - x;
    m_y = [cur GetY] + [cur ToDIBY:pos->y] - y;
}
-(bool)vNeedRefresh
{
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        if( ![vpage IsFinished] ) return true;
        cur++;
    }
    return false;
}
-(void)vDraw :(PDFVCanvas *)canvas :(bool)zooming
{
    if( m_w <= 0 || m_h <= 0 ) return;
    if( m_x + m_w > m_docw ) m_x = m_docw - m_w;
    if( m_y + m_h > m_doch ) m_y = m_doch - m_h;
    if( m_x < 0 ) m_x = 0;
    if( m_y < 0 ) m_y = 0;
    NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000;
    [canvas FillRect:CGRectMake(0, 0, m_w, m_h) :m_back_clr];
    int cur = 0;
    int end = m_pages_cnt;
    int find_page = [m_finder find_get_page];
    if( zooming )
    {
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            if( [vpage IsCrossed: m_x: m_y: m_w: m_h] )
            {
                [vpage Draw: canvas: m_x: m_y];
                if( m_del ) [m_del OnPageDisplayed:[canvas context]:vpage];
                if( cur == find_page )
                    [m_finder find_draw:canvas : vpage:m_x :m_y];
            }
            cur++;
        }
    }
    else
    {
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            if( [vpage IsCrossed: m_x: m_y: m_w: m_h] )
            {
                if( ![vpage NeedBmp] ) [vpage DeleteBmp];
                [m_thread start_render:vpage];
                [vpage Draw: canvas: m_x: m_y];
                if( m_del ) [m_del OnPageDisplayed:[canvas context]:vpage];
                if( cur == find_page )
                    [m_finder find_draw:canvas : vpage:m_x :m_y];
            }
            else
            {
                [vpage DeleteBmp];
                [m_thread end_render:vpage];
            }
            cur++;
        }
    }
    NSTimeInterval time2 = [[NSDate date] timeIntervalSince1970]*1000 - time1;
    time2 = 0;
}
-(PDFVPage *)vGetPage:(int) pageno
{return m_pages[pageno];}
-(void)vFindStart:(NSString *)pat : (bool)match_case :(bool)whole_word
{
    struct PDFV_POS pos;
    [self vGetPos:&pos: 0: 0];
    [m_finder find_start :m_doc :pos.pageno :pat :match_case :whole_word];
}
-(int)vFind:(int) dir
{
    if( m_pages == nil ) return -1;
    int ret = [m_finder find_prepare:dir];
    if( ret == 1 )
    {
        [self vFindGoto];
        return 0;//succeeded
    }
    if( ret == 0 )
    {
        return -1;//failed
    }
    [m_thread start_find: m_finder];
    return 1;
}
-(void)vFindEnd
{
    if( m_pages == NULL ) return;
    [m_finder find_end];
}
-(void)vRenderPage:(int)pageno
{
    [m_thread end_render:m_pages[pageno]];
    [m_thread start_render:m_pages[pageno]];
}
-(void)vOnTouchDown:(int)x :(int)y;
{
    m_hold_vx = x;
    m_hold_vy = y;
    m_hold_x = m_x;
    m_hold_y = m_y;
}
-(void)vOnTouchMove:(int)x : (int)y
{
    m_x = m_hold_x + (m_hold_vx - x);
    m_y = m_hold_y + (m_hold_vy - y);
}
-(void)vGetDeltaToCenterPage:(int)pageno : (int *)dx : (int *)dy
{
    if( m_pages == NULL || m_doc == NULL || m_w <= 0 || m_h <= 0 ) return;
    PDFVPage *vpage = m_pages[pageno];
    int left = [vpage GetX] - m_page_gap/2;
    int top = [vpage GetY] - m_page_gap/2;
    int w = [vpage GetWidth] + m_page_gap;
    int h = [vpage GetHeight] + m_page_gap;
    int x = left + (w - m_w)/2;
    int y = top + (h - m_h)/2;
    *dx = x - m_x;
    *dy = y - m_y;
}
-(void)vMoveDelta:(int)dx : (int)dy
{
    m_x += dx;
    m_y += dy;
}
-(void)vZoomStart
{
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage CreateBmp];
        [m_thread end_render:vpage];
        cur++;
    }
}
-(float)vGetScale
{return m_scale;}
-(void)vSetScale:(float) scale
{
    m_scale = scale;
    [self vLayout];
}
-(void)vSetSel:(int)x1 : (int)y1 : (int)x2 : (int)y2
{
    struct PDFV_POS pos;
    [self vGetPos: &pos: x1: y1];
    if( pos.pageno < 0 ) return;
    PDFVPage *vpage = m_pages[pos.pageno];
    [vpage SetSel: x1: y1: x2: y2: m_x: m_y];
}
-(void)vClearSel
{
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage ClearSel];
        cur++;
    }
}
-(int)vGetX
{return m_x;}
-(int)vGetY
{return m_y;}
-(int)vGetDocW
{return m_docw;}
-(int)vGetDocH
{return m_doch;}
@end

@implementation PDFVVert
-(void)vLayout
{
    if( m_w <= 0 || m_h <= 0 || !m_pages ) return;
    float max_w = [m_doc pageWidth:0];
    float max_h = [m_doc pageHeight:0];
    int pcur = 1;
    for( pcur = 1; pcur < m_pages_cnt; pcur++ )
    {
        float pw = [m_doc pageWidth:pcur];
        float ph = [m_doc pageHeight:pcur];
        if( max_w < pw ) max_w = pw;
        if( max_h < ph ) max_h = ph;
    }
    m_scale_min = (m_w - m_page_gap) / max_w;
    m_scale_max = m_scale_min * zoomLevel;
    if( m_scale < m_scale_min ) m_scale = m_scale_min;
    if( m_scale > m_scale_max ) m_scale = m_scale_max;
    int cur = 0;
    int end = m_pages_cnt;
    int left = m_page_gap_half;
    int top = m_page_gap_half;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        [vpage SetRect:left:top:m_scale];
        top += [vpage GetHeight] + m_page_gap;
        cur++;
    }
    m_docw = max_w * m_scale;
    m_doch = top - m_page_gap_half;
}
-(void)vGetPos:(struct PDFV_POS *)pos : (int)x : (int) y
{
    if( m_w <= 0 || m_h <= 0 || !m_pages )
    {
        pos->pageno = -1;
        pos->x = 0;
        pos->y = 0;
        return;
    }
    int x1 = x + m_x;
    int y1 = y + m_y;
    int cur = 0;
    int end = m_pages_cnt;
    while( cur < end )
    {
        PDFVPage *vpage = m_pages[cur];
        if( y1 < [vpage GetY] ) break;
        cur++;
    }
    if( cur > 0 ) cur--;
    PDFVPage *vpage = m_pages[cur];
    pos->pageno = [vpage GetPageNo];
    pos->x = [vpage ToPDFX:x: m_x];
    pos->y = [vpage ToPDFY:y: m_y];
}
-(void)vGetDelta:(int)delta : (int *)dx : (int *)dy;
{
    dy[0] += delta;
}
@end

@implementation PDFVHorz
-(id)init:(bool)rtol
{
    if( self = [super init] )
    {
        m_rtol = rtol;
    }
    return self;
}
-(void)vOpen:(PDFDoc *) doc :(int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *) disp;
{
    [super vOpen :doc :page_gap :notifier :disp];
    if( m_rtol ) m_x = m_docw;
}

-(void)vResize:(int)w : (int)h
{
    bool set = (m_rtol && (m_w <= 0 || m_h <= 0));
    [super vResize : w : h];
    if( set ) m_x = m_docw;
}
-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    int cur = 0;
    int cnt = [m_doc pageCount];
    float maxh = 0;
    while( cur < cnt )
    {
        float h = [m_doc pageHeight:cur];
        if( maxh < h ) maxh = h;
        cur++;
    }
    m_scale_min = ((float)(m_h - m_page_gap)) / maxh;
    m_scale_max = m_scale_min * zoomLevel;
    if( m_scale < m_scale_min ) m_scale = m_scale_min;
    if( m_scale > m_scale_max ) m_scale = m_scale_max;
    
    int left = m_page_gap_half;
    int top = m_page_gap_half;
    m_docw = 0;
    m_doch = 0;
    if( m_rtol )
    {
        cur = cnt - 1;
        while( cur >= 0 )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            left += [vpage GetWidth] + m_page_gap;
            if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
            cur--;
        }
    }
    else
    {
        cur = 0;
        while( cur < cnt )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            left += [vpage GetWidth] + m_page_gap;
            if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
            cur++;
        }
    }
    m_docw = left;
}
-(void)vGetPos:(struct PDFV_POS *)pos : (int) x : (int) y
{
    if( m_w <= 0 || m_h <= 0 || !m_pages )
    {
        pos->pageno = -1;
        pos->x = 0;
        pos->y = 0;
        return;
    }
    int x1 = x + m_x;
    int y1 = y + m_y;
    int cur = 0;
    int end = m_pages_cnt;
    if( m_rtol )
    {
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            if( x1 >= [vpage GetX] ) break;
            cur++;
        }
        if( cur == end ) cur--;
    }
    else
    {
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            if( x1 < [vpage GetX] ) break;
            cur++;
        }
        if( cur > 0 ) cur--;
    }
    PDFVPage *vpage = m_pages[cur];
    pos->pageno = [vpage GetPageNo];
    pos->x = [vpage ToPDFX: x: m_x ];
    pos->y = [vpage ToPDFY: y: m_y ];
}

-(void)vGetDelta:(int)delta : (int *)dx : (int *)dy
{
    dx[0] += delta;
}

@end

@implementation PDFVDual
-(id)init:(bool)rtol : (const bool *)verts : (int)verts_cnt : (const bool *)horzs : (int)horzs_cnt;
{
    if( self = [super init] )
    {
        if( verts && verts_cnt > 0 )
        {
            m_vert_dual = (bool *)malloc( sizeof( bool ) * verts_cnt );
            memcpy( m_vert_dual, verts, sizeof( bool ) * verts_cnt );
            m_vert_dual_cnt = verts_cnt;
        }
        else
        {
            m_vert_dual = NULL;
            m_vert_dual_cnt = 0;
        }
        if( horzs && horzs_cnt > 0 )
        {
            m_horz_dual = (bool *)malloc( sizeof( bool ) * horzs_cnt );
            memcpy( m_horz_dual, horzs, sizeof( bool ) * horzs_cnt );
            m_horz_dual_cnt = horzs_cnt;
        }
        else
        {
            m_horz_dual = NULL;
            m_horz_dual_cnt = 0;
        }
        m_cells = NULL;
        m_cells_cnt = 0;
        m_rtol = rtol;
    }
    return self;
}
-(void)vClose
{
    [super vClose];
    if( m_cells )
    {
        free( m_cells );
        m_cells = NULL;
        m_cells_cnt = 0;
    }
    if( m_vert_dual )
    {
        free( m_vert_dual );
        m_vert_dual = NULL;
        m_vert_dual_cnt = 0;
    }
    if( m_horz_dual )
    {
        free( m_horz_dual );
        m_horz_dual = NULL;
        m_horz_dual_cnt = 0;
    }
}
-(void)vOpen:(PDFDoc *)doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    [super vOpen:doc: page_gap: notifier: disp];
    if( m_rtol ) m_x = m_docw;
}
-(void)vResize:(int)w : (int)h
{
    bool set = (m_rtol && (m_w <=0 || m_h <= 0));
    [super vResize:w: h];
    if( set ) m_x = m_docw;
}
-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    int pcur = 0;
    int pcnt = [m_doc pageCount];
    int ccur = 0;
    int ccnt = 0;
    float max_w = 0;
    float max_h = 0;
    if( m_h > m_w )//vertical
    {
        while( pcur < pcnt )
        {
            if( m_vert_dual != NULL && ccnt < m_vert_dual_cnt && m_vert_dual[ccnt] && pcur < pcnt - 1 )
            {
                float w = [m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                h = [m_doc pageHeight:pcur + 1];
                if( max_h < h ) max_h = h;
                pcur += 2;
            }
            else
            {
                float w = [m_doc pageWidth:pcur];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                pcur++;
            }
            ccnt++;
        }
        float scale1 = ((float)(m_h - m_page_gap)) / max_h;
        m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
        if( m_scale_min > scale1 ) m_scale_min = scale1;
        m_scale_max = m_scale_min * zoomLevel;
        if( m_scale < m_scale_min ) m_scale = m_scale_min;
        if( m_scale > m_scale_max ) m_scale = m_scale_max;
        m_doch = (int)(max_h * m_scale) + m_page_gap;
        if( m_doch < m_h ) m_doch = m_h;
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pcur = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( m_vert_dual != NULL && ccur < m_vert_dual_cnt && m_vert_dual[ccur] && pcur < pcnt - 1 )
            {
                w = (int)( ([m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1]) * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = pcur + 1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2:(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                [m_pages[pcur + 1] SetRect:[m_pages[pcur] GetX] + [m_pages[pcur] GetWidth]:
                                        (m_doch - [m_doc pageHeight:pcur+1] * m_scale) / 2: m_scale];
                pcur += 2;
            }
            else
            {
                w = (int)( [m_doc pageWidth:pcur] * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                pcur++;
            }
            left += cw;
            cell++;
            ccur++;
        }
        m_docw = left;
    }
    else
    {
        while( pcur < pcnt )
        {
            if( (m_horz_dual == NULL || ccnt >= m_horz_dual_cnt || m_horz_dual[ccnt]) && pcur < pcnt - 1 )
            {
                float w = [m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                h = [m_doc pageHeight:pcur + 1];
                if( max_h < h ) max_h = h;
                pcur += 2;
            }
            else
            {
                float w = [m_doc pageWidth:pcur];
                if( max_w < w ) max_w = w;
                float h = [m_doc pageHeight:pcur];
                if( max_h < h ) max_h = h;
                pcur++;
            }
            ccnt++;
        }
        m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
        float scale = ((float)(m_h - m_page_gap)) / max_h;
        if( m_scale_min > scale ) m_scale_min = scale;
        m_scale_max = m_scale_min * zoomLevel;
        if( m_scale < m_scale_min ) m_scale = m_scale_min;
        if( m_scale > m_scale_max ) m_scale = m_scale_max;
        m_doch = (int)(max_h * m_scale) + m_page_gap;
        if( m_doch < m_h ) m_doch = m_h;
        if( m_cells ) free( m_cells );
        m_cells = (struct PDFCell *)malloc( sizeof(struct PDFCell) * ccnt );
        m_cells_cnt = ccnt;
        pcur = 0;
        ccur = 0;
        int left = 0;
        struct PDFCell *cell = m_cells;
        while( ccur < ccnt )
        {
            int w = 0;
            int cw = 0;
            if( (m_horz_dual == NULL || ccur >= m_horz_dual_cnt || m_horz_dual[ccur]) && pcur < pcnt - 1 )
            {
                w = (int)( ([m_doc pageWidth:pcur] + [m_doc pageWidth:pcur + 1]) * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = pcur + 1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2: (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                [m_pages[pcur + 1] SetRect:[m_pages[pcur] GetX] + [m_pages[pcur] GetWidth]:
                        (int)(m_doch - [m_doc pageHeight:pcur+1] * m_scale) / 2: m_scale];
                pcur += 2;
            }
            else
            {
                w = (int)( [m_doc pageWidth:pcur] * m_scale );
                if( w + m_page_gap < m_w ) cw = m_w;
                else cw = w + m_page_gap;
                cell->page_left = pcur;
                cell->page_right = -1;
                cell->left = left;
                cell->right = left + cw;
                [m_pages[pcur] SetRect:left + (cw - w)/2:
                        (int)(m_doch - [m_doc pageHeight:pcur] * m_scale) / 2: m_scale];
                pcur++;
            }
            left += cw;
            cell++;
            ccur++;
        }
        m_docw = left;
    }
    if( m_rtol )
    {
        struct PDFCell *ccur = m_cells;
        struct PDFCell *cend = ccur + m_cells_cnt;
        while( ccur < cend )
        {
            int tmp = ccur->left;
            ccur->left = m_docw - ccur->right;
            ccur->right = m_docw - tmp;
            if( ccur->page_right >= 0 )
            {
                tmp = ccur->page_left;
                ccur->page_left = ccur->page_right;
                ccur->page_right = tmp;
            }
            ccur++;
        }
        int cur = 0;
        int end = m_pages_cnt;
        while( cur < end )
        {
            PDFVPage *vpage = m_pages[cur];
            int x = m_docw - ([vpage GetX] + [vpage GetWidth]);
            int y = [vpage GetY];
            [vpage SetRect: x: y: m_scale];
            cur++;
        }
    }
}
-(void)vGetPos:(struct PDFV_POS *)pos : (int) x : (int) y
{
    pos->pageno = -1;
    pos->x = 0;
    pos->y = 0;
    if( m_pages == nil ) return;
    struct PDFCell *ccur = m_cells;
    struct PDFCell *cend = ccur + m_cells_cnt;
    x += m_x;
    y += m_y;
    while( ccur < cend )
    {
        if( x >= ccur->left && x < ccur->right )
        {
            pos->pageno = ccur->page_left;
            PDFVPage *vpage = m_pages[pos->pageno];
            if( ccur->page_right >= 0 )
            {
                if( x >= [vpage GetX] + [vpage GetWidth] )
                {
                    pos->pageno = ccur->page_right;
                    vpage = m_pages[pos->pageno];
                }
            }
            pos->x = (x - [vpage GetX])/m_scale;
            pos->y = [m_doc pageHeight:pos->pageno] - (y - [vpage GetY])/m_scale;
            return;
        }
        ccur++;
    }
    return;
}
-(void)vGetDelta:(int)delta :(int *)dx : (int *)dy
{
    dx[0] += delta;
}
-(void)vGetDeltaToCenterPage:(int)pageno : (int *)dx : (int *)dy
{
    if( m_pages == NULL || m_doc == NULL || m_w <= 0 || m_h <= 0 ) return;
    struct PDFCell *ccur = m_cells;
    struct PDFCell *cend = ccur + m_cells_cnt;
    while( ccur < cend )
    {
        if( pageno == ccur->page_left || pageno == ccur->page_right )
        {
            int left = ccur->left;
            int w = ccur->right - left;
            int x = left + (w - m_w)/2;
            *dx = x - m_x;
            break;
        }
        ccur++;
    }
}

@end

@implementation PDFVThmb
-(id)init:(int)orientation :(bool)rtol
{
    if( self = [super init] )
    {
        m_orientation = orientation;
        m_rtol = rtol;
        if( rtol && orientation == 0 ) m_x = 0x7FFFFFFF;
    }
    return self;
}

-(void)vOpen:(PDFDoc *)doc : (int)page_gap :(id<PDFVInnerDel>)notifier :(const struct PDFVThreadBack *)disp
{
    [super vOpen :doc :page_gap :notifier :disp];
    if( m_rtol && m_orientation == 0 ) m_x = 0x7FFFFFFF;
}

-(void)vClose
{
    [super vClose];
		m_sel = 0;
}

-(void)vLayout
{
    if( m_doc == NULL || m_w <= m_page_gap || m_h <= m_page_gap ) return;
    int cur = 0;
    int cnt = [m_doc pageCount];
    if( m_orientation == 0 )//horz
    {
        float maxh = 0;
        while( cur < cnt )
        {
            float h = [m_doc pageHeight:cur];
            if( maxh < h ) maxh = h;
            cur++;
        }
        m_scale_min = ((float)(m_h - m_page_gap)) / maxh;
        m_scale_max = m_scale_min * zoomLevel;
        m_scale = m_scale_min;
        
        int left = m_w/2;
        int top = m_page_gap / 2;
        cur = 0;
        m_docw = 0;
        m_doch = 0;
        if( m_rtol )
        {
            cur = cnt - 1;
            while( cur >= 0 )
            {
                PDFVPage *vpage = m_pages[cur];
                [vpage SetRect:left: top: m_scale];
                left += [vpage GetWidth] + m_page_gap;
                if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
                cur--;
            }
            m_docw = left + m_w/2;
        }
        else
        {
            while( cur < cnt )
            {
                PDFVPage *vpage = m_pages[cur];
                [vpage SetRect:left: top: m_scale];
                left += [vpage GetWidth] + m_page_gap;
                if( m_doch < [vpage GetHeight] ) m_doch = [vpage GetHeight];
                cur++;
            }
            m_docw = left + m_w/2;
        }
    }
    else
    {
        float maxw = 0;
        while( cur < cnt )
        {
            float w = [m_doc pageWidth:cur];
            if( maxw < w ) maxw = w;
            cur++;
        }
        m_scale_min = ((float)(m_w - m_page_gap)) / maxw;
        m_scale_max = m_scale_min * zoomLevel;
        m_scale = m_scale_min;
        
        int left = m_page_gap / 2;
        int top = m_h/2;
        cur = 0;
        m_docw = 0;
        m_doch = 0;
        while( cur < cnt )
        {
            PDFVPage *vpage = m_pages[cur];
            [vpage SetRect:left: top: m_scale];
            top += [vpage GetHeight] + m_page_gap;
            if( m_docw < [vpage GetWidth] ) m_docw = [vpage GetWidth];
            cur++;
        }
        m_doch = top + m_h/2;
    }
}

-(void)vGetPos:(struct PDFV_POS *)pos :(int)x : (int)y
{
    if( m_w <= 0 || m_h <= 0 || !m_doc )
    {
        pos->pageno = -1;
        pos->x = 0;
        pos->y = 0;
        return;
    }
    pos->x = m_x + x;
    pos->y = m_y + y;
    pos->pageno = 0;
    int cnt = [m_doc pageCount] - 1;
    if( m_orientation == 0 )
    {
        PDFVPage *vpage = m_pages[pos->pageno];
        if( m_rtol )
        {
            int left = [vpage GetX];
            while( pos->x < left && pos->pageno < cnt )
            {
                pos->pageno++;
                vpage = m_pages[pos->pageno];
                left = [vpage GetX];
            }
            pos->x -= [vpage GetX];
        }
        else
        {
            int right = [vpage GetX] + [vpage GetWidth] + m_page_gap;
            while( pos->x > right && pos->pageno < cnt )
            {
                pos->pageno++;
                vpage = m_pages[pos->pageno];
                right = [vpage GetX] + [vpage GetWidth] + m_page_gap;
            }
            pos->x -= [vpage GetX];
        }
    }
    else
    {
        PDFVPage *vpage = m_pages[pos->pageno];
        int bottom = [vpage GetY] + [vpage GetHeight] + m_page_gap;
        while( pos->y > bottom && pos->pageno < cnt )
        {
            pos->pageno++;
            vpage = m_pages[pos->pageno];
            bottom = [vpage GetY] + [vpage GetHeight] + m_page_gap;
        }
        pos->y -= [vpage GetY];
    }
    pos->x /= m_scale;
    pos->y = [m_doc pageHeight:pos->pageno] - pos->y / m_scale;
}

-(void)vDraw:(PDFVCanvas *)canvas :(bool)zooming
{
    if( m_w <= 0 || m_h <= 0 || !m_doc ) return;
    int disp_start = -1;
    int disp_end = -1;
    int left = m_x;
    int top = m_y;
    int left1 = left;
    int top1 = top;
    if( left1 > m_docw - m_w ) left1 = m_docw - m_w;
    if( left1 < 0 ) left1 = 0;
    if( top1 > m_doch - m_h ) top1 = m_doch - m_h;
    if( top1 < 0 ) top1 = 0;
    if( top1 != top || left1 != left )
    {
        m_x = left1;
        m_y = top1;
        left = left1;
        top = top1;
    }
    int right = left + m_w;
    int bottom = top + m_h;
    int cur = 0;
    int cnt = [m_doc pageCount];
    
    cur = 0;
    //NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970]*1000;
    [canvas FillRect:CGRectMake(0, 0, m_w, m_h) :m_back_clr];
    while( cur < cnt )
    {
        PDFVPage *vpage = m_pages[cur];
        int pl = [vpage GetX];
        int pt = [vpage GetY];
        int pr = pl + [vpage GetWidth];
        int pb = pt + [vpage GetHeight];
        if( pr > left && pb > top && pl < right && pt < bottom )
        {
            [m_thread start_thumb:vpage];
            [vpage DrawThumb:canvas: left: top];
            if( m_del ) [m_del OnPageDisplayed:[canvas context]:vpage];
            if( disp_start < 0 ) disp_start = cur;
        }
        else
        {
            [m_thread end_thumb:vpage];
            if( disp_start >= 0 && disp_end < 0 ) disp_end = cur;
        }
        cur++;
    }
    
    PDFVPage *vpage = m_pages[m_sel];
    left = [vpage GetVX:m_x];
    top = [vpage GetVY:m_y];
    [canvas FillRect:CGRectMake(left, top, [vpage GetWidth], [vpage GetHeight]) :selColor];

    //NSTimeInterval time2 = [[NSDate date] timeIntervalSince1970] * 1000 - time1;
    //time2 = 0;
}
-(void)vSetSel:(int)pageno
{
    if( !m_doc ) return;
    if( pageno >= 0 && pageno < [m_doc pageCount] )
        m_sel = pageno;
}
-(int)vGetSel
{
    return m_sel;
}

-(void)vRenderPage:(int)pageno
{
    [m_thread end_thumb:m_pages[pageno]];
    [m_thread start_thumb:m_pages[pageno]];
}

@end