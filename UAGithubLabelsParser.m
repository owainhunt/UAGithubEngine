//
//  UAGithubLabelsParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubLabelsParser.h"


@implementation UAGithubLabelsParser

- (id)initWithXML:(NSData *)theXML delegate:(id)theDelegate requestType:(UAGithubRequestType)reqType {
	
	if (self = [super initWithXML:theXML delegate:theDelegate requestType:reqType])
	{
		numberElements = [NSArray arrayWithObject:[NSNull null]];
		boolElements = [NSArray arrayWithObject:[NSNull null]];
		dateElements = [NSArray arrayWithObject:[NSNull null]];
		baseElement = @"label";
	}
	
	[parser parse];
	
	return self;
}


@end
