//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"


@implementation UAGithubEngine

@synthesize delegate, username, apiKey, dataFormat;

- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate
{
	if (self = [super init]) 
	{
		[username release];
		[apiKey release];
		username = [aUsername retain];
		apiKey = [aKey retain];
		delegate = theDelegate;
		dataFormat = @"xml";
	}
	return self;
		
}

- (id)sendRequest:(NSString *)path withParameters:(NSDictionary *)params
{
	
	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/%@/%@?login=%@&token=%@", self.dataFormat, path, self.username, self.apiKey]];

	NSLog(@"Request sent: %@", theURL);
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad	timeoutInterval:30];
	NSURLResponse *response;
	NSError *error;
	//return [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	return [[NSXMLDocument alloc] initWithData:[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error] options:0 error:&error];
	
}

- (id)getRepositoriesForUser:(NSString *)aUser withWatched:(BOOL)watched
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] withParameters:nil];
	
}

- (id)getRepository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] withParameters:nil];
	
}

@end
