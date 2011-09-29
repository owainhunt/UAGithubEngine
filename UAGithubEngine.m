//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAReachability.h"

#import "UAGithubSimpleJSONParser.h"
#import "UAGithubUsersJSONParser.h"
#import "UAGithubRepositoriesJSONParser.h"
#import "UAGithubMilestonesJSONParser.h"
#import "UAGithubCommitsJSONParser.h"
#import "UAGithubIssuesJSONParser.h"
#import "UAGithubIssueCommentsJSONParser.h"

#import "UAGithubEngineRequestTypes.h"
#import "UAGithubURLConnection.h"

#import "NSString+UAGithubEngineUtilities.h"
#import "NSData+Base64.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"github.com/api"
#define API_VERSION @"v2"
#define API_FORMAT @"json"


@interface UAGithubEngine (Private)

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params;
- (BOOL)isValidSelectorForDelegate:(SEL)selector;

@end


@implementation UAGithubEngine

@synthesize delegate, username, password, connections, reachability, isReachable;


#pragma mark Initializer

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword delegate:(id)theDelegate withReachability:(BOOL)withReach
{
	if ((self = [super init])) 
	{
		username = [aUsername retain];
		password = [aPassword retain];
		delegate = theDelegate;
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
		if (withReach)
		{
			reachability = [[UAReachability alloc] init];
		}
	}
	
	
	return self;
		
}


- (void)dealloc
{
	[username release];
	[password release];
	[connections release];
	[reachability release];
	delegate = nil;
	
	[super dealloc];
	
}


- (UAReachability *)reachability
{
	if (!reachability)
	{
		reachability = [[UAReachability alloc] init];
	}
	
	return reachability;
}


#pragma mark Delegate Check

- (BOOL)isValidSelectorForDelegate:(SEL)selector
{
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}


#pragma mark -
#pragma mark Reachability Check

- (BOOL)isReachable
{
	return [self.reachability currentReachabilityStatus];
}	


