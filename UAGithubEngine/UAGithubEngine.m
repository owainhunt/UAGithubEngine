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
#import "UAGithubEngineConstants.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubURLConnection.h"

#import "NSString+UAGithubEngineUtilities.h"
#import "NSData+Base64.h"
#import "NSString+UUID.h"

#import "NSInvocation+Blocks.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"api.github.com"


@interface UAGithubEngine ()

@property BOOL isMultiPageRequest;
@property (nonatomic, strong) NSURL *nextPageURL;
@property (nonatomic, strong) NSURL *lastPageURL;
@property (nonatomic, strong) NSMutableArray *multiPageArray;

- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error withNameOrNil:(NSString*)name;;
- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error withNameOrNil:(NSString*)name;;
- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error withNameOrNil:(NSString*)name;;
- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page error:(NSError **)error withNameOrNil:(NSString*)name;;

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
		self.username = aUsername;
		self.password = aPassword;
		if (withReach)
		{
			self.reachability = [[UAReachability alloc] init];
		}
        self.multiPageArray = [@[] mutableCopy];
		self.operationQueue = [[NSOperationQueue alloc] init];
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

- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params page:(NSInteger)page error:(NSError * __autoreleasing *)error  withNameOrNil:(NSString*)name
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
            [querystring appendFormat:@"&page=%ld", page];
        }
        else
        {
            querystring = [NSString stringWithFormat:@"?page=%ld", page];
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
        case UAGithubIssueAddRequest:
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
        case UAGithubMarkdownRequest:
        case UAGithubRepositoryMergeRequest:
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
        case UAGithubNotificationsMarkReadRequest:
        case UAGithubNotificationThreadSubscriptionRequest:
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
        case UAGithubNotificationsMarkThreadReadRequest:
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
        case UAGithubNotificationDeleteSubscriptionRequest:
        {
            [urlRequest setHTTPMethod:@"DELETE"];
        }
            break;
            
		default:
			break;
	}
	
	[UAGithubURLConnection sendAsynchronousRequest:urlRequest queue:_operationQueue completionHandler:
	 ^(NSURLResponse *response, NSData *responseData, NSError *error) {
		 
		 NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
		 NSInteger statusCode = resp.statusCode;
		 
		 if (statusCode >= 400 || statusCode == 204) {
			 
		 } else if(requestType == UAGithubMarkdownRequest) {
			 
		 } else {
			 [_delegate didReceiveData:responseData forPullRequestsInRepositoryWithName:name];
		 }
		 
	 }];
	
   }


- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(id)params error:(NSError **)error withNameOrNil:(NSString*)name;
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:params page:0 error:error  withNameOrNil:name];
}


- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType page:(NSInteger)page error:(NSError **)error withNameOrNil:(NSString*)name;
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:page error:error  withNameOrNil:name];
}


- (void)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType error:(NSError **)error withNameOrNil:(NSString*)name;
{
    return [self sendRequest:path requestType:requestType responseType:responseType withParameters:nil page:0 error:error withNameOrNil:name];
}

#pragma mark 
#pragma mark Gists
#pragma mark

- (void)gistsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/gists", user] requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil withNameOrNil:user];
}


- (void)gistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:@"gists" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil withNameOrNil:nil];
}

- (void)publicGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"gists/public" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil withNameOrNil:nil];
}


- (void)starredGistsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"gists/starred" requestType:UAGithubGistsRequest responseType:UAGithubGistsResponse error:nil withNameOrNil:nil];
}


- (void)gist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistRequest responseType:UAGithubGistResponse error:nil withNameOrNil:gistId];
}


- (void)createGist:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"gists" requestType:UAGithubGistCreateRequest responseType:UAGithubGistResponse withParameters:gistDictionary error:nil withNameOrNil:nil];
}


- (void)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistUpdateRequest responseType:UAGithubGistResponse withParameters:gistDictionary error:nil withNameOrNil:nil];
}


- (void)starGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:nil];
}


- (void)unstarGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistUnstarRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:gistId];
}


