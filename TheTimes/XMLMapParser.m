//
//  XMLMapParser.m
//  News International
//
//  Created by Daniel Wichett on 03/12/2009.
//  Copyright 2009 News International. All rights reserved.
//
//  Parses XML into a dictionary of NSStrings.

#import "XMLMapParser.h"

@implementation XMLMapParser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.dict = [[NSMutableDictionary alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [currentElementValue appendString:string];    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if (currentElementValue != nil)
    {
        [_dict setObject:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    }

    currentElementValue = nil;
}

@end
