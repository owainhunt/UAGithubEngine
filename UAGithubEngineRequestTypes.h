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
	UAGithubAddLabelRequest				= 17,
	UAGithubRemoveLabelRequest			= 18,
	UAGithubCommitRequest				= 19,
	UAGithubCommitsRequest				= 20,

} UAGithubRequestType;