- (void)gistIsStarred:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/star", gistId] requestType:UAGithubGistStarStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:gistId];
}


- (void)forkGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/fork", gistId] requestType:UAGithubGistForkRequest responseType:UAGithubGistResponse error:nil withNameOrNil:gistId];
}


- (void)deleteGist:(NSString *)gistId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@", gistId] requestType:UAGithubGistDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:gistId];
}


#pragma mark Comments

- (void)commentsForGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentsRequest responseType:UAGithubGistCommentsResponse error:nil withNameOrNil:gistId];
}


- (void)gistComment:(NSInteger)commentId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentRequest responseType:UAGithubGistCommentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",commentId]];
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/%@/comments", gistId] requestType:UAGithubGistCommentCreateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary error:nil withNameOrNil:gistId];
}


- (void)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentUpdateRequest responseType:UAGithubGistCommentResponse withParameters:commentDictionary error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",commentId]];
}


- (void)deleteGistComment:(NSInteger)commentId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"gists/comments/%ld", commentId] requestType:UAGithubGistCommentDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",commentId]];
}


#pragma mark
#pragma mark Issues 
#pragma mark

- (void)assignedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"issues?state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil withNameOrNil:state];
}


- (void)createdIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"issues?filter=created&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil withNameOrNil:state];
}


- (void)subscribedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"issues?filter=subscribed&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil withNameOrNil:state];
}


- (void)mentionedIssuesWithState:(NSString *)state success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"issues?filter=mentioned&state=%@", state] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse error:nil withNameOrNil:state];
}


- (void)openIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:parameters error:nil withNameOrNil:repositoryPath];
}


- (void)closedIssuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues?state=closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:parameters error:nil withNameOrNil:repositoryPath];
}


- (void)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse error:nil withNameOrNil:repositoryPath];
}


- (void)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)closeIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *paramsDictionary = @{ @"state" : @"closed" };
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:paramsDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)reopenIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *paramsDictionary = @{ @"state" : @"open" };
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:paramsDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",issueNumber]];
}


#pragma mark Assignees

- (void)assigneesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/assignees", repositoryPath] requestType:UAGithubAssigneesRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:repositoryPath];
}


- (void)user:(NSString *)user isAssigneeForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/assignees/%@", repositoryPath, user] requestType:UAGithubAssigneeRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
}


#pragma mark Comments

- (void)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentRequest responseType:UAGithubIssueCommentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/comments", repositoryPath, issueNumber] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary error:nil withNameOrNil:repositoryPath];
	
}


- (void)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:commentBody forKey:@"body"];
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentEditRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/comments/%ld", repositoryPath, commentNumber] requestType:UAGithubIssueCommentDeleteRequest responseType:UAGithubIssueCommentResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark
#pragma mark Activity
#pragma mark


#pragma mark Notifications

- (void)notificationsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"notifications" requestType:UAGithubNotificationsRequest responseType:UAGithubNotificationsResponse error:nil withNameOrNil:nil];
}

- (void)notificationsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/notifications", repositoryPath] requestType:UAGithubNotificationsRequest responseType:UAGithubNotificationsResponse error:nil withNameOrNil:repositoryPath];
}

- (void)notificationsForThread:(NSInteger)threadId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"notifications/threads/%ld", threadId] requestType:UAGithubNotificationsRequest  responseType:UAGithubNotificationsResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",threadId]];
}

- (void)markNotificationsAsReadWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"read" : @"true" } copy];
    
    [self sendRequest:@"notifications" requestType:UAGithubNotificationsMarkReadRequest responseType:UAGithubNoContentResponse withParameters:params error:nil withNameOrNil:nil];
}

- (void)markNotificationsAsReadInRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"read" : @"true" } copy];
    
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/notifications", repositoryPath] requestType:UAGithubNotificationsMarkReadRequest responseType:UAGithubNoContentResponse withParameters:params error:nil withNameOrNil:repositoryPath];
}