#pragma mark Request Management

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params
{
    
    NSMutableString *urlString;
    
    switch (requestType) 
    {
        // V3 Requests
        
        // NOT YET IN V3 case UAGithubIssuesClosedRequest:
        // NOT YET IN V3 case UAGithubIssuesOpenRequest:
        case UAGithubIssuesRequest:
        case UAGithubIssueRequest:
        case UAGithubIssueAddRequest:
        case UAGithubIssueEditRequest:
        case UAGithubIssueDeleteRequest:
            
        case UAGithubIssueCommentsRequest:
        case UAGithubIssueCommentRequest:
        case UAGithubIssueCommentAddRequest:
        case UAGithubIssueCommentEditRequest:
        case UAGithubIssueCommentDeleteRequest:
            
        case UAGithubRepositoryLabelsRequest:
        case UAGithubRepositoryLabelAddRequest:   
        case UAGithubRepositoryLabelRemoveRequest:
            
        case UAGithubIssueLabelsRequest:
        case UAGithubIssueLabelRequest:
        case UAGithubIssueLabelAddRequest:
        case UAGithubIssueLabelRemoveRequest:
        case UAGithubIssueLabelReplaceRequest:
            
        case UAGithubMilestoneRequest:
        case UAGithubMilestoneCreateRequest:
        case UAGithubMilestoneUpdateRequest:
        case UAGithubMilestoneDeleteRequest:
        case UAGithubMilestonesRequest:
            
        case UAGithubUserRequest:
            urlString = [NSMutableString stringWithFormat:@"%@api.github.com/%@", API_PROTOCOL, path];
            break;
        
        // v2 Requests
        default:
            urlString = [NSMutableString stringWithFormat:@"%@%@/%@/%@/%@", API_PROTOCOL, API_DOMAIN, API_VERSION, API_FORMAT, path];
            break;
    }
    
    NSData *jsonData = nil;
    NSError *error = nil;
    
    if ([params count] > 0)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    }

    NSMutableString *querystring = nil;

    if (!jsonData && [params count] > 0) 
	{
        // API v3 means we're passing more parameters in the querystring than previously.
        // Is the querystring already present (ie a question mark is present in the path)? Create it if not.        
        if ([path rangeOfString:@"?"].location == NSNotFound)
        {
            querystring = [NSMutableString stringWithString:@"?"];
        }
        
		for (NSString *key in [params allKeys]) 
		{
			[querystring appendFormat:@"%@%@=%@", [querystring length] <= 1 ? @"" : @"&", key, [[params valueForKey:key] encodedString]];
		}
	}

    if ([querystring length] > 0)
	{
		[urlString appendString:querystring];
	}

	NSURL *theURL = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
	if (self.username && self.password)
	{
		[urlRequest setValue:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]] forHTTPHeaderField:@"Authorization"];	
	}

	if (jsonData)
    {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:jsonData];
    }

	switch (requestType) 
    {
        case UAGithubFollowRequest:
        {
            [urlRequest setHTTPMethod:@"PUT"];
        }
            break;
		case UAGithubRepositoryUpdateRequest:
		case UAGithubRepositoryCreateRequest:
		case UAGithubRepositoryDeleteConfirmationRequest:
        case UAGithubMilestoneCreateRequest:
		case UAGithubDeployKeyAddRequest:
		case UAGithubDeployKeyDeleteRequest:
		case UAGithubCollaboratorAddRequest:
		case UAGithubCollaboratorRemoveRequest:
		case UAGithubIssueCommentAddRequest:
        case UAGithubPublicKeyAddRequest:
            
        case UAGithubRepositoryLabelAddRequest:

        case UAGithubIssueLabelAddRequest:
		{
			[urlRequest setHTTPMethod:@"POST"];
		}
			break;
        case UAGithubMilestoneUpdateRequest:
        case UAGithubIssueEditRequest:
        case UAGithubIssueCommentEditRequest:
        case UAGithubPublicKeyEditRequest:
        case UAGithubUserEditRequest:
        case UAGithubRepositoryLabelEditRequest:
        {
            [urlRequest setHTTPMethod:@"PATCH"];
        }
            break;
        case UAGithubMilestoneDeleteRequest:
        case UAGithubIssueDeleteRequest:
        case UAGithubIssueCommentDeleteRequest:
        case UAGithubUnfollowRequest:
        case UAGithubPublicKeyDeleteRequest:
            
        case UAGithubRepositoryLabelRemoveRequest:
        case UAGithubIssueLabelRemoveRequest:
        {
            [urlRequest setHTTPMethod:@"DELETE"];
        }
            break;
        case UAGithubIssueLabelReplaceRequest:
        {
            [urlRequest setHTTPMethod:@"PUT"];
        }
            break;
		default:
			break;
	}
	
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
			[[[UAGithubRepositoriesJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
        case UAGithubMilestonesResponse:
        case UAGithubMilestoneResponse:
            [[[UAGithubMilestonesJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
            break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[[[UAGithubIssuesJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
		case UAGithubIssueCommentsResponse:
		case UAGithubIssueCommentResponse:
			[[[UAGithubIssueCommentsJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[[[UAGithubUsersJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[[[UAGithubCommitsJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
		case UAGithubRawBlobResponse:
			[delegate rawBlobReceived:connection.data forConnection:connection.identifier];
			break;
		case UAGithubCollaboratorsResponse:
		case UAGithubBlobsResponse:
		case UAGithubBlobResponse:
		case UAGithubIssueLabelsResponse:
		case UAGithubRepositoryLabelsResponse:
		case UAGithubDeployKeysResponse:
		case UAGithubRepositoryLanguageBreakdownResponse:
		case UAGithubTagsResponse:
		case UAGithubBranchesResponse:
        case UAGithubFollowingResponse:
        case UAGithubFollowersResponse:
		case UAGithubTreeResponse:
			[[[UAGithubSimpleJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType] autorelease];
			break;
		default:
			break;
	}

}
	

#pragma mark Parser Delegate Methods

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withParsedObjects:(NSArray *)parsedObjects
{
	[delegate requestSucceeded:connectionIdentifier];
	
	switch (responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[delegate repositoriesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
        case UAGithubMilestonesResponse:
        case UAGithubMilestoneResponse:
            [delegate milestonesReceived:parsedObjects forConnection:connectionIdentifier];
            break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[delegate issuesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssueCommentsResponse:
		case UAGithubIssueCommentResponse:
			[delegate issueCommentsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[delegate usersReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssueLabelsResponse:
		case UAGithubRepositoryLabelsResponse:
			[delegate labelsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[delegate commitsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobsResponse:
			[delegate blobsReceieved:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobResponse:
			[delegate blobReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCollaboratorsResponse:
			[delegate collaboratorsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubDeployKeysResponse:
			[delegate deployKeysReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubRepositoryLanguageBreakdownResponse:
			[delegate languagesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubTagsResponse:
			[delegate tagsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBranchesResponse:
			[delegate branchesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubTreeResponse:
			[delegate treeReceived:parsedObjects forConnection:connectionIdentifier];
			break;
        case UAGithubFollowingResponse:
			[delegate followingReceived:parsedObjects forConnection:connectionIdentifier];
			break;
        case UAGithubFollowersResponse:
			[delegate followersReceived:parsedObjects forConnection:connectionIdentifier];
			break;

		default:
			break;
	}
	
}


- (void)parsingFailedForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withError:(NSError *)parseError
{
	[delegate requestFailed:connectionIdentifier withError:parseError];	
}


#pragma mark Repositories

- (NSString *)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	return [self repositoriesForUser:aUser includeWatched:watched page:1];	
}

- (NSString *)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/%@?page=%d", (watched ? @"watched" : @"show"), aUser, page] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)repository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];	
}


- (NSString *)searchRepositories:(NSString *)query
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/search/%@", [query encodedString]] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	 
}


- (NSString *)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	for (NSString *key in [infoDictionary allKeys])
	{
		[params setObject:[infoDictionary objectForKey:key] forKey:[NSString stringWithFormat:@"values[%@]", key]];
		
	}
	
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:params];
	
}


- (NSString *)watchRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/watch/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubRepositoryResponse withParameters:nil];	 
}


- (NSString *)unwatchRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/unwatch/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)forkRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/fork/%@", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)createRepositoryWithInfo:(NSDictionary *)infoDictionary
{
	return [self sendRequest:@"repos/create" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary];	
}


- (NSString *)deleteRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteRequest responseType:UAGithubDeleteRepositoryResponse withParameters:nil];
}


- (NSString *)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:deleteToken forKey:@"delete_token"];
	return [self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteConfirmationRequest responseType:UAGithubDeleteRepositoryConfirmationResponse withParameters:params];
	
}


- (NSString *)privatiseRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/set/private/%@", repositoryName] requestType:UAGithubRepositoryPrivatiseRequest responseType:UAGithubRepositoryResponse withParameters:nil];	
}


- (NSString *)publiciseRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/set/public/%@", repositoryName] requestType:UAGithubRepositoryPubliciseRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)deployKeysForRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/keys/%@", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse withParameters:nil];
}


- (NSString *)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	return [self sendRequest:[NSString stringWithFormat:@"repos/key/%@/add", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (NSString *)removeDeployKey:(NSString *)keyID fromRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:keyID forKey:@"id"];
	return [self sendRequest:[NSString stringWithFormat:@"repos/key/%@/remove", repositoryName] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (NSString *)collaboratorsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];	
}


- (NSString *)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/add/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];
}


- (NSString *)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/remove/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];
}


- (NSString *)pushableRepositories
{
	return [self sendRequest:@"repos/pushable" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)networkForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/network", repositoryPath] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)languageBreakdownForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse withParameters:nil];	
}


- (NSString *)tagsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse withParameters:nil];	
}


- (NSString *)branchesForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse withParameters:nil];	
}


#pragma mark Milestones

- (NSString *)milestonesForRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse withParameters:nil];
}


- (NSString *)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse withParameters:nil];
}


- (NSString *)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary];
}


- (NSString *)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]; 
}


