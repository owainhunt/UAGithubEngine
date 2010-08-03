//
//  UAGithubEngineRequestTypes.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//



typedef enum UAGithubRequestType 
{
	UAGithubUsersRequest = 0,				
	UAGithubUserRequest,					
	UAGithubRepositoriesRequest,			
	UAGithubRepositoryRequest,			
	UAGithubRepositoryUpdateRequest,
	UAGithubRepositoryWatchRequest,
	UAGithubRepositoryUnwatchRequest,
	UAGithubRepositoryForkRequest,
	UAGithubRepositoryCreateRequest,
	UAGithubRepositoryPrivatiseRequest,
	UAGithubRepositoryPubliciseRequest,
	UAGithubRepositoryDeleteRequest,		
	UAGithubRepositoryDeleteConfirmationRequest,
	UAGithubDeployKeysRequest,			
	UAGithubDeployKeyAddRequest,
	UAGithubDeployKeyDeleteRequest,
	UAGithubRepositoryLanguageBreakdownRequest,
	UAGithubTagsRequest,
	UAGithubBranchesRequest,
	UAGithubCollaboratorsRequest,
	UAGithubCollaboratorAddRequest,
	UAGithubCollaboratorRemoveRequest,
	UAGithubCommitsRequest,				
	UAGithubCommitRequest,				
	UAGithubIssuesOpenRequest,			
	UAGithubIssuesClosedRequest,			
	UAGithubIssueRequest,				
	UAGithubIssueAddRequest,				
	UAGithubIssueEditRequest,			
	UAGithubIssueCloseRequest,			
	UAGithubIssueReopenRequest,			
	UAGithubRepositoryLabelsRequest,		
	UAGithubIssueLabelAddRequest,				
	UAGithubIssueLabelRemoveRequest,			
	UAGithubCommentsRequest,			
	UAGithubCommentRequest,			
	UAGithubCommentAddRequest,			
	UAGithubTreeRequest,				
	UAGithubBlobsRequest,				
	UAGithubBlobRequest,					
	UAGithubRawBlobRequest,				

} UAGithubRequestType;


typedef enum UAGithubResponseType 
{
	UAGithubUsersResponse = 0,
	UAGithubUserResponse,
	UAGithubRepositoriesResponse,
	UAGithubRepositoryResponse,
	UAGithubDeleteRepositoryResponse,
	UAGithubDeleteRepositoryConfirmationResponse,
	UAGithubDeployKeysResponse,
	UAGithubRepositoryLanguageBreakdownResponse,
	UAGithubTagsResponse,
	UAGithubBranchesResponse,
	UAGithubCollaboratorsResponse,
	UAGithubCommitsResponse,
	UAGithubCommitResponse,
	UAGithubIssuesResponse,
	UAGithubIssueResponse,
	UAGithubIssueCommentsResponse,
	UAGithubIssueCommentResponse,
	UAGithubIssueLabelsResponse,
	UAGithubRepositoryLabelsResponse,
	UAGithubTreeResponse,
	UAGithubBlobsResponse,
	UAGithubBlobResponse,
	UAGithubRawBlobResponse,
	
} UAGithubResponseType;