- (void)markNotificationThreadAsRead:(NSInteger)threadId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"read" : @"true" } copy];
    
    [self sendRequest:[NSString stringWithFormat:@"notifications/threads/%ld", threadId] requestType:UAGithubNotificationsMarkThreadReadRequest responseType:UAGithubNoContentResponse withParameters:params error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",threadId]];
}

- (void)currentUserIsSubscribedToNotificationThread:(NSInteger)threadId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"notifications/threads/%ld/subscription", threadId] requestType:UAGithubNotificationsRequest responseType:UAGithubNotificationThreadSubscriptionResponse error:nil withNameOrNil:nil];
}

- (void)subscribeCurrentUserToNotificationThread:(NSInteger)threadId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"subscribed" : @"true" } copy];
    
    [self sendRequest:[NSString stringWithFormat:@"notifications/threads/%ld/subscription", threadId] requestType:UAGithubNotificationThreadSubscriptionRequest responseType:UAGithubNotificationThreadSubscriptionResponse withParameters:params error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",threadId]];
}

- (void)unsubscribeCurrentUserFromNotificationThread:(NSInteger)threadId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"subscribed" : @"false" } copy];
    
    [self sendRequest:[NSString stringWithFormat:@"notifications/threads/%ld/subscription", threadId] requestType:UAGithubNotificationDeleteSubscriptionRequest responseType:UAGithubNotificationThreadSubscriptionResponse withParameters:params error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",threadId]];
}


#pragma mark Events

- (void)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/events", repositoryPath, issueId] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",issueId]];
}


- (void)issueEventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events", repositoryPath] requestType:UAGithubIssueEventsRequest responseType:UAGithubIssueEventsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/events/%ld", repositoryPath, eventId] requestType:UAGithubIssueEventRequest responseType:UAGithubIssueEventResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",eventId]];
}


#pragma mark Labels

- (void)labelsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)label:(NSString *)labelName inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubIssueLabelRequest responseType:UAGithubIssueLabelResponse error:nil withNameOrNil:repositoryPath];
}

- (void)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels", repositoryPath] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labelDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelEditRequest responseType:UAGithubRepositoryLabelResponse withParameters:labelDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/labels/%@", repositoryPath, labelName] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:labels error:nil withNameOrNil:repositoryPath];
}


- (void)removeLabel:(NSString *)labelName fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels/%@", repositoryPath, issueNumber, labelName] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueNumber] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelReplaceRequest responseType:UAGithubIssueLabelsResponse withParameters:labels error:nil withNameOrNil:repositoryPath];
}


- (void)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld/labels", repositoryPath, issueId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld/labels", repositoryPath, milestoneId] requestType:UAGithubIssueLabelsRequest responseType:UAGithubIssueLabelsResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Milestones

- (void)milestonesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestonesRequest responseType:UAGithubMilestonesResponse error:nil withNameOrNil:repositoryPath];
}


- (void)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneRequest responseType:UAGithubMilestoneResponse error:nil withNameOrNil:repositoryPath];
}


- (void)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones", repositoryPath] requestType:UAGithubMilestoneCreateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneUpdateRequest responseType:UAGithubMilestoneResponse withParameters:infoDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/milestones/%ld", repositoryPath, milestoneNumber] requestType:UAGithubMilestoneDeleteRequest responseType:UAGithubMilestoneResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addIssue:(NSInteger)issueNumber toMilestone:(NSInteger)milestoneNumber inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = @{ @"milestone" : [NSString stringWithFormat:@"%ld", milestoneNumber] };
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/issues/%ld", repositoryPath, issueNumber] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:params error:nil withNameOrNil:repositoryPath];

}



#pragma mark
#pragma mark Organizations
#pragma mark

- (void)organizationsForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{ 
    [self sendRequest:[NSString stringWithFormat:@"users/%@/orgs", user] requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse error:nil withNameOrNil:user];
}


- (void)organizationsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/orgs" requestType:UAGithubOrganizationsRequest responseType:UAGithubOrganizationsResponse error:nil withNameOrNil:nil];
}


- (void)organization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationRequest responseType:UAGithubOrganizationResponse error:nil withNameOrNil:org];
}


