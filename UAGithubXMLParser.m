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
	[xml release];
	[connectionIdentifier release];
	[lastOpenedElement release];
	[super dealloc];
	
}


- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    if (self = [super init]) {
        xml = [theXML retain];
        delegate = theDelegate;
		connectionIdentifier = [theIdentifier retain];
        requestType = reqType;
		responseType = respType;
        parsedObjects = [[NSMutableArray alloc] initWithCapacity:0];
        
        parser = [[NSXMLParser alloc] initWithData:xml];
        //[parser setDelegate:self];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldResolveExternalEntities:NO];
        

    }
    return self;
}


- (void)parser:(NSXMLParser *)theParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.lastOpenedElement = elementName;

    if ([elementName isEqualToString:baseElement]) 
	{
        NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
        [parsedObjects addObject:newNode];
        currentNode = newNode;
    } 
	else if ([arrayElements containsObject:elementName])
	{
		currentArray = [NSMutableArray arrayWithCapacity:0];
		[currentNode setObject:currentArray forKey:elementName];
	}
	else if ([dictionaryElements containsObject:elementName]) 
	{
		NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
		if (currentArray)
		{
			[currentArray addObject:newNode];
		}
		else
		{
			[currentNode setObject:newNode forKey:elementName];
		}
		parentNode = currentNode;
		currentNode = newNode;
	}
	else if (currentNode) 
	{
		[currentNode setObject:[NSMutableString string] forKey:elementName];
    }
	
}


- (void)parser:(NSXMLParser *)theParser foundCharacters:(NSString *)characters
{
    if (lastOpenedElement && currentNode && ![arrayElements containsObject:lastOpenedElement]) {
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
		//if (!currentArray)
		//{
			currentNode = parentNode;
			parentNode = nil;
		//}
	}
	else if ([arrayElements containsObject:elementName])
	{
		if (parentNode)
		{
			currentNode = parentNode;
			parentNode = nil;
		}		
		currentArray = nil;
	}
	else if ([elementName isEqualToString:baseElement]) 
	{
        currentNode = nil;
    }
	
}


- (void)parserDidEndDocument:(NSXMLParser *)theParser
{
    [delegate parsingSucceededForConnection:connectionIdentifier ofResponseType:responseType withParsedObjects:parsedObjects];
	
}


- (void)parser:(NSXMLParser *)theParser parseErrorOccurred:(NSError *)parseError
{
    [delegate parsingFailedForConnection:connectionIdentifier ofResponseType:responseType withError:parseError];
	
}



@end
