//
//  UAGithubEngineRequestTypes.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//



typedef enum UAGithubRequestType 
{
	UAGithubUsersRequest = 0,						// Get more than one non-specific user
	UAGithubUserRequest,							// Get exactly one specific user
	UAGithubRepositoriesRequest,					// Get more than one non-specific repository
	UAGithubRepositoryRequest,						// Get exactly one specific repository
	UAGithubRepositoryUpdateRequest,				// Update repository metadata
	UAGithubRepositoryWatchRequest,					// Watch a repository
	UAGithubRepositoryUnwatchRequest,				// Unwatch a repository
	UAGithubRepositoryForkRequest,					// Fork a repository
	UAGithubRepositoryCreateRequest,				// Create a repository
	UAGithubRepositoryPrivatiseRequest,				// Make a repository private
	UAGithubRepositoryPubliciseRequest,				// Make a repository public
	UAGithubRepositoryDeleteRequest,				// Delete a repository
	UAGithubRepositoryDeleteConfirmationRequest,	// Confirm deletion of a repository
	UAGithubDeployKeysRequest,						// Get repository-specific deploy keys
	UAGithubDeployKeyAddRequest,					// Add a repository-specific deploy key
	UAGithubDeployKeyDeleteRequest,					// Delete a repository-specific deploy key
	UAGithubRepositoryLanguageBreakdownRequest,		// Get the language breakdown for a repository
	UAGithubTagsRequest,							// Tags for a repository
	UAGithubBranchesRequest,						// Branches for a repository
	UAGithubCollaboratorsRequest,					// Collaborators for a repository
	UAGithubCollaboratorAddRequest,					// Add a collaborator
	UAGithubCollaboratorRemoveRequest,				// Remove a collaborator
	UAGithubCommitsRequest,							// Get more than one non-specific commit
	UAGithubCommitRequest,							// Get exactly one specific commit
	UAGithubIssuesOpenRequest,						// Get open issues
	UAGithubIssuesClosedRequest,					// Get closed issues
	UAGithubIssueRequest,							// Get exactly one specific issue
	UAGithubIssueAddRequest,						// Add an issue
	UAGithubIssueEditRequest,						// Edit an issue
	UAGithubIssueCloseRequest,						// Close an issue
	UAGithubIssueReopenRequest,						// Reopen a closed issue
	UAGithubRepositoryLabelsRequest,				// Get repository-wide issue labels
	UAGithubRepositoryLabelAddRequest,				// Add a repository-wide issue label
	UAGithubRepositoryLabelRemoveRequest,			// Remove a repository-wide issue label
	UAGithubIssueLabelAddRequest,					// Add a label to a specific issue
	UAGithubIssueLabelRemoveRequest,				// Remove a label from a specific issue
	UAGithubIssueCommentsRequest,					// Get more than one non-specific issue comment
	UAGithubIssueCommentRequest,					// Get exactly one specific issue comment
	UAGithubIssueCommentAddRequest,					// Add a comment to an issue
	UAGithubTreeRequest,							// Get the listing of a tree by SHA
	UAGithubBlobsRequest,							// Get the names and SHAs of all blobs for a specific tree SHA
	UAGithubBlobRequest,							// Get data about a single blob by tree SHA and path
	UAGithubRawBlobRequest,							// Get the raw data for a blob

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
