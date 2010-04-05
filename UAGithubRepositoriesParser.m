//
//  UAGithubRepositoriesParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubRepositoriesParser.h"


@implementation UAGithubRepositoriesParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate requestType:(UAGithubRequestType)reqType {
	
	if (self = [super initWithXML:theXML delegate:theDelegate requestType:reqType])
	{
		numberElements = [NSArray arrayWithObjects:@"watchers", @"forks", @"open-issues", nil];
		boolElements = [NSArray arrayWithObjects:@"has-issues", @"has-downloads", @"fork", @"has-wiki", @"private", nil];
	}
	
	[parser parse];

	return self;
}


- (void)parser:(NSXMLParser *)theParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.lastOpenedElement = elementName;
    
    if ([elementName isEqualToString:@"repository"]) {
        // Make new entry in parsedObjects.
        NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithCapacity:0];
        [parsedObjects addObject:newNode];
        currentNode = newNode;
    } else if (currentNode) {
        // Create relevant name-value pair.
        [currentNode setObject:[NSMutableString string] forKey:elementName];
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

	if ([numberElements containsObject:elementName])
	{
		[currentNode setValue:[NSNumber numberWithInt:[[currentNode objectForKey:elementName] intValue]] forKey:elementName];
	}
	else if ([boolElements containsObject:elementName])
	{
		[currentNode setObject:[NSNumber numberWithBool:[[currentNode objectForKey:elementName] isEqualToString:@"true"]] forKey:elementName];
	}
	else if ([elementName isEqualToString:@"repository"]) 
	{
        currentNode = nil;
    }
	
}


@end
