//
//  UAGithubCollaboratorsParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 29/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubCollaboratorsParser.h"


@implementation UAGithubCollaboratorsParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithXML:theXML delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		baseElement = @"collaborators";
	}
	
	[parser parse];
	
	return self;
}


- (void)parser:(NSXMLParser *)theParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.lastOpenedElement = elementName;
	
    if ([elementName isEqualToString:baseElement]) 
	{
        NSMutableArray *newNode = [NSMutableArray arrayWithCapacity:0];
        [parsedObjects addObject:newNode];
        theNode = newNode;
    } 
	else if (theNode) 
	{
		[theNode addObject:[NSMutableString string]];
    }
	
}


- (void)parser:(NSXMLParser *)theParser foundCharacters:(NSString *)characters
{
    if (lastOpenedElement && theNode) {
        [[theNode lastObject] appendString:characters];
    }
	
}


- (void)parser:(NSXMLParser *)theParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	self.lastOpenedElement = nil;
	
	//Process anything that shouldn't be a string
	
	if ([elementName isEqualToString:baseElement]) 
	{
        theNode = nil;
    }
	
}



@end
