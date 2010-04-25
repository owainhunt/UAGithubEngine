//
//  UAGithubCommitsParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 24/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubCommitsParser.h"


@implementation UAGithubCommitsParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate requestType:(UAGithubRequestType)reqType {
	
	if (self = [super initWithXML:theXML delegate:theDelegate requestType:reqType])
	{
		dateElements = [NSArray arrayWithObjects:@"committed-date", @"authored-date", nil];
		dictionaryElements = [NSArray arrayWithObjects:@"parents", @"author", @"committer", nil];
		baseElement = @"commit";
	}
	
	[parser parse];
	
	return self;
}

@end
