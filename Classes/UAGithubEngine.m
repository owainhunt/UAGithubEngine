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


- (void)invoke:(NSInvocation *)invocation success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    __unsafe_unretained NSError *error = nil;
    __unsafe_unretained id result;
    [invocation setArgument:&error atIndex:5];
    [invocation invoke];
    [invocation getReturnValue:&result];
    if (error)
    {
        failureBlock(error);
    }
    
    successBlock(result);
}


- (NSInvocation *)invocation:(void (^)(id obj))block
{
    return [NSInvocation jr_invocationWithTarget:self block:block];
}


#pragma mark 
#pragma mark Gists
#pragma mark

- (void)gistsForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSInvocation *theInvocation = [NSInvocation jr_invocationWithTarget:self block:^(id self){
        [self sendRequest:[NSString stringWithFormat:@"users/%@/gists", user] requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil];    
    }];
    [self invoke:theInvocation success:successBlock failure:failureBlock];
}


- (void)gistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"gists" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);

}

- (void)publicGistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"gists/public" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (void)starredGistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"gists/starred" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse]);
}


- (void)gist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistRequest responseType:UAGithubGistResponse]);
}


- (void)createGist:(NSDictionary *)gistDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"gists" requestType:UAGithubGistCreateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (void)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistUpdateRequest responseType:UAGithubGistResponse withParameters:gistDictionary]);
}


- (void)starGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarRequest responseType:UAGithubNoContentResponse]);
}


- (void)unstarGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistUnstarRequest responseType:UAGithubNoContentResponse]);
}


- (void)gistIsStarred:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)forkGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/fork", gistId] requestType:UAGithubGistForkRequest responseType:UAGithubGistResponse]);
}


- (void)deleteGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Comments

- (void)commentsForGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentsRequest responseType:UAGithubGistCommentsResponse]);
}


- (void)gistComment:(NSInteger)commentId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentRequest responseType:UAGithubGistCommentResponse]);
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentCreateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (void)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentUpdateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary]);
}


- (void)deleteGistComment:(NSInteger)commentId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"gists/comments/%d", commentId] requestType:UAGithubGistCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Issues 
#pragma mark

- (void)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType completion:(UAGithubEngineSuccessBlock)successBlock
{
	// Use UAGithubIssuesOpenRequest for open issues, UAGithubIssuesClosedRequest for closed issues.
    
	switch (requestType) {
		case UAGithubIssuesOpenRequest:
			return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:parameters]);
			break;
            
		case UAGithubIssuesClosedRequest:
			return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:parameters]);
			break;
        default:
            return nil;
			break;
	}
	return nil;
}


- (void)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


- (void)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary]);	
}


- (void)closeIssue:(NSString *)issuePath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubIssueCloseRequest responseType:UAGithubIssueResponse]);	
}


- (void)reopenIssue:(NSString *)issuePath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubIssueReopenRequest responseType:UAGithubIssueResponse]);	
}


- (void)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse]);	
}


#pragma mark Comments

- (void)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
 	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse]);	
}


- (void)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse]);
}


- (void)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
	
}


- (void)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody completion:(UAGithubEngineSuccessBlock)successBlock
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary]);
}


- (void)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%d", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse]);
}


#pragma mark Events

- (void)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/events", repositoryPath, issueId] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (void)issueEventsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events", repositoryPath] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse]);
}


- (void)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events/%d", repositoryPath, eventId] requestType:UAGithubIssueEventRequest responseType:UAGithubIssueEventResponse]);
}


#pragma mark Labels

- (void)labelsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse]);	
}


- (void)label:(NSString *)labelName inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse]);
}

- (void)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary]);	
}


- (void)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary]);
}


- (void)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse]);	
}


- (void)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (void)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse]);	
}


- (void)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL (^)(id))successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueNumber] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (void)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels]);
}


- (void)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%d/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


- (void)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse]);
}


#pragma mark Milestones

- (void)milestonesForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse]);
}


- (void)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse]);
}


- (void)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]);
}


- (void)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary]); 
}


- (void)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%d", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse]);
}


#pragma mark
#pragma mark Organizations
#pragma mark

- (void)organizationsForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{ 
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/orgs", user] requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse]);
}


- (void)organizationsWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/orgs" requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse]);
}


- (void)organization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationRequest responseType:UAGithubOrganizationResponse]);
}


- (void)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationUpdateRequest responseType:UAGithubOrganizationResponse withParameters:orgDictionary]);
}


#pragma mark Members

- (void)membersOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse]);
}


- (void)user:(NSString *)user isMemberOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)removeUser:(NSString *)user fromOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMemberRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (void)publicMembersOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse]);
}


- (void)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipPublicizeRequest responseType:UAGithubNoContentResponse]);
}


- (void)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipConcealRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Teams

- (void)teamsInOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamsRequest responseType:UAGithubTeamsResponse]);    
}


- (void)team:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamRequest responseType:UAGithubTeamResponse]);
}


