//
//  UAGithubEngineRequestTypes.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//



typedef enum UAGithubRequestType 
{
    UAGithubIssuesAllRequest			= 0,    
	UAGithubIssuesOpenRequest			= 1,
	UAGithubIssuesClosedRequest			= 2,
	UAGithubRepositoriesRequest			= 3,
	UAGithubRepositoryRequest			= 4,
	UAGithubRepositoryUpdateRequest,
	UAGithubRepositoryWatchRequest,
	UAGithubRepositoryUnwatchRequest,
	UAGithubRepositoryForkRequest,
	UAGithubRepositoryCreateRequest,
	UAGithubRepositoryPrivatiseRequest,
	UAGithubRepositoryPubliciseRequest,
	UAGithubIssuesRequest				= 5,
	UAGithubIssueRequest				= 6,
	UAGithubIssueAddRequest				= 7,
	UAGithubIssueEditRequest			= 8,
	UAGithubIssueCloseRequest			= 9,
	UAGithubIssueReopenRequest			= 10,
	UAGithubCommentsRequest				= 11,
	UAGithubCommentRequest				= 12,
	UAGithubCommentAddRequest			= 13,
	UAGithubUsersRequest				= 14,
	UAGithubUserRequest					= 15,
	UAGithubLabelsRequest				= 16,
	UAGithubRepositoryLabelsRequest		= 17,
	UAGithubLabelAddRequest				= 18,
	UAGithubLabelRemovedRequest			= 19,
	UAGithubCommitRequest				= 20,
	UAGithubCommitsRequest				= 21,
	UAGithubTreeRequest					= 22,
	UAGithubBlobsRequest				= 23,
	UAGithubBlobRequest					= 24,
	UAGithubRawBlobRequest				= 25,
	UAGithubRepositoryDeleteRequest		= 26,
	UAGithubRepositoryDeleteConfirmationRequest	= 27,
	UAGithubDeployKeysRequest			= 28,
	UAGithubDeployKeyAddRequest,
	UAGithubDeployKeyDeleteRequest,
	UAGithubRepositoryLanguageBreakdownRequest,
	UAGithubTagsRequest,
	UAGithubBranchesRequest,
	UAGithubCollaboratorsRequest,
	UAGithubCollaboratorAddRequest,
	UAGithubCollaboratorRemoveRequest,

} UAGithubRequestType;






typedef enum UAGithubResponseType 
{
	UAGithubIssuesResponse				= 0,
	UAGithubIssueResponse				= 1,
	UAGithubRepositoriesResponse		= 2,
	UAGithubRepositoryResponse			= 3,
	UAGithubIssueCommentsResponse		= 4,
	UAGithubIssueCommentResponse		= 5,
	UAGithubUsersResponse				= 6,
	UAGithubUserResponse				= 7,
	UAGithubIssueLabelsResponse			= 8,
	UAGithubRepositoryLabelsResponse	= 9,
	UAGithubCommitsResponse				= 10,
	UAGithubCommitResponse				= 11,
	UAGithubTreeResponse				= 12,
	UAGithubBlobsResponse				= 13,
	UAGithubBlobResponse				= 14,
	UAGithubRawBlobResponse				= 15,
	UAGithubDeleteRepositoryResponse	= 16,
	UAGithubDeleteRepositoryConfirmationResponse = 17,
	UAGithubDeployKeysResponse			= 18,
	UAGithubRepositoryLanguageBreakdownResponse,
	UAGithubTagsResponse,
	UAGithubBranchesResponse,
	UAGithubCollaboratorsResponse,
	
} UAGithubResponseType;
