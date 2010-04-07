//
//  UAGithubCommentsParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubCommentsParser.h"


@implementation UAGithubCommentsParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate requestType:(UAGithubRequestType)reqType {
	
	if (self = [super initWithXML:theXML delegate:theDelegate requestType:reqType])
	{
		numberElements = [NSArray arrayWithObjects:@"id", nil];
		boolElements = [NSArray arrayWithObject:[NSNull null]];
		baseElement = @"comment";
	}
	
	[parser parse];
	
	return self;
}


@end
