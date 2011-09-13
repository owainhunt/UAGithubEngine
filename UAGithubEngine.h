//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAReachability.h"
#import "UAGithubEngineDelegate.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubEngineConstants.h"
#import "UAGithubParserDelegate.h"

@interface UAGithubEngine : NSObject <UAGithubParserDelegate> {
	id <UAGithubEngineDelegate> delegate;
	NSString *username;
	NSString *password;
	NSMutableDictionary *connections;
	UAReachability *reachability;
	BOOL isReachable;
}

@property (assign) id <UAGithubEngineDelegate> delegate;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSMutableDictionary *connections;
@property (nonatomic, retain) UAReachability *reachability;
@property (nonatomic, assign, readonly) BOOL isReachable;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword delegate:(id)theDelegate withReachability:(BOOL)withReach;
- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params;

/*
 Where methods take a 'whateverPath' argument, supply the full path to 'whatever'.
 For example, if the method calls for 'repositoryPath', supply @"username/repository".

 Where methods take a 'whateverName' argument, supply just the name of 'whatever'. The username used will be that set in the engine instance.
 
 For methods that take an NSDictionary as an argument, this should contain the relevant keys and values for the required API call.
 See the documentation for more details on updating repositories, and adding and editing issues.
*/

#pragma mark Users

- (NSString *)user:(NSString *)user;
- (NSString *)searchUsers:(NSString *)query byEmail:(BOOL)email;
- (NSString *)following:(NSString *)user;
- (NSString *)followers:(NSString *)user;
- (NSString *)follow:(NSString *)user;
- (NSString *)unfollow:(NSString *)user;


#pragma mark Repositories

- (NSString *)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched;
- (NSString *)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page;
- (NSString *)repository:(NSString *)repositoryPath;
- (NSString *)searchRepositories:(NSString *)query;
- (NSString *)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary;
- (NSString *)watchRepository:(NSString *)repositoryPath;
- (NSString *)unwatchRepository:(NSString *)repositoryPath;
- (NSString *)forkRepository:(NSString *)repositoryPath;
- (NSString *)createRepositoryWithInfo:(NSDictionary *)infoDictionary;
- (NSString *)deleteRepository:(NSString *)repositoryName;
- (NSString *)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken;
- (NSString *)privatiseRepository:(NSString *)repositoryName;
- (NSString *)publiciseRepository:(NSString *)repositoryName;
- (NSString *)deployKeysForRepository:(NSString *)repositoryName;
- (NSString *)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName;
- (NSString *)removeDeployKey:(NSString *)keyID fromRepository:(NSString *)repositoryName;
- (NSString *)collaboratorsForRepository:(NSString *)repositoryName;
- (NSString *)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryName;
- (NSString *)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath;
- (NSString *)pushableRepositories;
- (NSString *)networkForRepository:(NSString *)repositoryPath;
- (NSString *)languageBreakdownForRepository:(NSString *)repositoryPath;
- (NSString *)tagsForRepository:(NSString *)repositoryPath;
- (NSString *)branchesForRepository:(NSString *)repositoryPath;
- (NSString *)organizationsForUser:(NSString *)aUser;


#pragma mark Commits

- (NSString *)commitsForBranch:(NSString *)branchPath;
- (NSString *)commit:(NSString *)commitPath;


#pragma mark Issues 

- (NSString *)issuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType;
- (NSString *)issue:(NSString *)issuePath;
- (NSString *)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)closeIssue:(NSString *)issuePath;
- (NSString *)reopenIssue:(NSString *)issuePath;


#pragma mark Labels

- (NSString *)labelsForRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;


#pragma mark Comments

- (NSString *)commentsForIssue:(NSString *)issuePath;
- (NSString *)addComment:(NSString *)comment toIssue:(NSString *)issuePath;


#pragma mark Trees

- (NSString *)tree:(NSString *)treePath;


#pragma mark Blobs

- (NSString *)blobsForSHA:(NSString *)shaPath;
- (NSString *)blob:(NSString *)blobPath;
- (NSString *)rawBlob:(NSString *)blobPath;
 

@end
