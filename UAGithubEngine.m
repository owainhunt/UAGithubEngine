//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAReachability.h"

#import "UAGithubJSONParser.h"

#import "UAGithubEngineRequestTypes.h"
#import "UAGithubURLConnection.h"

#import "NSString+UAGithubEngineUtilities.h"
#import "NSData+Base64.h"
#import "NSString+UUID.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"api.github.com"


@interface UAGithubEngine (Private)

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page;

@end


@implementation UAGithubEngine

@synthesize username, password, connections, reachability, isReachable;

#pragma mark
#pragma mark Setup & Teardown
#pragma mark

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword withReachability:(BOOL)withReach
{
	if ((self = [super init])) 
	{
		username = [aUsername retain];
		password = [aPassword retain];
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
	
	[super dealloc];
	
}


#pragma mark 
#pragma mark Reachability 
#pragma mark 

- (BOOL)isReachable
{
	return [self.reachability currentReachabilityStatus];
}	


- (UAReachability *)reachability
{
	if (!reachability)
	{
		reachability = [[UAReachability alloc] init];
	}
	
	return reachability;
}


#pragma mark 
#pragma mark Request Management
#pragma mark 

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page
{
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@/%@", API_PROTOCOL, API_DOMAIN, path];
    NSData *jsonData = nil;
    NSError *error = nil;
    
    if ([params count] > 0)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    }

    NSMutableString *querystring = nil;

    if (!jsonData && [params count] > 0) 
	{
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
    
    if (page > 0)
    {
        if (querystring) 
        {
            [querystring appendFormat:@"&page=%d", page];
        }
        else
        {
            querystring = [NSString stringWithFormat:@"?page=%d", page];
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
		case UAGithubRepositoryCreateRequest:
		case UAGithubRepositoryDeleteConfirmationRequest:
        case UAGithubMilestoneCreateRequest:
		case UAGithubDeployKeyAddRequest:
		case UAGithubDeployKeyDeleteRequest:
		case UAGithubIssueCommentAddRequest:
        case UAGithubPublicKeyAddRequest:            
        case UAGithubRepositoryLabelAddRequest:
        case UAGithubIssueLabelAddRequest:            
        case UAGithubTreeCreateRequest:            
        case UAGithubBlobCreateRequest:            
        case UAGithubReferenceCreateRequest:
        case UAGithubRawCommitCreateRequest:
        case UAGithubGistCreateRequest:
        case UAGithubGistCommentCreateRequest:
        case UAGithubGistForkRequest:
        case UAGithubPullRequestCreateRequest:
        case UAGithubPullRequestCommentCreateRequest:
        case UAGithubEmailAddRequest:
            
		{
			[urlRequest setHTTPMethod:@"POST"];
		}
			break;

		case UAGithubCollaboratorAddRequest:
        case UAGithubIssueLabelReplaceRequest:
        case UAGithubFollowRequest:
        case UAGithubGistStarRequest:
        case UAGithubPullRequestMergeRequest:
            
        {
            [urlRequest setHTTPMethod:@"PUT"];
        }
            break;
            
		case UAGithubRepositoryUpdateRequest:
        case UAGithubMilestoneUpdateRequest:
        case UAGithubIssueEditRequest:
        case UAGithubIssueCommentEditRequest:
        case UAGithubPublicKeyEditRequest:
        case UAGithubUserEditRequest:
        case UAGithubRepositoryLabelEditRequest:
        case UAGithubReferenceUpdateRequest:
        case UAGithubGistUpdateRequest:
        case UAGithubGistCommentUpdateRequest:
        case UAGithubPullRequestUpdateRequest:
        case UAGithubPullRequestCommentUpdateRequest:
            
        {
            [urlRequest setHTTPMethod:@"PATCH"];
        }
            break;
            
        case UAGithubMilestoneDeleteRequest:
        case UAGithubIssueDeleteRequest:
        case UAGithubIssueCommentDeleteRequest:
        case UAGithubUnfollowRequest:
        case UAGithubPublicKeyDeleteRequest:
		case UAGithubCollaboratorRemoveRequest:            
        case UAGithubRepositoryLabelRemoveRequest:
        case UAGithubIssueLabelRemoveRequest:
        case UAGithubGistUnstarRequest:
        case UAGithubGistDeleteRequest:
        case UAGithubGistCommentDeleteRequest:
        case UAGithubPullRequestCommentDeleteRequest:
        case UAGithubEmailDeleteRequest:
            
        {
            [urlRequest setHTTPMethod:@"DELETE"];
        }
            break;
            
		default:
			break;
	}
	
    __block NSString *uuid = [[NSString stringWithNewUUID] retain];    
    __block id jsonObj = nil;
    
    [UAGithubURLConnection asyncRequest:urlRequest 
                                success:^(NSData *data, NSURLResponse *response)
                                {
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
                                    
                                    
                                    if (statusCode >= 400) 
                                    {
                                        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
                                        [connections removeObjectForKey:uuid];
#pragma mark TODO Handle error
                                                                                
                                    } 
                                    
                                    else if (statusCode == 204)
                                    {
#pragma mark TODO Handle NoContentResponse
                                    }

                                    jsonObj = [UAGithubJSONParser parseJSON:data];
                                }
                                failure:^(NSData *data, NSError *parserError)
                                {
#pragma mark TODO Handle failure
                                }
     ];
    
    return jsonObj;
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:params page:0];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:page];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:0];
}


