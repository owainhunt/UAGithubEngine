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
	UAGithubCommentsRequest				= 7,
	UAGithubCommentRequest				= 8,
	UAGithubUsersRequest				= 9,
	UAGithubUserRequest					= 10,
	UAGithubLabelsRequest				= 11,
	UAGithubCommitRequest				= 12,
	UAGithubCommitsRequest				= 13,
} UAGithubRequestType;
