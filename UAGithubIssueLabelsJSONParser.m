//
//  UAGithubIssueLabelsJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 28/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubIssueLabelsJSONParser.h"


@implementation UAGithubIssueLabelsJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	if (self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
	}
	
	[self parse];
	
	return self;
}


@end