- (void)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamCreateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary]);
}


- (void)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamUpdateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary]);
}


- (void)deleteTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d", teamId] requestType:UAGithubTeamDeleteRequest responseType:UAGithubNoContentResponse]);
}


- (void)membersOfTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/members", teamId] requestType:UAGithubTeamMembersRequest responseType:UAGithubUsersResponse]);
}


- (void)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMembershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)addUser:(NSString *)user toTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMemberAddRequest responseType:UAGithubNoContentResponse]);
}


- (void)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/members/%@", teamId, user] requestType:UAGithubTeamMemberRemoveRequest responseType:UAGithubNoContentResponse]);
}


- (void)repositoriesForTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos", teamId] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (void)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipAddRequest responseType:UAGithubNoContentResponse]);
}


- (void)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"teams/%d/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipRemoveRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (void)pullRequestsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestsRequest responseType:UAGithubPullRequestsResponse]);
}


- (void)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestRequest responseType:UAGithubPullRequestResponse]);
}


- (void)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestCreateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (void)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d", repositoryPath, pullRequestId] requestType:UAGithubPullRequestUpdateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary]);
}


- (void)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/commits", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommitsRequest responseType:UAGithubPullRequestCommitsResponse]);
}


- (void)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/files", repositoryPath, pullRequestId] requestType:UAGithubPullRequestFilesRequest responseType:UAGithubPullRequestFilesResponse]);
}


- (void)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeStatusRequest responseType:UAGithubNoContentResponse]);
}


- (void)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeRequest responseType:UAGithubPullRequestMergeSuccessStatusResponse]);
}


#pragma mark Comments

- (void)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentsRequest responseType:UAGithubPullRequestCommentsResponse]);
}


- (void)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentRequest responseType:UAGithubPullRequestCommentResponse]);
}


- (void)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%d/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentCreateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (void)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentUpdateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary]);
}


- (void)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%d", repositoryPath, commentId] requestType:UAGithubPullRequestCommentDeleteRequest responseType:UAGithubPullRequestCommentResponse]);
}


#pragma mark
#pragma mark Repositories
#pragma mark

- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self repositoriesForUser:aUser includeWatched:watched page:1 completion:successBlock]);	
}

#pragma mark TODO watched repos?
- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/repos", aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);	
}


- (void)repositoriesWithCompletion:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self invoke:[self invocation:^(id self){[self sendRequest:@"user/repos" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil];}] success:successBlock failure:failureBlock];
}


- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:@"user/repos" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);	
}


- (void)repository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse]);	
}


- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary]);
}


- (void)contributorsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
   	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/contributitors", repositoryPath] requestType:UAGithubRepositoryContributorsRequest responseType:UAGithubUsersResponse]);
}


- (void)languageBreakdownForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse]);	
}


- (void)teamsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/teams", repositoryPath] requestType:UAGithubRepositoryTeamsRequest responseType:UAGithubRepositoryTeamsResponse]);
}


- (void)annotatedTagsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse]);	
}


- (void)branchesForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse]);	
}


#pragma mark Collaborators

- (void)collaboratorsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse]);	
}


- (void)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, user] requestType:UAGithubCollaboratorsRequest responseType:UAGithubNoContentResponse]);
}


- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse]);
}


- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse]);
}


#pragma mark Commits

- (void)commitsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse]);	
}


- (void)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse]);	
}


#pragma mark Commit Comments

- (void)commitCommentsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse]);
}


- (void)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse]);
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary]);
}


- (void)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse]);
}


- (void)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary]);
}


- (void)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%d", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Downloads

- (void)downloadsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadsRequest responseType:UAGithubDownloadsResponse]);
}


- (void)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadRequest responseType:UAGithubDownloadResponse]);
}


- (void)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadAddRequest responseType:UAGithubDownloadResponse withParameters:downloadDictionary]);
}


- (void)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%d", repositoryPath, downloadId] requestType:UAGithubDownloadDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Forks

- (void)forksForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForksRequest responseType:UAGithubRepositoriesResponse]);
}


- (void)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org completion:(UAGithubEngineSuccessBlock)successBlock
{
    if (org)
    {
        return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:[NSDictionary dictionaryWithObject:org forKey:@"org"]]);
    }
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse]);
}


- (void)forkRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self forkRepository:repositoryPath inOrganization:nil completion:successBlock(nil)]);
}


#pragma mark Keys

- (void)deployKeysForRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse]);
}


- (void)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyRequest responseType:UAGithubDeployKeyResponse]);
}


- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params]);
    
}


- (void)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryPath, keyId] requestType:UAGithubDeployKeyEditRequest responseType:UAGithubDeployKeyResponse withParameters:keyDictionary]);
}


- (void)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%d", repositoryName, keyId] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubNoContentResponse]);
    
}


#pragma mark Watching

- (void)watchersForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/watchers", repositoryPath] requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse]);
}


- (void)watchedRepositoriesForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/watched", user] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}


