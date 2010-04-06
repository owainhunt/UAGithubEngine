//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubRepositoriesParser.h"
#import "UAGithubIssuesParser.h"
#import "UAGithubCommentsParser.h"
#import "UAGithubLabelsParser.h"
#import "UAGithubUsersParser.h"


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


- (void)parseData:(NSData *)theData requestType:(UAGithubRequestType)requestType
{
	switch (requestType) {
		case UAGithubRepositoriesRequest:
		case UAGithubRepositoryRequest:
			[[UAGithubRepositoriesParser alloc] initWithXML:theData delegate:self requestType:requestType];
			break;
		case UAGithubIssuesRequest:
		case UAGithubIssueRequest:
			[[UAGithubIssuesParser alloc] initWithXML:theData delegate:self requestType:requestType];
			break;
		case UAGithubCommentsRequest:
		case UAGithubCommentRequest:
			[[UAGithubCommentsParser alloc] initWithXML:theData delegate:self requestType:requestType];
			break;
		case UAGithubUsersRequest:
		case UAGithubUserRequest:
			[[UAGithubUsersParser alloc] initWithXML:theData delegate:self requestType:requestType];
			break;
		case UAGithubLabelsRequest:
			[[UAGithubLabelsParser alloc] initWithXML:theData delegate:self requestType:requestType];
			break;
			
		default:
			break;
	}

}
	

#pragma mark Repositories


- (void)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] withParameters:nil]
		requestType:UAGithubRepositoriesRequest];
	
}


- (void)getRepository:(NSString *)repositoryPath;
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] withParameters:nil]
		requestType:UAGithubRepositoryRequest];
	
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


- (void)getIssue:(NSString *)issuePath
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"issues/show/%@", issuePath] withParameters:nil] requestType:UAGithubIssueRequest];
	
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

- (void)getLabelsForRepository:(NSString *)repositoryPath
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"issues/labels/%@", repositoryPath] withParameters:nil] requestType:UAGithubLabelsRequest];
	
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

- (void)getCommentsForIssue:(NSString *)issuePath
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"issues/comments/%@", issuePath] withParameters:nil] requestType:UAGithubCommentsRequest];
	
}


- (id)addComment:(NSString *)comment toIssue:(NSString *)issuePath
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
	return [self sendRequest:[NSString stringWithFormat:@"issues/comment/%@", issuePath] withParameters:commentDictionary];
	
}


#pragma mark Users

- (void)getUser:(NSString *)user
{
	[self parseData:[self sendRequest:[NSString stringWithFormat:@"user/show/%@", user] withParameters:nil] requestType:UAGithubUserRequest];
	
}


#pragma mark Parser Delegate Methods

- (void)parsingSucceededForRequestOfType:(UAGithubRequestType)requestType withParsedObjects:(NSArray *)parsedObjects
{
	
}


- (void)parsingFailedForRequestOfType:(UAGithubRequestType)requestType withError:(NSError *)parseError
{
	
}


@end
