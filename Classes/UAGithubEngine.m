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

#import "NSInvocation+blocks.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"api.github.com"


@interface UAGithubEngine (Private)

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error;
- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page error:(NSError **)error;

@end


@implementation UAGithubEngine

@synthesize username, password, reachability, isReachable;

#pragma mark
#pragma mark Setup & Teardown
#pragma mark

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword withReachability:(BOOL)withReach
{
    self = [super init];
	if (self) 
	{
		username = aUsername;
		password = aPassword;
		if (withReach)
		{
			reachability = [[UAReachability alloc] init];
		}
	}
	
	
	return self;
		
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

- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page error:(NSError **)error
{
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@/%@", API_PROTOCOL, API_DOMAIN, path];
    NSData *jsonData = nil;
    NSError *serializationError = nil;
    
    if ([params count] > 0)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&serializationError];
        
        if (serializationError)
        {
            *error = serializationError;
            return nil;
        }
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
        case UAGithubTeamCreateRequest:
		{
			[urlRequest setHTTPMethod:@"POST"];
		}
			break;

		case UAGithubCollaboratorAddRequest:
        case UAGithubIssueLabelReplaceRequest:
        case UAGithubFollowRequest:
        case UAGithubGistStarRequest:
        case UAGithubPullRequestMergeRequest:            
        case UAGithubOrganizationMembershipPublicizeRequest:
        case UAGithubTeamMemberAddRequest:
        case UAGithubTeamRepositoryManagershipAddRequest:
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
        case UAGithubOrganizationUpdateRequest: 
        case UAGithubTeamUpdateRequest:
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
        case UAGithubOrganizationMemberRemoveRequest:
        case UAGithubOrganizationMembershipConcealRequest:
        case UAGithubTeamDeleteRequest:
        case UAGithubTeamMemberRemoveRequest:
        case UAGithubTeamRepositoryManagershipRemoveRequest:
        {
            [urlRequest setHTTPMethod:@"DELETE"];
        }
            break;
            
		default:
			break;
	}
	
    __block NSError *blockError = nil;
    
    id returnValue = [UAGithubURLConnection asyncRequest:urlRequest 
                                success:^(NSData *data, NSURLResponse *response)
                                {
                                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                    int statusCode = resp.statusCode;
                                    
                                    
                                    if ([[[resp allHeaderFields] allKeys] containsObject:@"X-Ratelimit-Remaining"] && [[[resp allHeaderFields] valueForKey:@"X-Ratelimit-Remaining"] isEqualToString:@"1"])
                                    {                                     
                                        return [NSError errorWithDomain:UAGithubAPILimitReached code:statusCode userInfo:[NSDictionary dictionaryWithObject:urlRequest forKey:@"request"]];
                                    }
                                    
                                    if (statusCode >= 400) 
                                    {
                                        if (statusCode == 404)
                                        {
                                            switch (requestType)
                                            {
                                                case UAGithubFollowingRequest:
                                                case UAGithubGistStarStatusRequest:
                                                case UAGithubOrganizationMembershipStatusRequest:
                                                case UAGithubTeamMembershipStatusRequest:
                                                case UAGithubTeamRepositoryManagershipStatusRequest:
                                                {
                                                    return [NSNumber numberWithBool:NO];
                                                }
                                                    break;
                                                default:
                                                    break;
                                            }
                                        }
                                        
                                        return [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:[NSDictionary dictionaryWithObject:urlRequest forKey:@"request"]];
                                                                                
                                    } 
                                    
                                    else if (statusCode == 204)
                                    {
                                        return [NSNumber numberWithBool:YES]; 
                                    }
                                    
                                    else
                                    {
                                        return [UAGithubJSONParser parseJSON:data error:&blockError];
                                    }

                                }
                                failure:^(NSError *parserError)
                                {
                                    return parserError;
                                }
     ];

    // If returnValue is of class NSArray, everything's fine.
    // If it's an NSNumber YES, then we're looking at a successful call that expects a No Content response.
    // If it's an NSNumber NO then that's a successful call to a method that returns an expected 404 response.
    // If it's an NSError, then it's either a connection error, an HTTP error (eg 404), or a parser error. Inspect the NSError instance to determine which.
    
    if (blockError)
    {
        *error = blockError;
        return nil;
    }
    
    return returnValue;
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:params page:0 error:error];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:page error:error];
}


