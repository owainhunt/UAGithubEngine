//
//  UAGithubMilestonesJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 15/09/2011.
//  Copyright 2011 Owain R Hunt. All rights reserved.
//

#import "UAGithubMilestonesJSONParser.h"

@implementation UAGithubMilestonesJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{	
	if ((self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType]))
	{
		dateElements = [NSArray arrayWithObjects:@"created_at", @"due_on", nil];
	}
	
	[self parse];
	
	return self;
}

@end
