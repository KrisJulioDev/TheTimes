//
//  XMLMapParser.h
//  News International
//
//  Created by Daniel Wichett on 03/12/2009.
//  Copyright 2009 News International. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLMapParser : NSObject <NSXMLParserDelegate>
{
    NSMutableString *currentElementValue;
}

@property (nonatomic, retain) NSMutableDictionary *dict;

@end