#pragma mark 
#pragma mark Gists
#pragma mark

- (id)gistsForUser:(NSString *)user success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/gists", user] requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)gistsSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);

}

- (id)publicGistsSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists/public" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)starredGistsSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists/starred" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)gist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d", gistId] requestType:UAGithubGistRequest responseType:UAGithubGistResponse]);
}


- (id)createGist:(NSDictionary *)gistDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists" requestType:UAGithubGistCreateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (id)editGist:(NSInteger)gistId withDictionary:(NSDictionary *)gistDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d", gistId] requestType:UAGithubGistUpdateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (id)starGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/star", gistId] requestType:UAGithubGistStarRequest responseType:UAGithubNoContentResponse]);
}


- (id)unstarGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/star", gistId] requestType:UAGithubGistUnstarRequest responseType:UAGithubNoContentResponse]);
}


- (id)gistIsStarred:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/star", gistId] requestType:UAGithubGistStarStatusRequest responseType:UAGithubNoContentResponse]);
}


- (id)forkGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/fork", gistId] requestType:UAGithubGistForkRequest responseType:UAGithubGistResponse]);
}


- (id)deleteGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d", gistId] requestType:UAGithubGistDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Comments

- (id)commentsForGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/comments", gistId] requestType:UAGithubGistCommentsRequest responseType:UAGithubGistCommentsResponse]);
}


- (id)gistComment:(NSString *)commentId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentRequest responseType:UAGithubGistCommentResponse]);
}


- (id)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%d/comments", gistId] requestType:UAGithubGistCommentCreateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (id)editGistComment:(NSString *)commentId withDictionary:(NSDictionary *)commentDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentUpdateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (id)deleteGistComment:(NSString *)commentId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Issues 
#pragma mark

- (id)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType success:(id(^)(id obj))successBlock_
{
	// Use UAGithubIssuesOpenRequest for open issues, UAGithubIssuesClosedRequest for closed issues.
    
	switch (requestType) {
		case UAGithubIssuesOpenRequest:
			return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:parameters]);
			break;
            
		case UAGithubIssuesClosedRequest:
			return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:parameters]);
			break;
        default:
            return nil;
			break;
	}
	return nil;
}


- (id)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


- (id)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (id)closeIssue:(NSString *)issuePath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubIssueCloseRequest responseType:UAGithubIssueResponse]);	
}


- (id)reopenIssue:(NSString *)issuePath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubIssueReopenRequest responseType:UAGithubIssueResponse]);	
}


- (id)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


#pragma mark Comments

- (id)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse]);	
}


- (id)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse]);
}


- (id)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
	
}


- (id)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody success:(id(^)(id obj))successBlock_
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
}


- (id)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse]);
}


#pragma mark Events

- (id)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/events", repositoryPath, issueId] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (id)issueEventsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events", repositoryPath] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (id)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events/%d", repositoryPath, eventId] requestType:UAGithubIssueEventRequest responseType:UAGithubIssueEventResponse]);
}


#pragma mark Labels

- (id)labelsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse]);	
}


- (id)label:(NSString *)labelName inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse]);
}

- (id)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary]);	
}


- (id)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary]);
}


- (id)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse]);	
}


- (id)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (id)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse]);	
}


- (id)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (id)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


- (id)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


#pragma mark Milestones

- (id)milestonesForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse]);
}


- (id)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse]);
}


- (id)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]);
}


- (id)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]); 
}


- (id)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse]);
}


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (id)pullRequestsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestsRequest responseType:UAGithubPullRequestsResponse]);
}


- (id)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestRequest responseType:UAGithubPullRequestResponse]);
}


- (id)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestCreateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (id)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestUpdateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (id)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/commits", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommitsRequest responseType:UAGithubPullRequestCommitsResponse]);
}


