//
//  XmlParser.h
//  News International
//
//  Created by Daniel Wichett on 24/11/2009.
//  Copyright 2009 News International. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "Feed.h"

@interface XMLParser : NSObject <NSXMLParserDelegate>
{
    NSMutableString *currentElementValue;

    Feed *feed;
    NSMutableArray *questions;
    
    NSDateFormatter *dateFormatter;
    BOOL inError;
}

@property (nonatomic, retain) NSString *errorText;
@property (nonatomic, retain) NSMutableArray *elements;
@property (nonatomic, retain) Config *config;

@end