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


#pragma mark Initializer


- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate
{
	if (self = [super init]) 
	{
		username = [aUsername retain];
		apiKey = [aKey retain];
		delegate = theDelegate;
		dataFormat = @"xml";
	}
	
	return self;
		
}


- (void)dealloc
{
	[username release];
	[apiKey release];
	[dataFormat release];
	delegate = nil;
	
	[super dealloc];
	
}


- (id)sendRequest:(NSString *)path withParameters:(NSDictionary *)params
{
	
	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/%@/%@?login=%@&token=%@", self.dataFormat, path, self.username, self.apiKey]];

	NSLog(@"Request sent: %@", theURL);
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad	timeoutInterval:30];
	NSURLResponse *response;
	NSError *error;
	return [[NSXMLDocument alloc] initWithData:[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error] options:0 error:&error];
	
}


#pragma mark Repositories


- (id)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] withParameters:nil];
	
}


- (id)getRepository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] withParameters:nil];
	
}


#pragma mark Issues 

/*
 
 - (id)getIssuesForRepository:(NSString *)repositoryPath;
 - (id)getIssue:(NSString *)issuePath;
 - (id)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
 - (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
 - (id)closeIssue:(NSString *)issuePath;
 - (id)reopenIssue:(NSString *)issuePath;
 
 */


#pragma mark Labels

/*
 
 - (id)getLabelsForRepository:(NSString *)repositoryPath;
 - (id)getIssuesForLabel:(NSString *)label;
 - (id)addLabelForRepository:(NSString *)repositoryPath;
 - (id)addLabel:(NSString *)label toIssue:(NSString *)issuePath;
 - (id)removeLabel:(NSString *)label fromIssue:(NSString *)issuePath;
 
 */


#pragma mark Comments

/*
 
 - (id)getCommentsForIssue:(NSString *)issuePath;
 - (id)addComment:(NSString *)comment toIssue:(NSString *)issuePath;
 
 */


#pragma mark Users

/*
 
 - (id)getUser:(NSString *)username;
 
 */

@end
