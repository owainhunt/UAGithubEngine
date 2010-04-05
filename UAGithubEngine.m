//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAGithubEngineRequestTypes.h"


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


- (NSData *)sendRequest:(NSString *)path withParameters:(NSDictionary *)params
{
	
	NSMutableString *querystring = nil;
	if (![params isEqual:nil]) 
	{
		querystring = [NSMutableString stringWithFormat:@"&"];
		for (NSString *key in [params allKeys]) {
			[querystring appendFormat:@"%@=%@", key, [params valueForKey:key]];
		}
	}
	
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://github.com/api/v2/%@/%@?login=%@&token=%@", self.dataFormat, path, self.username, self.apiKey];
	if (![querystring isEqual:nil])
	{
		[urlString appendString:querystring];
	}
	
	NSURL *theURL = [NSURL URLWithString:urlString];
	NSLog(@"Request sent: %@", theURL);
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad	timeoutInterval:30];
	NSURLResponse *response;
	NSError *error;
	return [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
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

- (id)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType
{
	id theData;
	switch (requestType) {
		case UAGithubAllIssuesRequest:
		{	
			theData = [[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] withParameters:nil] mutableCopy];
			[theData appendData:[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] withParameters:nil]];
		}
			break;
		case UAGithubOpenIssuesRequest:
		{
			theData = [self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] withParameters:nil];
		}
			break;
		case UAGithubClosedIssuesRequest:
		{
			theData = [self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] withParameters:nil];
		}
			break;
		default:
			break;
	}
	return theData;
	
}


- (id)getIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/show/%@", issuePath] withParameters:nil];
	
}


- (id)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/edit/%@", issuePath] withParameters:issueDictionary];
	
}


- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/open/%@", repositoryPath] withParameters:issueDictionary];
	
}


- (id)closeIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] withParameters:nil];
	
}


- (id)reopenIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] withParameters:nil];
	
}


#pragma mark Labels

- (id)getLabelsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/labels/%@", repositoryPath] withParameters:nil];
	
}


- (id)addLabel:(NSString *)label toIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@/%@", repositoryPath, label, issueNumber] withParameters:nil];
	
}


- (id)removeLabel:(NSString *)label fromIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@/%@", repositoryPath, label, issueNumber] withParameters:nil];
	
}


#pragma mark Comments

- (id)getCommentsForIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/comments/%@", issuePath] withParameters:nil];
	
}


- (id)addComment:(NSString *)comment toIssue:(NSString *)issuePath
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
	return [self sendRequest:[NSString stringWithFormat:@"issues/comment/%@", issuePath] withParameters:commentDictionary];
	
}


#pragma mark Users

- (id)getUser:(NSString *)user
{
	return [self sendRequest:[NSString stringWithFormat:@"user/show/%@", user] withParameters:nil];
	
}

/*
 
 
 */

@end