- (void)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@", org] requestType:UAGithubOrganizationUpdateRequest responseType:UAGithubOrganizationResponse withParameters:orgDictionary error:nil withNameOrNil:org];
}


#pragma mark Members

- (void)membersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:org];
}


- (void)user:(NSString *)user isMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
}


- (void)removeUser:(NSString *)user fromOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/members/%@", org, user] requestType:UAGithubOrganizationMemberRemoveRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%@",user,org]];
}


- (void)publicMembersOfOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members", org] requestType:UAGithubOrganizationMembersRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:org];
}


- (void)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
}


- (void)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipPublicizeRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%@",user,org]];
}


- (void)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/public_members/%@", org, user] requestType:UAGithubOrganizationMembershipConcealRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%@",user,org]];
}


#pragma mark Teams

- (void)teamsInOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamsRequest responseType:UAGithubTeamsResponse error:nil withNameOrNil:org];
}


- (void)team:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamRequest responseType:UAGithubTeamResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",teamId]];
}


- (void)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/teams", org] requestType:UAGithubTeamCreateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary error:nil withNameOrNil:org];
}


- (void)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamUpdateRequest responseType:UAGithubTeamResponse withParameters:teamDictionary error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",teamId]];
}


- (void)deleteTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld", teamId] requestType:UAGithubTeamDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",teamId]];
}


- (void)membersOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/members", teamId] requestType:UAGithubTeamMembersRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",teamId]];
}


- (void)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMembershipStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",user,teamId]];
}


- (void)addUser:(NSString *)user toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMemberAddRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",user,teamId]];
}


- (void)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/members/%@", teamId, user] requestType:UAGithubTeamMemberRemoveRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",user,teamId]];
}


- (void)repositoriesForTeam:(NSInteger)teamId withSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos", teamId] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%ld",teamId]];
}


- (void)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,teamId]];
}


- (void)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipAddRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,teamId]];
}


- (void)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withSuccess:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"teams/%ld/repos/%@", teamId, repositoryPath] requestType:UAGithubTeamRepositoryManagershipRemoveRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,teamId]];
}


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (void)pullRequestsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestsRequest responseType:UAGithubPullRequestsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld", repositoryPath, pullRequestId] requestType:UAGithubPullRequestRequest responseType:UAGithubPullRequestResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls", repositoryPath] requestType:UAGithubPullRequestCreateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld", repositoryPath, pullRequestId] requestType:UAGithubPullRequestUpdateRequest responseType:UAGithubPullRequestResponse withParameters:pullRequestDictionary error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/commits", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommitsRequest responseType:UAGithubPullRequestCommitsResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/files", repositoryPath, pullRequestId] requestType:UAGithubPullRequestFilesRequest responseType:UAGithubPullRequestFilesResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeStatusRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/merge", repositoryPath, pullRequestId] requestType:UAGithubPullRequestMergeRequest responseType:UAGithubPullRequestMergeSuccessStatusResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


#pragma mark Comments

- (void)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentsRequest responseType:UAGithubPullRequestCommentsResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentRequest responseType:UAGithubPullRequestCommentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,commentId]];
}


- (void)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/%ld/comments", repositoryPath, pullRequestId] requestType:UAGithubPullRequestCommentCreateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,pullRequestId]];
}


- (void)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentUpdateRequest responseType:UAGithubPullRequestCommentResponse withParameters:commentDictionary error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,commentId]];
}


- (void)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/pulls/comments/%ld", repositoryPath, commentId] requestType:UAGithubPullRequestCommentDeleteRequest responseType:UAGithubPullRequestCommentResponse error:nil withNameOrNil:[NSString stringWithFormat:@"%@-%ld",repositoryPath,commentId]];
}


#pragma mark
#pragma mark Repositories
#pragma mark

- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self repositoriesForUser:aUser includeWatched:watched page:1 success:successBlock failure:failureBlock];	
}

#pragma mark TODO watched repos?
- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"users/%@/repos", aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:aUser];
}