- (id)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:0 error:error];
}
}


#pragma mark 
#pragma mark Gists
#pragma mark

- (id)gistsForUser:(NSString *)user completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/gists", user] requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)gistsWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);

}

- (id)publicGistsWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists/public" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)starredGistsWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists/starred" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (id)gist:(NSString *)gistId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistRequest responseType:UAGithubGistResponse]);
}


- (id)createGist:(NSDictionary *)gistDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"gists" requestType:UAGithubGistCreateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (id)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistUpdateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (BOOL)starGist:(NSString *)gistId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)unstarGist:(NSString *)gistId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistUnstarRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)gistIsStarred:(NSString *)gistId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarStatusRequest responseType:UAGithubNoContentResponse]);
}


- (id)forkGist:(NSString *)gistId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/fork", gistId] requestType:UAGithubGistForkRequest responseType:UAGithubGistResponse]);
}


- (BOOL)deleteGist:(NSString *)gistId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Comments

- (id)commentsForGist:(NSString *)gistId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentsRequest responseType:UAGithubGistCommentsResponse]);
}


- (id)gistComment:(NSInteger)commentId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentRequest responseType:UAGithubGistCommentResponse]);
}


- (id)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentCreateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (id)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentUpdateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (BOOL)deleteGistComment:(NSInteger)commentId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Issues 
#pragma mark

- (id)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType completion:(id(^)(id obj))successBlock_
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


- (id)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


- (id)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (id)closeIssue:(NSString *)issuePath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubIssueCloseRequest responseType:UAGithubIssueResponse]);	
}


- (id)reopenIssue:(NSString *)issuePath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubIssueReopenRequest responseType:UAGithubIssueResponse]);	
}


- (BOOL)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


#pragma mark Comments

- (id)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse]);	
}


- (id)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse]);
}


- (id)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
	
}


- (id)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody completion:(id(^)(id obj))successBlock_
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
}


- (BOOL)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse]);
}


#pragma mark Events

- (id)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/events", repositoryPath, issueId] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (id)issueEventsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events", repositoryPath] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (id)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events/%d", repositoryPath, eventId] requestType:UAGithubIssueEventRequest responseType:UAGithubIssueEventResponse]);
}


#pragma mark Labels

- (id)labelsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse]);	
}


- (id)label:(NSString *)labelName inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse]);
}

- (id)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary]);	
}


- (id)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary]);
}


- (BOOL)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse]);	
}


- (id)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (BOOL)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse]);	
}


- (BOOL)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL (^)(id))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueNumber] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (id)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (id)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


- (id)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


#pragma mark Milestones

- (id)milestonesForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse]);
}


- (id)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse]);
}


- (id)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]);
}


- (id)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]); 
}


- (BOOL)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse]);
}


#pragma mark
#pragma mark Organizations
#pragma mark

- (id)organizationsForUser:(NSString *)user completion:(id(^)(id obj))successBlock_
{ 
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/orgs", user] requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse]);
}


- (id)organizationsWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/orgs" requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse]);
}


- (id)organization:(NSString *)org withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationRequest responseType:UAGithubOrganizationResponse]);
}


- (id)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary completion:(id(^)(id))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationUpdateRequest responseType:UAGithubOrganizationResponse withParameters:orgDictionary]);
}


#pragma mark Members

- (id)membersOfOrganization:(NSString *)org withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse]);
}


- (BOOL)user:(NSString *)user isMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)removeUser:(NSString *)user fromOrganization:(NSString *)org withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMemberRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (id)publicMembersOfOrganization:(NSString *)org withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse]);
}


- (BOOL)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipPublicizeRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipConcealRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Teams

- (id)teamsInOrganization:(NSString *)org withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamsRequest responseType:UAGithubTeamsResponse]);    
}


- (id)team:(NSInteger)teamId withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamRequest responseType:UAGithubTeamResponse]);
}


- (id)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamCreateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary]);
}


- (id)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamUpdateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary]);
}


- (BOOL)deleteTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamDeleteRequest responseType:UAGithubNoContentResponse]);
}


- (id)membersOfTeam:(NSInteger)teamId withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d/members", teamId] requestType:UAGithubTeamMembersRequest responseType:UAGithubUsersResponse]);
}


