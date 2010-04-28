//
//  UAGithubIssuesParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubIssuesParser.h"


@implementation UAGithubIssuesParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithXML:theXML delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		numberElements = [NSArray arrayWithObjects:@"number", @"votes", @"comments", nil];
		dateElements = [NSArray arrayWithObjects:@"created-at", @"updated-at", nil];
		arrayElements = [NSArray arrayWithObject:@"labels"];
		dictionaryElements = [NSArray arrayWithObject:@"label"];
		baseElement = @"issue";
	}
	
	[parser parse];
	
	return self;
}


@end