- (void)repositoriesWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/repos" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:nil];
}


- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:@"user/repos" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary error:nil withNameOrNil:nil];
}


- (void)repository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse error:nil withNameOrNil:repositoryPath];
}


- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)contributorsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
   	[self sendRequest:[NSString stringWithFormat:@"repos/%@/contributitors", repositoryPath] requestType:UAGithubRepositoryContributorsRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:repositoryPath];
}


- (void)languageBreakdownForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse error:nil withNameOrNil:repositoryPath];
}


- (void)teamsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/teams", repositoryPath] requestType:UAGithubRepositoryTeamsRequest responseType:UAGithubRepositoryTeamsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)annotatedTagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)branchesForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Collaborators

- (void)collaboratorsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, user] requestType:UAGithubCollaboratorsRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/collaborators/%@", repositoryPath, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Commits

- (void)commitsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits", repositoryPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@", repositoryPath, commitSha] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse error:nil withNameOrNil:repositoryPath];	
}


#pragma mark Commit Comments

- (void)commitCommentsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments", repositoryPath] requestType:UAGithubCommitCommentsRequest responseType:UAGithubCommitCommentsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/commits/%@/comments", repositoryPath, sha] requestType:UAGithubCommitCommentAddRequest responseType:UAGithubCommitCommentResponse withParameters:commentDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentRequest responseType:UAGithubCommitCommentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentEditRequest responseType:UAGithubCommitCommentResponse withParameters:infoDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/comments/%ld", repositoryPath, commentId] requestType:UAGithubCommitCommentDeleteRequest responseType:UAGithubNoContentResponse error:nil  withNameOrNil:repositoryPath];
}


#pragma mark Downloads

- (void)downloadsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadsRequest responseType:UAGithubDownloadsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%ld", repositoryPath, downloadId] requestType:UAGithubDownloadRequest responseType:UAGithubDownloadResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads", repositoryPath] requestType:UAGithubDownloadAddRequest responseType:UAGithubDownloadResponse withParameters:downloadDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/downloads/%ld", repositoryPath, downloadId] requestType:UAGithubDownloadDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Forks

- (void)forksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForksRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:repositoryPath];
}


- (void)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    if (org)
    {
        [self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:[NSDictionary dictionaryWithObject:org forKey:@"org"] error:nil  withNameOrNil:repositoryPath];
    }
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/forks", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse error:nil withNameOrNil:repositoryPath];
}


- (void)forkRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self forkRepository:repositoryPath inOrganization:nil success:successBlock failure:failureBlock];
}


#pragma mark Keys

- (void)deployKeysForRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse error:nil withNameOrNil:repositoryName];
}


- (void)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryPath, keyId] requestType:UAGithubDeployKeyRequest responseType:UAGithubDeployKeyResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params error:nil withNameOrNil:repositoryName];
    
}


- (void)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryPath, keyId] requestType:UAGithubDeployKeyEditRequest responseType:UAGithubDeployKeyResponse withParameters:keyDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/keys/%ld", repositoryName, keyId] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryName];
    
}


#pragma mark Watching

- (void)watchersForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/watchers", repositoryPath] requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:repositoryPath];
}


- (void)watchedRepositoriesForUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/watched", user] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:user];
}


- (void)watchedRepositoriessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/watched" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse error:nil withNameOrNil:nil];
}



- (void)repositoryIsWatched:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchingRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)watchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)unwatchRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"user/watched/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Hooks

- (void)hooksForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHooksRequest responseType:UAGithubRepositoryHooksResponse error:nil withNameOrNil:repositoryPath];
}


- (void)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookRequest responseType:UAGithubRepositoryHookResponse error:nil withNameOrNil:repositoryPath];
}


- (void)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks", repositoryPath] requestType:UAGithubRepositoryHookAddRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookEditRequest responseType:UAGithubRepositoryHookResponse withParameters:hookDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookTestRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


- (void)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/hooks/%ld", repositoryPath, hookId] requestType:UAGithubRepositoryHookDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Merges