- (NSString *)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse withParameters:nil];
}


#pragma mark Issues 

- (NSString *)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType
{
	// Use UAGithubIssuesOpenRequest for open issues, UAGithubIssuesClosedRequest for closed issues, UAGithubIssuesRequest for all issues.

	switch (requestType) {
		case UAGithubIssuesOpenRequest:
			return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=open", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:parameters];
			break;
            
		case UAGithubIssuesClosedRequest:
			return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:parameters];
			break;
            
        case UAGithubIssuesRequest:
		default:
            return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssueResponse withParameters:parameters];
			break;
	}
	return nil;
}


- (NSString *)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


- (NSString *)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];	
}


- (NSString *)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];	
}


- (NSString *)closeIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubIssueCloseRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


- (NSString *)reopenIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubIssueReopenRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


- (NSString *)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse withParameters:nil];	
}

#pragma mark Labels

- (NSString *)labelsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse withParameters:nil];	
}


- (NSString *)label:(NSInteger)labelId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%d", repositoryPath, labelId] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse withParameters:nil];
}

- (NSString *)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary];	
}


- (NSString *)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary];
}


- (NSString *)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse withParameters:nil];	
}


/*- (NSString *)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@/%d", repositoryPath, [label encodedString], issueNumber] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}*/


- (NSString *)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels];
}


- (NSString *)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}


// modify sendRequest... to take an id as final parameter. If passed an array, send through as is.

- (NSString *)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels];
}


- (NSString *)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];
}


- (NSString *)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];
}


#pragma mark Comments

- (NSString *)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath
{
 	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse withParameters:nil];	
}


- (NSString *)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse withParameters:nil];
}


- (NSString *)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath;
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary];
	
}


