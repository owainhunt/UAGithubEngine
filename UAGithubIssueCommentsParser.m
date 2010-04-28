//
//  UAGithubCommentsParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubIssueCommentsParser.h"


@implementation UAGithubIssueCommentsParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithXML:theXML delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		numberElements = [NSArray arrayWithObjects:@"id", nil];
		dateElements = [NSArray arrayWithObjects:@"created-at", @"updated-at", nil];
		baseElement = @"comment";
	}
	
	[parser parse];
	
	return self;
}


@end