- (void)mergeHead:(NSString *)head intoBranch:(NSString *)base inRepository:(NSString *)repositoryPath withMessage:(NSString *)commitMessage success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/merges", repositoryPath] requestType:UAGithubRepositoryMergeRequest responseType:UAGithubCommitResponse error:nil withNameOrNil:repositoryPath];
}



#pragma mark
#pragma mark Users
#pragma mark 

- (void)user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"users/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse error:nil withNameOrNil:user];
}


- (void)userWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:@"user" requestType:UAGithubUserRequest responseType:UAGithubUserResponse error:nil withNameOrNil:nil];
}


- (void)editUser:(NSDictionary *)userDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user" requestType:UAGithubUserEditRequest responseType:UAGithubUserResponse withParameters:userDictionary error:nil withNameOrNil:nil];
}


#pragma mark Emails

- (void)emailAddressessuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/emails" requestType:UAGithubEmailsRequest responseType:UAGithubEmailsResponse error:nil withNameOrNil:nil];
}


- (void)addEmailAddresses:(NSArray *)emails success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/emails" requestType:UAGithubEmailAddRequest responseType:UAGithubEmailsResponse withParameters:emails error:nil withNameOrNil:nil];
}


- (void)deleteEmailAddresses:(NSArray *)emails success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/emails" requestType:UAGithubEmailDeleteRequest responseType:UAGithubNoContentResponse withParameters:emails error:nil withNameOrNil:nil];
}


#pragma mark Followers
// List a user's followers
- (void)followers:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"users/%@/followers", user] requestType:UAGithubUserRequest responseType:UAGithubFollowersResponse error:nil withNameOrNil:user];
    
}

// List the authenticated user's followers
- (void)followersWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/followers" requestType:UAGithubUsersRequest responseType:UAGithubFollowersResponse error:nil withNameOrNil:nil];
}

// List who a user is following
- (void)following:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"users/%@/following", user] requestType:UAGithubUserRequest responseType:UAGithubFollowingResponse error:nil withNameOrNil:user];
}

// List who the authenticated user is following
- (void)followingWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/following" requestType:UAGithubUsersRequest responseType:UAGithubUsersResponse error:nil withNameOrNil:nil];
}

// Check if the authenticated user follows another user
- (void)follows:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowingRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
}

// Follow a user
- (void)follow:(NSString *)user  success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubFollowRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
   
}

// Unfollow a user
- (void)unfollow:(NSString *)user success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
 	[self sendRequest:[NSString stringWithFormat:@"user/following/%@", user] requestType:UAGithubUnfollowRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:user];
}


#pragma mark Keys

- (void)publicKeysWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/keys" requestType:UAGithubPublicKeysRequest responseType:UAGithubPublicKeysResponse error:nil withNameOrNil:nil];
}


- (void)publicKey:(NSInteger)keyId success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyRequest responseType:UAGithubPublicKeyResponse error:nil withNameOrNil:nil];
}


- (void)addPublicKey:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"user/keys" requestType:UAGithubPublicKeyAddRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary error:nil withNameOrNil:nil];
}


- (void)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyEditRequest responseType:UAGithubPublicKeyResponse withParameters:keyDictionary error:nil withNameOrNil:nil];
}


- (void)deletePublicKey:(NSInteger)keyId success:(UAGithubEngineBooleanSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"user/keys/%ld", keyId] requestType:UAGithubPublicKeyDeleteRequest responseType:UAGithubNoContentResponse error:nil withNameOrNil:nil];
}


- (void)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags", repositoryPath] requestType:UAGithubTagObjectCreateRequest responseType:UAGithubAnnotatedTagResponse withParameters:tagDictionary error:nil withNameOrNil:repositoryPath];
}


#pragma mark
#pragma mark Events
#pragma mark

- (void)eventsWithSuccess:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:@"events" requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:nil];
}


- (void)eventsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/events", repositoryPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:repositoryPath];
}


- (void)eventsForNetwork:(NSString *)networkPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"networks/%@/events", networkPath] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:networkPath];
}
                         

