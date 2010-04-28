//
//  UAGithubCommitParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 24/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubCommitParser.h"


@implementation UAGithubCommitParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithXML:theXML delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		dateElements = [NSArray arrayWithObjects:@"committed-date", @"authored-date", nil];
		dictionaryElements = [NSArray arrayWithObjects:@"modified", @"removed", @"parents", @"author", @"committer", nil];
		baseElement = @"commit";
	}
	
	[parser parse];
	
	return self;
}


@end
