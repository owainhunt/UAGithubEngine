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
#import "UAGithubIssueCommentsParser.h"
#import "UAGithubLabelsParser.h"
#import "UAGithubUsersParser.h"
#import "UAGithubCommitsParser.h"
#import "UAGithubURLConnection.h"

@interface UAGithubEngine (Private)

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params;


@end


@implementation UAGithubEngine

@synthesize delegate, username, apiKey, dataFormat, connections;


#pragma mark Initializer


- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate
{
	if (self = [super init]) 
	{
		username = [aUsername retain];
		apiKey = [aKey retain];
		delegate = theDelegate;
		dataFormat = @"xml";
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	return self;
		
}


- (void)dealloc
{
	[username release];
	[apiKey release];
	[dataFormat release];
	[connections release];
	delegate = nil;
	
	[super dealloc];
	
}


- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params
{
	
	NSMutableString *querystring = nil;
	if (![params isEqual:nil]) 
	{
		querystring = [NSMutableString stringWithFormat:@"&"];
		for (NSString *key in [params allKeys]) 
		{
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
	UAGithubURLConnection *connection;
	connection = [[UAGithubURLConnection alloc] initWithRequest:urlRequest delegate:self requestType:requestType responseType:responseType];
	
	if (!connection) 
	{
		return nil;
	}
	else
	{ 
		[connections setObject:connection forKey:connection.identifier];
		[connection release];
	}
	
	return connection.identifier;
	
}




- (void)parseDataForConnection:(UAGithubURLConnection *)connection
{
	switch (connection.responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[[UAGithubRepositoriesParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[[UAGithubIssuesParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubCommentsResponse:
		case UAGithubCommentResponse:
			[[UAGithubIssueCommentsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[[UAGithubUsersParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubLabelsResponse:
			[[UAGithubLabelsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[[UAGithubCommitsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		default:
			break;
	}

}
	

#pragma mark Repositories

- (void)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];
	
}


- (void)getRepository:(NSString *)repositoryPath;
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];
	
}


#pragma mark Issues 

- (void)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType
{
	switch (requestType) {
		case UAGithubAllIssuesRequest:
			/*
			theData = [[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] withParameters:nil] mutableCopy];
			[theData appendData:[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] withParameters:nil]];
			 */

			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		case UAGithubOpenIssuesRequest:
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		case UAGithubClosedIssuesRequest:
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		default:
			break;
	}
	
}


- (void)getIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/show/%@", issuePath] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


- (void)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary
{
	[self sendRequest:[NSString stringWithFormat:@"issues/edit/%@", issuePath] requestType:UAGithubEditIssueRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];
	
}


- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary
{
	[self sendRequest:[NSString stringWithFormat:@"issues/open/%@", repositoryPath] requestType:UAGithubAddIssueRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];
	
}


- (void)closeIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubCloseIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


- (void)reopenIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubReopenIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


#pragma mark Labels

- (void)getLabelsForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/labels/%@", repositoryPath] requestType:UAGithubLabelsRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


- (void)addLabel:(NSString *)label toIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@/%@", repositoryPath, label, issueNumber] requestType:UAGithubAddLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


- (void)removeLabel:(NSString *)label fromIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@/%@", repositoryPath, label, issueNumber] requestType:UAGithubRemoveLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


#pragma mark Comments

- (void)getCommentsForIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/comments/%@", issuePath] requestType:UAGithubCommentsRequest responseType:UAGithubCommentsResponse withParameters:nil];
	
}


- (void)addComment:(NSString *)comment toIssue:(NSString *)issuePath
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
	[self sendRequest:[NSString stringWithFormat:@"issues/comment/%@", issuePath] requestType:UAGithubAddCommentRequest responseType:UAGithubCommentResponse withParameters:commentDictionary];
	
}


#pragma mark Users

- (void)getUser:(NSString *)user
{
	[self sendRequest:[NSString stringWithFormat:@"user/show/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse withParameters:nil];
	
}


#pragma mark Commits

- (void)getCommitsForBranch:(NSString *)branchPath
{
	[self sendRequest:[NSString stringWithFormat:@"commits/list/%@", branchPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse withParameters:nil];
}


- (void)getCommit:(NSString *)commitPath
{
	[self sendRequest:[NSString stringWithFormat:@"commits/show/%@", commitPath] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse withParameters:nil];
}
	


#pragma mark Parser Delegate Methods

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withParsedObjects:(NSArray *)parsedObjects
{
	switch (responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[delegate repositoriesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[delegate issuesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommentsResponse:
		case UAGithubCommentResponse:
			[delegate issueCommentsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[delegate usersReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubLabelsResponse:
			[delegate labelsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[delegate commitsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		default:
			break;
	}
	
}


- (void)parsingFailedForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withError:(NSError *)parseError
{
	[delegate requestFailed:connectionIdentifier withError:parseError];
	
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(UAGithubURLConnection *)connection didFailWithError:(NSError *)error
{
	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveData:(NSData *)data
{
	[connection appendData:data];
	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}


- (void)connectionDidFinishLoading:(UAGithubURLConnection *)connection
{
	[self parseDataForConnection:connection];
	
}


@end