- (BOOL)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)addUser:(NSString *)user toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMemberAddRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMemberRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (id)repositoriesForTeam:(NSInteger)teamId withCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos", teamId] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (BOOL)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipAddRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipRemoveRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (id)pullRequestsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestsRequest responseType:UAGithubPullRequestsResponse]);
}


- (id)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestRequest responseType:UAGithubPullRequestResponse]);
}


- (id)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestCreateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (id)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestUpdateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (id)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/commits", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommitsRequest responseType:UAGithubPullRequestCommitsResponse]);
}


- (id)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/files", repositoryPath, pullRequestId] requestType:UAGithubPullRequestFilesRequest responseType:UAGithubPullRequestFilesResponse]);
}


- (BOOL)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeStatusRequest responseType:UAGithubNoContentResponse]);
}


- (id)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeRequest responseType:UAGithubPullRequestMergeSuccessStatusResponse]);
}


#pragma mark Comments

- (id)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentsRequest responseType:UAGithubPullRequestCommentsResponse]);
}


- (id)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentRequest responseType:UAGithubPullRequestCommentResponse]);
}


- (id)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentCreateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (id)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentUpdateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (BOOL)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentDeleteRequest responseType:UAGithubPullRequestCommentResponse]);
}


#pragma mark
#pragma mark Repositories
#pragma mark

- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self repositoriesForUser:aUser includeWatched:watched page:1 completion:successBlock_]);	
}

#pragma mark TODO watched repos?
- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/repos", aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	
}


- (id)repositoriesWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/repos" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (id)createRepositoryWithInfo:(NSDictionary *)infoDictionary completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:@"user/repos" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);	
}


- (id)repository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse]);	
}


- (id)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);
}


- (id)contributorsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
   	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/contributitors", repositoryPath] requestType:UAGithubRepositoryContributorsRequest responseType:UAGithubUsersResponse]);
}


- (id)languageBreakdownForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse]);	
}


- (id)teamsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/teams", repositoryPath] requestType:UAGithubRepositoryTeamsRequest responseType:UAGithubRepositoryTeamsResponse]);
}


- (id)annotatedTagsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse]);	
}


- (id)branchesForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse]);	
}


#pragma mark Collaborators

- (id)collaboratorsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse]);	
}


- (BOOL)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, user] requestType:UAGithubCollaboratorsRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse]);
}


- (BOOL)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse]);
}


#pragma mark Commits

- (id)commitsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse]);	
}


- (id)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse]);	
}


#pragma mark Commit Comments

- (id)commitCommentsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse]);
}


- (id)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse]);
}


- (id)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary]);
}


- (id)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse]);
}


- (id)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary]);
}


- (BOOL)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Downloads

- (id)downloadsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadsRequest responseType:UAGithubDownloadsResponse]);
}


- (id)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadRequest responseType:UAGithubDownloadResponse]);
}


- (id)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadAddRequest responseType:UAGithubDownloadResponse withParameters:downloadDictionary]);
}


- (BOOL)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Forks

- (id)forksForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForksRequest responseType:UAGithubRepositoriesResponse]);
}


- (id)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org completion:(id(^)(id obj))successBlock_
{
    if (org)
    {
        return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:[NSDictionary dictionaryWithObject:org forKey:@"org"]]);
    }
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse]);
}


- (id)forkRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self forkRepository:repositoryPath inOrganization:nil completion:successBlock_(nil)]);
}


#pragma mark Keys

- (id)deployKeysForRepository:(NSString *)repositoryName completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse]);
}


- (id)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyRequest responseType:UAGithubDeployKeyResponse]);
}


- (id)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName completion:(id(^)(id obj))successBlock_
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params]);
    
}


- (id)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyEditRequest responseType:UAGithubDeployKeyResponse withParameters:keyDictionary]);
}


- (BOOL)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryName, keyId] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubNoContentResponse]);
    
}


#pragma mark Watching

- (id)watchersForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/watchers", repositoryPath] requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse]);
}


- (id)watchedRepositoriesForUser:(NSString *)user completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/watched", user] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (id)watchedRepositoriescompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/watched" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}



- (BOOL)repositoryIsWatched:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchingRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)watchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubNoContentResponse]);	 
}


- (BOOL)unwatchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Hooks

