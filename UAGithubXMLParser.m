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


- (void)parserDidEndDocument:(NSXMLParser *)theParser
{
    NSLog(@"Parsing complete: %@", parsedObjects);
    [delegate parsingSucceededForRequestOfType:requestType withParsedObjects:parsedObjects];
}


@end
