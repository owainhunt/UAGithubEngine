//
//  UAGithubUsersJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubUsersJSONParser.h"
#import "CJSONDeserializer.h"

@implementation UAGithubUsersJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
	
	if (self = [super initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType])
	{
		numberElements = [NSArray arrayWithObjects:@"collaborators", @"space", @"private-repos", @"disk-usage", @"public-gist-count", @"public-repo-count", @"following-count", @"id", @"private-gist-count", @"owned-private-repo-count", @"total-private-repo-count", @"followers-count", nil];
		dateElements = [NSArray arrayWithObject:@"created_at"];
		dictionaryElements = [NSArray arrayWithObjects:@"plan", nil];
		baseElement = @"user";
	}
	
	[self parse];
	
	return self;
}


@end
