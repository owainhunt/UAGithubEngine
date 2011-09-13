//
//  UAGithubOrganizationsJSONParser.m
//  UAGithubEngine
//
//  Created by Oscar Del Ben on 9/13/11.
//  Copyright (c) 2011 Fructivity. All rights reserved.
//

#import "UAGithubOrganizationsJSONParser.h"

@implementation UAGithubOrganizationsJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	if ((self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType]))
	{

	}
	
	[self parse];
	
	return self;
}

@end
