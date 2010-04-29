//
//  UAGithubEngineRequestTypes.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//



typedef enum UAGithubRequestType {
    UAGithubAllIssuesRequest			= 0,    
	UAGithubOpenIssuesRequest			= 1,
	UAGithubClosedIssuesRequest			= 2,
	UAGithubRepositoriesRequest			= 3,
	UAGithubRepositoryRequest			= 4,
	UAGithubIssuesRequest				= 5,
	UAGithubIssueRequest				= 6,
	UAGithubAddIssueRequest				= 7,
	UAGithubEditIssueRequest			= 8,
	UAGithubCloseIssueRequest			= 9,
	UAGithubReopenIssueRequest			= 10,
	UAGithubCommentsRequest				= 11,
	UAGithubCommentRequest				= 12,
	UAGithubAddCommentRequest			= 13,
	UAGithubUsersRequest				= 14,
	UAGithubUserRequest					= 15,
	UAGithubLabelsRequest				= 16,
	UAGithubRepositoryLabelsRequest		= 17,
	UAGithubAddLabelRequest				= 18,
	UAGithubRemoveLabelRequest			= 19,
	UAGithubCommitRequest				= 20,
	UAGithubCommitsRequest				= 21,
	UAGithubTreeRequest					= 22,
	UAGithubBlobsRequest				= 23,
	UAGithubBlobRequest					= 24,
	UAGithubRawBlobRequest				= 25,

} UAGithubRequestType;


typedef enum UAGithubResponseType {
	UAGithubIssuesResponse				= 0,
	UAGithubIssueResponse				= 1,
	UAGithubRepositoriesResponse		= 2,
	UAGithubRepositoryResponse			= 3,
	UAGithubCommentsResponse			= 4,
	UAGithubCommentResponse				= 5,
	UAGithubUsersResponse				= 6,
	UAGithubUserResponse				= 7,
	UAGithubLabelsResponse				= 8,
	UAGithubRepositoryLabelsResponse	= 9,
	UAGithubCommitsResponse				= 10,
	UAGithubCommitResponse				= 11,
	UAGithubTreeResponse				= 12,
	UAGithubBlobsResponse				= 13,
	UAGithubBlobResponse				= 14,
	UAGithubRawBlobResponse				= 15,

} UAGithubResponseType;