- (id)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/files", repositoryPath, pullRequestId] requestType:UAGithubPullRequestFilesRequest responseType:UAGithubPullRequestFilesResponse]);
}


- (id)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeStatusRequest responseType:UAGithubNoContentResponse]);
}


- (id)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeRequest responseType:UAGithubPullRequestMergeSuccessStatusResponse]);
}


#pragma mark Comments

- (id)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentsRequest responseType:UAGithubPullRequestCommentsResponse]);
}


- (id)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentRequest responseType:UAGithubPullRequestCommentResponse]);
}


- (id)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentCreateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (id)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentUpdateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (id)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentDeleteRequest responseType:UAGithubPullRequestCommentResponse]);
}


#pragma mark
#pragma mark Repositories
#pragma mark

- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched success:(id(^)(id obj))successBlock_
{
	return successBlock_([self repositoriesForUser:aUser includeWatched:watched page:1 success:successBlock_(nil)]);	
}

#pragma mark TODO watched repos?
- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/repos", aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	
}


- (id)repositoriesSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/repos" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}

#pragma mark TODO check orgs is implemented elsewhere
- (id)createRepositoryWithInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:@"user/repos" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);	
}


- (id)repository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse]);	
}

/*
- (id)searchRepositories:(NSString *)query success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/search/%@", [query encodedString]] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	 
}*/


- (id)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);
}


- (id)contributorsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
   	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/contributitors", repositoryPath] requestType:UAGithubRepositoryContributorsRequest responseType:UAGithubUsersResponse]);
}


- (id)languageBreakdownForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse]);	
}


- (id)teamsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/teams", repositoryPath] requestType:UAGithubRepositoryTeamsRequest responseType:UAGithubRepositoryTeamsResponse]);
}


- (id)annotatedTagsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse]);	
}


- (id)branchesForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse]);	
}


#pragma mark Collaborators

- (id)collaboratorsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse]);	
}

#pragma mark TODO Vomit. Returns 204 No Content if true, 404 if false.
- (id)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, user] requestType:UAGithubCollaboratorsRequest responseType:UAGithubNoContentResponse]);
}


- (id)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse]);
}


- (id)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse]);
}


#pragma mark Commits

- (id)commitsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse]);	
}


- (id)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse]);	
}


#pragma mark Commit Comments

- (id)commitCommentsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse]);
}


- (id)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse]);
}


- (id)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary]);
}


- (id)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse]);
}


- (id)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary]);
}


- (id)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Downloads

- (id)downloadsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadsRequest responseType:UAGithubDownloadsResponse]);
}


- (id)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadRequest responseType:UAGithubDownloadResponse]);
}


- (id)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadAddRequest responseType:UAGithubDownloadResponse withParameters:downloadDictionary]);
}


- (id)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Forks

- (id)forksForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForksRequest responseType:UAGithubRepositoriesResponse]);
}


- (id)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org success:(id(^)(id obj))successBlock_
{
    if (org)
    {
        return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:[NSDictionary dictionaryWithObject:org forKey:@"org"]]);
    }
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse]);
}


- (id)forkRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self forkRepository:repositoryPath inOrganization:nil success:successBlock_(nil)]);
}


#pragma mark Keys

- (id)deployKeysForRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse]);
}


- (id)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyRequest responseType:UAGithubDeployKeyResponse]);
}


- (id)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params]);
    
}


- (id)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyEditRequest responseType:UAGithubDeployKeyResponse withParameters:keyDictionary]);
}


- (id)removeDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryName, keyId] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubNoContentResponse]);
    
}


#pragma mark Watching

- (id)watchersForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/watchers", repositoryPath] requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse]);
}


- (id)watchedRepositoriesForUser:(NSString *)user success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/watched", user] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (id)watchedRepositoriesSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/watched" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


#pragma mark TODO Vomit again (204/404)
- (id)repositoryIsWatched:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchingRequest responseType:UAGithubNoContentResponse]);
}


- (id)watchRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubNoContentResponse]);	 
}


- (id)unwatchRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Hooks

- (id)hooksForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHooksRequest responseType:UAGithubRepositoryHooksResponse]);
}


- (id)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookRequest responseType:UAGithubRepositoryHookResponse]);
}


- (id)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHookAddRequest responseType:UAGithubRepositoryHookResponse]);
}


- (id)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookEditRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary]);
}


- (id)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookTestRequest responseType:UAGithubNoContentResponse]);
}


- (id)removeHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookDeleteRequest responseType:UAGithubNoContentResponse]);
}