- (void)watchedRepositoriescompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/watched" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse]);
}



- (void)repositoryIsWatched:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchingRequest responseType:UAGithubNoContentResponse]);
}


- (void)watchRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubNoContentResponse]);	 
}


- (void)unwatchRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark Hooks

- (void)hooksForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHooksRequest responseType:UAGithubRepositoryHooksResponse]);
}


- (void)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookRequest responseType:UAGithubRepositoryHookResponse]);
}


- (void)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHookAddRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary]);
}


- (void)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookEditRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary]);
}


- (void)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookTestRequest responseType:UAGithubNoContentResponse]);
}


- (void)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%d", repositoryPath, hookId] requestType:UAGithubRepositoryHookDeleteRequest responseType:UAGithubNoContentResponse]);
}


#pragma mark
#pragma mark Users
#pragma mark 

- (void)user:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (void)userWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse]);	
}


- (void)editUser:(NSDictionary *)userDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary]);
}


#pragma mark Emails

- (void)emailAddressescompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/emails" requestType:UAGithubEmailsRequest responseType:UAGithubEmailsResponse]);
}


- (void)addEmailAddresses:(NSArray *)emails completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/emails" requestType:UAGithubEmailAddRequest responseType:UAGithubEmailsResponse withParameters:emails]);
}


- (void)deleteEmailAddresses:(NSArray *)emails completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/emails" requestType:UAGithubEmailDeleteRequest responseType:UAGithubNoContentResponse withParameters:emails]);
}


#pragma mark Followers
// List a user's followers
- (void)followers:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse]);	    
    
}

// List the authenticated user's followers
- (void)followersWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/followers" requestType:UAGithubUsersRequest responseType:UAGithubFollowersResponse]);
}

// List who a user is following
- (void)following:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse]);	    
}

// List who the authenticated user is following
- (void)followingWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/following" requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse]);
}

// Check if the authenticated user follows another user
- (void)follows:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowingRequest responseType:UAGithubNoContentResponse]);
}

// Follow a user
- (void)follow:(NSString *)user  completion:(UAGithubEngineSuccessBlock)successBlock
{
 	return successBlock([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse]);	    
   
}

// Unfollow a user
- (void)unfollow:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
 	return successBlock([self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse]);	        
}


#pragma mark Keys

- (void)publicKeysWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse]);
}


- (void)publicKey:(NSInteger)keyId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse]);
}


- (void)addPublicKey:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (void)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary]);
}


- (void)deletePublicKey:(NSInteger)keyId completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"user/keys/%d", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse]);
}


- (void)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags", repositoryPath] requestType:UAGithubTagObjectCreateRequest responseType:UAGithubAnnotatedTagResponse withParameters:tagDictionary]);
}


#pragma mark
#pragma mark Events
#pragma mark

- (void)eventsWithCompletion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:@"events" requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)eventsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/events", repositoryPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)eventsForNetwork:(NSString *)networkPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"networks/%@/events", networkPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}
                         

- (void)eventsReceivedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/received_events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)eventsPerformedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)publicEventsPerformedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events/public", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)eventsForOrganization:(NSString *)organization user:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"users/%@/events/orgs/%@", user, organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


- (void)publicEventsForOrganization:(NSString *)organization completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"orgs/%@/events", organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse]);
}


#pragma mark -
#pragma mark Git Database API
#pragma mark -

#pragma mark Trees

- (void)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees/%@%@", repositoryPath, sha, recursive ? @"?recursive=1" : @""] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse]);	
}


- (void)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees", repositoryPath] requestType:UAGithubTreeCreateRequest responseType:UAGithubTreeResponse withParameters:treeDictionary]);
}


#pragma mark Blobs

- (void)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
	return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs/%@", repositoryPath, sha] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse]);	
}


- (void)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs", repositoryPath] requestType:UAGithubBlobCreateRequest responseType:UAGithubSHAResponse withParameters:blobDictionary]);
}


#pragma mark References

- (void)reference:(NSString *)reference inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceRequest responseType:UAGithubReferenceResponse]);
}


- (void)referencesInRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (void)tagsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/tags", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse]);
}


- (void)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferenceCreateRequest responseType:UAGithubReferenceResponse withParameters:refDictionary]);
}


- (void)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceUpdateRequest responseType:UAGithubReferenceResponse withParameters:referenceDictionary]);
}


#pragma mark Tags

- (void)tag:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags/%@", repositoryPath, sha] requestType:UAGithubTagObjectRequest responseType:UAGithubAnnotatedTagResponse]);
}


#pragma mark Raw Commits

- (void)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits/%@", repositoryPath, commit] requestType:UAGithubRawCommitRequest responseType:UAGithubRawCommitResponse]);
}


- (void)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock
{
    return successBlock([self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits", repositoryPath] requestType:UAGithubRawCommitCreateRequest responseType:UAGithubRawCommitResponse withParameters:commitDictionary]);
}

@end