- (id)hooksForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHooksRequest responseType:UAGithubRepositoryHooksResponse]);
}


- (id)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookRequest responseType:UAGithubRepositoryHookResponse]);
}


- (id)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHookAddRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary]);
}


- (id)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookEditRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary]);
}


- (BOOL)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookTestRequest responseType:UAGithubNoContentResponse]);
}


- (BOOL)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Users
#pragma mark 

- (id)user:(NSString *)user completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (id)userWithCompletion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (id)editUser:(NSDictionary *)userDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary]);
}


#pragma mark Emails

- (id)emailAddressescompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailsRequest responseType:UAGithubEmailsResponse]);
}


- (id)addEmailAddresses:(NSArray *)emails completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailAddRequest responseType:UAGithubEmailsResponse withParameters:emails]);
}


- (BOOL)deleteEmailAddresses:(NSArray *)emails completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/emails" requestType:UAGithubEmailDeleteRequest responseType:UAGithubNoContentResponse withParameters:emails]);
}


#pragma mark Followers
// List a user's followers
- (id)followers:(NSString *)user completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse]);	    
    
}

// List the authenticated user's followers
- (id)followersWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/followers" requestType:UAGithubUsersRequest responseType:UAGithubFollowersResponse]);
}

// List who a user is following
- (id)following:(NSString *)user completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse]);	    
}

// List who the authenticated user is following
- (id)followingWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/following" requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse]);
}

// Check if the authenticated user follows another user
- (BOOL)follows:(NSString *)user completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowingRequest responseType:UAGithubNoContentResponse]);
}

// Follow a user
- (BOOL)follow:(NSString *)user  completion:(BOOL(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse]);	    
   
}

// Unfollow a user
- (BOOL)unfollow:(NSString *)user completion:(BOOL(^)(id obj))successBlock_
{
 	return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse]);	        
}


#pragma mark Keys

- (id)publicKeysWithCompletion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse]);
}


- (id)publicKey:(NSInteger)keyId completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse]);
}


- (id)addPublicKey:(NSDictionary *)keyDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (id)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (BOOL)deletePublicKey:(NSInteger)keyId completion:(BOOL(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse]);
}


- (id)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
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


- (id)eventsForNetwork:(NSString *)networkPath completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"networks/%@/events", networkPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}
                         

- (id)eventsReceivedByUser:(NSString *)user completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/received_events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (id)eventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (id)publicEventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events/public", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (id)eventsForOrganization:(NSString *)organization user:(NSString *)user completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events/orgs/%@", user, organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (id)publicEventsForOrganization:(NSString *)organization completion:(id(^)(id obj))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/events", organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


#pragma mark -
#pragma mark Git Database API
#pragma mark -

#pragma mark Trees

- (id)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees/%@%@", repositoryPath, sha, recursive ? @"?recursive=1" : @""] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse]);	
}


- (id)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees", repositoryPath] requestType:UAGithubTreeCreateRequest responseType:UAGithubTreeResponse withParameters:treeDictionary]);
}


#pragma mark Blobs

- (id)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
	return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs/%@", repositoryPath, sha] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse]);	
}


- (id)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs", repositoryPath] requestType:UAGithubBlobCreateRequest responseType:UAGithubSHAResponse withParameters:blobDictionary]);
}


#pragma mark References

- (id)reference:(NSString *)reference inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceRequest responseType:UAGithubReferenceResponse]);
}


- (id)referencesInRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (id)tagsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/tags", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (id)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferenceCreateRequest responseType:UAGithubReferenceResponse withParameters:refDictionary]);
}


- (id)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceUpdateRequest responseType:UAGithubReferenceResponse withParameters:referenceDictionary]);
}


#pragma mark Tags

- (id)tag:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags/%@", repositoryPath, sha] requestType:UAGithubTagObjectRequest responseType:UAGithubAnnotatedTagResponse]);
}


#pragma mark Raw Commits

- (id)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits/%@", repositoryPath, commit] requestType:UAGithubRawCommitRequest responseType:UAGithubRawCommitResponse]);
}


- (id)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_
{
    return successBlock_([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits", repositoryPath] requestType:UAGithubRawCommitCreateRequest responseType:UAGithubRawCommitResponse withParameters:commitDictionary]);
}


@end
