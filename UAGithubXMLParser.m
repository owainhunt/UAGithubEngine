//
//  UAGithubXMLParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubXMLParser.h"
#import "UAGithubParserDelegate.h"


@implementation UAGithubXMLParser

@synthesize lastOpenedElement;

- (void)dealloc
{
	[lastOpenedElement release];
	[super dealloc];
	
}


- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate requestType:(UAGithubRequestType)reqType
{
    if (self = [super init]) {
        xml = [theXML retain];
        requestType = reqType;
        delegate = theDelegate;
        parsedObjects = [[NSMutableArray alloc] initWithCapacity:0];
        
        parser = [[NSXMLParser alloc] initWithData:xml];
        [parser setDelegate:self];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldResolveExternalEntities:NO];
        

    }
    return self;
}

- (void)parser:(NSXMLParser *)theParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.lastOpenedElement = elementName;
    
    if ([elementName isEqualToString:baseElement]) {
        // Make new entry in parsedObjects.
        NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
        [parsedObjects addObject:newNode];
        currentNode = newNode;
    } else if (currentNode) {
		if ([dictionaryElements containsObject:elementName]) {
			NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
			[currentNode setObject:newNode forKey:elementName];
			parentNode = currentNode;
			currentNode = newNode;
		} else {
			[currentNode setObject:[NSMutableString string] forKey:elementName];
		}
    }
	
}


- (void)parser:(NSXMLParser *)theParser foundCharacters:(NSString *)characters
{
    if (lastOpenedElement && currentNode) {
        [[currentNode objectForKey:lastOpenedElement] appendString:characters];
    }
}


- (void)parser:(NSXMLParser *)theParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	self.lastOpenedElement = nil;
	
	//Process anything that shouldn't be a string
	
	if ([numberElements containsObject:elementName])
	{
		[currentNode setValue:[NSNumber numberWithInt:[[currentNode objectForKey:elementName] intValue]] forKey:elementName];
	}
	else if ([boolElements containsObject:elementName])
	{
		[currentNode setObject:[NSNumber numberWithBool:[[currentNode objectForKey:elementName] isEqualToString:@"true"]] forKey:elementName];
	}
	else if ([dateElements containsObject:elementName])
	{
		[currentNode setObject:[[currentNode objectForKey:elementName] dateFromGithubDateString] forKey:elementName];
	}
	else if ([dictionaryElements containsObject:elementName])
	{
		currentNode = parentNode;
	}
	else if ([elementName isEqualToString:baseElement]) 
	{
        currentNode = nil;
    }
	
}

- (void)parserDidEndDocument:(NSXMLParser *)theParser
{
    NSLog(@"Parsing complete: %@", parsedObjects);
    //[delegate parsingSucceededForRequestOfType:requestType withParsedObjects:parsedObjects];
}


@end
