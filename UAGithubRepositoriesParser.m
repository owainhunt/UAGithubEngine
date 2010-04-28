//
//  UAGithubRepositoriesParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubRepositoriesParser.h"


@implementation UAGithubRepositoriesParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if (self = [super initWithXML:theXML delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		numberElements = [NSArray arrayWithObjects:@"watchers", @"forks", @"open-issues", nil];
		boolElements = [NSArray arrayWithObjects:@"has-issues", @"has-downloads", @"fork", @"has-wiki", @"private", nil];
		baseElement = @"repository";
	}
	
	[parser parse];

	return self;
}


@end