/*
- (id)deleteRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteRequest responseType:UAGithubDeleteRepositoryResponse]);
}


- (id)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken success:(id(^)(id obj))successBlock_
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:deleteToken forKey:@"delete_token"]);
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteConfirmationRequest responseType:UAGithubDeleteRepositoryConfirmationResponse withParameters:params]);
	
}


- (id)privatiseRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/set/private/%@", repositoryName] requestType:UAGithubRepositoryPrivatiseRequest responseType:UAGithubRepositoryResponse]);	
}


- (id)publiciseRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/set/public/%@", repositoryName] requestType:UAGithubRepositoryPubliciseRequest responseType:UAGithubRepositoryResponse]);
}


- (id)pushableRepositories success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:@"repos/pushable" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	
}


- (id)networkForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/show/%@/network", repositoryPath] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	
}
*/


#pragma mark
#pragma mark Users
#pragma mark 

- (id)user:(NSString *)user success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (id)userSuccess:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (id)editUser:(NSDictionary *)userDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary]);
}


#pragma mark Emails

- (id)emailAddressesSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailsRequest responseType:UAGithubEmailsResponse]);
}


- (id)addEmailAddresses:(NSArray *)emails success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailAddRequest responseType:UAGithubEmailsResponse withParameters:emails]);
}


- (id)deleteEmailAddresses:(NSArray *)emails success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailDeleteRequest responseType:UAGithubNoContentResponse withParameters:emails]);
}


#pragma mark Followers

- (id)followers:(NSString *)user success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse]);	    
    
}


- (id)followersSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/followers" requestType:UAGithubUsersRequest responseType:UAGithubFollowersResponse]);
}


- (id)following:(NSString *)user success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse]);	    
}


- (id)followedBy:(NSString *)user success:(id(^)(id obj))successBlock_
{
    return nil;
}


- (id)follows:(NSString *)user success:(id(^)(id obj))successBlock_
{
    return nil;
}


- (id)follow:(NSString *)user  success:(id(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse]);	    
   
}


- (id)unfollow:(NSString *)user success:(id(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse]);	        
}


#pragma mark Keys

- (id)publicKeysSuccess:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse]);
}


- (id)publicKey:(NSInteger)keyId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse]);
}


- (id)addPublicKey:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (id)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (id)deletePublicKey:(NSInteger)keyId success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse]);
}


- (id)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags", repositoryPath] requestType:UAGithubTagObjectCreateRequest responseType:UAGithubAnnotatedTagResponse withParameters:tagDictionary]);
}


#pragma mark
#pragma mark Events
#pragma mark

- (id)eventsWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"events" requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (id)eventsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/events", repositoryPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}

/*
- (id)eventsForNetwork:(NSString *)networkPath completion:(id(^)(id obj))successBlock;
- (id)eventsReceivedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)eventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)publicEventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)eventsForOrganization:(NSString *)organization completion:(id(^)(id obj))successBlock;
- (id)publicEventsForOrganization:(NSString *)organization completion:(id(^)(id obj))successBlock;
*/

#pragma mark -
#pragma mark Git Database API
#pragma mark -

#pragma mark Trees

- (id)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees/%@%@", repositoryPath, sha, recursive ? @"?recursive=1" : @""] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse]);	
}


- (id)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees", repositoryPath] requestType:UAGithubTreeCreateRequest responseType:UAGithubTreeResponse withParameters:treeDictionary]);
}


#pragma mark Blobs

- (id)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs/%@", repositoryPath, sha] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse]);	
}


- (id)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs", repositoryPath] requestType:UAGithubBlobCreateRequest responseType:UAGithubSHAResponse withParameters:blobDictionary]);
}


#pragma mark References

- (id)reference:(NSString *)reference inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceRequest responseType:UAGithubReferenceResponse]);
}


- (id)referencesInRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (id)tagsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/tags", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (id)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferenceCreateRequest responseType:UAGithubReferenceResponse withParameters:refDictionary]);
}


- (id)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceUpdateRequest responseType:UAGithubReferenceResponse withParameters:referenceDictionary]);
}


#pragma mark Tags

- (id)tag:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags/%@", repositoryPath, sha] requestType:UAGithubTagObjectRequest responseType:UAGithubAnnotatedTagResponse]);
}


#pragma mark Raw Commits

- (id)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits/%@", repositoryPath, commit] requestType:UAGithubRawCommitRequest responseType:UAGithubRawCommitResponse]);
}


- (id)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits", repositoryPath] requestType:UAGithubRawCommitCreateRequest responseType:UAGithubRawCommitResponse withParameters:commitDictionary]);
}


@end