- (NSString *)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    return [self sendRequest:[NSString stringWithFormat:@"repos/:user/:repo/issues/comments/:id", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary];
}


- (NSString *)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse withParameters:nil];
}


#pragma mark Users

- (NSString *)user:(NSString *)user
{
	return [self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse withParameters:nil];	
}


- (NSString *)user
{
	return [self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse withParameters:nil];	
}


- (NSString *)editUser:(NSDictionary *)userDictionary
{
    return [self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary];
}


#pragma mark TODO is in v3?
- (NSString *)searchUsers:(NSString *)query byEmail:(BOOL)email
{
	return [self sendRequest:[NSString stringWithFormat:@"user/%@/%@", email ? @"email" : @"search", query] requestType:UAGithubUserRequest responseType:UAGithubUsersResponse withParameters:nil];	
}


- (NSString *)following:(NSString *)user
{
	return [self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse withParameters:nil];	    
}


- (NSString *)followers:(NSString *)user
{
	return [self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse withParameters:nil];	    
    
}


- (NSString *)follow:(NSString *)user 
{
 	return [self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse withParameters:nil];	    
   
}


- (NSString *)unfollow:(NSString *)user
{
 	return [self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse withParameters:nil];	        
}


- (NSString *)publicKeys
{
    return [self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse withParameters:nil];
}


- (NSString *)publicKey:(NSInteger)keyId
{
    return [self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse withParameters:nil];
}


- (NSString *)addPublicKey:(NSDictionary *)keyDictionary
{
    return [self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary];
}


- (NSString *)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary
{
    return [self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary];
}


- (NSString *)deletePublicKey:(NSInteger)keyId
{
    return [self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse withParameters:nil];
}


#pragma mark Commits

- (NSString *)commitsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse withParameters:nil];	
}


- (NSString *)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse withParameters:nil];	
}
	

#pragma mark Commit Comments

- (NSString *)commitCommentsForRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse withParameters:nil];
}


- (NSString *)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse withParameters:nil];
}


- (NSString *)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary];
}


- (NSString *)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse withParameters:nil];
}


- (NSString *)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary];
}


- (NSString *)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath
{
    return [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse withParameters:nil];
}



#pragma mark Trees

- (NSString *)tree:(NSString *)treePath
{
	return [self sendRequest:[NSString stringWithFormat:@"tree/show/%@", treePath] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse withParameters:nil];	
}


#pragma mark Blobs

- (NSString *)blobsForSHA:(NSString *)shaPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/all/%@", shaPath] requestType:UAGithubBlobsRequest responseType:UAGithubBlobsResponse withParameters:nil];	
}


- (NSString *)blob:(NSString *)blobPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse withParameters:nil];	
}


- (NSString *)rawBlob:(NSString *)blobPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubRawBlobRequest responseType:UAGithubRawBlobResponse withParameters:nil];	
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(UAGithubURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.connections removeObjectForKey:connection.identifier];
	
	if ([self isValidSelectorForDelegate:@selector(requestFailed:withError:)])
	{
		[delegate requestFailed:connection.identifier withError:error];
	}
			
	if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
	{
		[delegate connectionFinished:connection.identifier];
	}

}


- (void)connection:(UAGithubURLConnection *)connection didReceiveData:(NSData *)data
{
	[connection appendData:data];	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[connection resetDataLength];
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    int statusCode = resp.statusCode;
	
	
	if ([[[resp allHeaderFields] allKeys] containsObject:@"X-Ratelimit-Remaining"] && [[[resp allHeaderFields] valueForKey:@"X-Ratelimit-Remaining"] isEqualToString:@"1"])
	{
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UAGithubAPILimitReached object:nil]];
		[self.connections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
		 {
			 [(UAGithubURLConnection *)obj cancel];
		 }];
	}
		
	//If X-Ratelimit-Remaining == 0:
	//Add connection to list to retry
	//Get all remaining connections from self.connections and add to retry list
	//Post notification in 60s to allow new connections
    
    if (statusCode >= 400) {
        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		if ([self isValidSelectorForDelegate:@selector(requestFailed:withError:)])
		{
			[delegate requestFailed:connection.identifier withError:error];
		}
        
        [connection cancel];
		NSString *connectionIdentifier = connection.identifier;
		[connections removeObjectForKey:connectionIdentifier];
		if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
		{
			[delegate connectionFinished:connectionIdentifier];
		}
		
    } 
	
}


- (void)connectionDidFinishLoading:(UAGithubURLConnection *)connection
{
	[self parseDataForConnection:connection];
	[self.connections removeObjectForKey:connection.identifier];
	if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
	{
		[delegate connectionFinished:connection.identifier];
	}
	
}


@end
