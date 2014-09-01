//
//  XmlParser.m
//  News International
//
//  Created by Daniel Wichett on 24/11/2009.
//  Copyright 2009 News International. All rights reserved.
//
//  Central parser

#import "XMLParser.h"

@implementation XMLParser

- (id) init
{
	self = [super init];
	if (self != nil)
	{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        self.elements = [[NSMutableArray alloc] init];
        self.config = [[Config alloc] init];
	}
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString:@"feed"])
    {
        feed = [[Feed alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if(!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [currentElementValue appendString:string];    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"feed"])
    {
        if (_config.feeds == nil) { _config.feeds = [[NSMutableArray alloc] init]; }
        [_config.feeds addObject:feed];
        feed = nil;
    }
    else if (currentElementValue)
    {
        NSString *trimmedValue = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //id is a reserved keyword so we use myid on the objects.
        if ([@"id" isEqualToString:elementName]) { elementName = @"myid"; }
        
        if (feed != nil && elementName != nil)
        {
            [feed setValue:trimmedValue forKey:elementName];
        }
        else if (_config != nil && elementName != nil)
        {
            if ([@"feeds" isEqualToString:elementName]) {}
            else
            {
                [_config setValue:trimmedValue forKey:elementName];
            }
        }
    }
    
    currentElementValue = nil;
}

- (int) blankInt:(NSString *)string
{
    if (string == nil || [string isEqualToString:@""]) { return -1; }
    return [string intValue];
}


@end