- (void)eventsReceivedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/received_events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:user];
}


- (void)eventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/events", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:user];
}


- (void)publicEventsPerformedByUser:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/events/public", user] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:user];
}


- (void)eventsForOrganization:(NSString *)organization user:(NSString *)user success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"users/%@/events/orgs/%@", user, organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:organization];
}


- (void)publicEventsForOrganization:(NSString *)organization success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"orgs/%@/events", organization] requestType:UAGithubEventsRequest responseType:UAGithubEventsResponse error:nil withNameOrNil:organization];
}


#pragma mark -
#pragma mark Git Database API
#pragma mark -

#pragma mark Trees

- (void)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees/%@%@", repositoryPath, sha, recursive ? @"?recursive=1" : @""] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse error:nil withNameOrNil:repositoryPath];
}


- (void)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/trees", repositoryPath] requestType:UAGithubTreeCreateRequest responseType:UAGithubTreeResponse withParameters:treeDictionary error:nil withNameOrNil:repositoryPath];
}


#pragma mark Blobs

- (void)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs/%@", repositoryPath, sha] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse error:nil withNameOrNil:repositoryPath];	
}


- (void)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/blobs", repositoryPath] requestType:UAGithubBlobCreateRequest responseType:UAGithubSHAResponse withParameters:blobDictionary error:nil withNameOrNil:repositoryPath];
}


#pragma mark References

- (void)reference:(NSString *)reference inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceRequest responseType:UAGithubReferenceResponse error:nil withNameOrNil:repositoryPath];
}


- (void)referencesInRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse error:nil withNameOrNil:repositoryPath];
}


- (void)tagsForRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/tags", repositoryPath] requestType:UAGithubReferencesRequest responseType:UAGithubReferencesResponse error:nil withNameOrNil:repositoryPath];
}


- (void)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs", repositoryPath] requestType:UAGithubReferenceCreateRequest responseType:UAGithubReferenceResponse withParameters:refDictionary error:nil withNameOrNil:repositoryPath];
}


- (void)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/refs/%@", repositoryPath, reference] requestType:UAGithubReferenceUpdateRequest responseType:UAGithubReferenceResponse withParameters:referenceDictionary error:nil withNameOrNil:repositoryPath];
}


#pragma mark Tags

- (void)tag:(NSString *)sha inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/tags/%@", repositoryPath, sha] requestType:UAGithubTagObjectRequest responseType:UAGithubAnnotatedTagResponse error:nil withNameOrNil:repositoryPath];
}


#pragma mark Raw Commits

- (void)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits/%@", repositoryPath, commit] requestType:UAGithubRawCommitRequest responseType:UAGithubRawCommitResponse error:nil withNameOrNil:repositoryPath];
}


- (void)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    [self sendRequest:[NSString stringWithFormat:@"repos/%@/git/commits", repositoryPath] requestType:UAGithubRawCommitCreateRequest responseType:UAGithubRawCommitResponse withParameters:commitDictionary error:nil withNameOrNil:repositoryPath];
}


#pragma mark -
#pragma mark Markdown
#pragma mark -

- (void)renderAsMarkdown:(NSString *)string success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"text" : string } copy];
    [self sendRequest:@"markdown" requestType:UAGithubMarkdownRequest responseType:UAGithubMarkdownResponse withParameters:params error:nil withNameOrNil:string];
}


- (void)renderAsGitHubFlavoredMarkdown:(NSString *)string withRepositoryContext:(NSString *)repositoryPath success:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock
{
    NSDictionary *params = [@{ @"text" : string, @"mode" : @"gfm" } copy];
    if (repositoryPath)
    {
        NSMutableDictionary *mutableParams = [params mutableCopy];
        [mutableParams setValue:repositoryPath forKey:@"context"];
        params = [mutableParams copy];
    }
    [self sendRequest:@"markdown" requestType:UAGithubMarkdownRequest responseType:UAGithubMarkdownResponse withParameters:params error:nil withNameOrNil:string];
   
}

@end
