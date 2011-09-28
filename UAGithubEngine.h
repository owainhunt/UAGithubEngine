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
- (NSString *)user;
- (NSString *)editUser:(NSDictionary *)userDictionary;
- (NSString *)searchUsers:(NSString *)query byEmail:(BOOL)email;
- (NSString *)following:(NSString *)user;
- (NSString *)followers:(NSString *)user;
- (NSString *)follow:(NSString *)user;
- (NSString *)unfollow:(NSString *)user;
- (NSString *)publicKeys;
- (NSString *)publicKey:(NSInteger)keyId;
- (NSString *)addPublicKey:(NSDictionary *)keyDictionary;
- (NSString *)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary;
- (NSString *)deletePublicKey:(NSInteger)keyId;


#pragma mark Repositories
#pragma mark TODO Move to v3

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


#pragma mark Commits

- (NSString *)commitsForRepository:(NSString *)repositoryPath;
- (NSString *)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath;


#pragma mark Commit Comments

- (NSString *)commitCommentsForRepository:(NSString *)repositoryPath;
- (NSString *)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath;
- (NSString *)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath;
- (NSString *)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath;
- (NSString *)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary;
- (NSString *)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath;


#pragma mark Milestones 

- (NSString *)milestonesForRepository:(NSString *)repositoryPath;
- (NSString *)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath;
- (NSString *)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath;
- (NSString *)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary;
- (NSString *)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath;


#pragma mark Issues 

- (NSString *)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType;
- (NSString *)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (NSString *)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)closeIssue:(NSString *)issuePath;
- (NSString *)reopenIssue:(NSString *)issuePath;
- (NSString *)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;


#pragma mark Labels
#pragma mark TODO Move to v3

- (NSString *)labelsForRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;


#pragma mark Issue Comments 

- (NSString *)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath;
- (NSString *)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath;
- (NSString *)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath;
- (NSString *)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody;
- (NSString *)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath;


#pragma mark Trees
#pragma mark TODO Move to v3

- (NSString *)tree:(NSString *)treePath;


#pragma mark Blobs
#pragma mark TODO Move to v3

- (NSString *)blobsForSHA:(NSString *)shaPath;
- (NSString *)blob:(NSString *)blobPath;
- (NSString *)rawBlob:(NSString *)blobPath;
 

@end
