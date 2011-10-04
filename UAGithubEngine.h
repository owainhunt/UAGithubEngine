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
- (NSString *)repositories;
- (NSString *)createRepositoryWithInfo:(NSDictionary *)infoDictionary;
- (NSString *)repository:(NSString *)repositoryPath;
- (NSString *)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary;
- (NSString *)contributorsForRepository:(NSString *)repositoryPath;
- (NSString *)languageBreakdownForRepository:(NSString *)repositoryPath;
- (NSString *)teamsForRepository:(NSString *)repositoryPath;
- (NSString *)tagsForRepository:(NSString *)repositoryPath;
- (NSString *)branchesForRepository:(NSString *)repositoryPath;

- (NSString *)collaboratorsForRepository:(NSString *)repositoryName;
- (NSString *)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath;
- (NSString *)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath;
- (NSString *)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath;

- (NSString *)downloadsForRepository:(NSString *)repositoryPath;
- (NSString *)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath;
// NOTE see http://developer.github.com/v3/repos/downloads for more information: this is a two-part process!
- (NSString *)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary;
- (NSString *)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath;

- (NSString *)forksForRepository:(NSString *)repositoryPath;
- (NSString *)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org;
- (NSString *)forkRepository:(NSString *)repositoryPath;

- (NSString *)deployKeysForRepository:(NSString *)repositoryName;
- (NSString *)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath;
- (NSString *)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName;
- (NSString *)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary;
- (NSString *)removeDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName;

- (NSString *)watchersForRepository:(NSString *)repositoryPath;
- (NSString *)watchedRepositoriesForUser:(NSString *)user;
- (NSString *)watchedRepositories;
- (NSString *)repositoryIsWatched:(NSString *)repositoryPath;
- (NSString *)watchRepository:(NSString *)repositoryPath;
- (NSString *)unwatchRepository:(NSString *)repositoryPath;

- (NSString *)hooksForRepository:(NSString *)repositoryPath;
- (NSString *)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath;
- (NSString *)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath;
- (NSString *)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary;
- (NSString *)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath;
- (NSString *)removeHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath;

/* NOT YET IMPLEMENTED
- (NSString *)searchRepositories:(NSString *)query;
- (NSString *)deleteRepository:(NSString *)repositoryName;
- (NSString *)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken;
- (NSString *)privatiseRepository:(NSString *)repositoryName;
- (NSString *)publiciseRepository:(NSString *)repositoryName;
- (NSString *)pushableRepositories;
- (NSString *)networkForRepository:(NSString *)repositoryPath;
 */


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

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (NSString *)labelsForRepository:(NSString *)repositoryPath;
- (NSString *)label:(NSString *)labelName inRepository:(NSString *)repositoryPath;
- (NSString *)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary;
- (NSString *)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary;
- (NSString *)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath;
- (NSString *)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (NSString *)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (NSString *)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels;
- (NSString *)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath;


#pragma mark Issue Comments 

- (NSString *)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath;
- (NSString *)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath;
- (NSString *)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath;
- (NSString *)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody;
- (NSString *)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath;


#pragma mark Trees

- (NSString *)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive;
- (NSString *)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath;


#pragma mark Blobs

- (NSString *)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath;
- (NSString *)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath;
/*
- (NSString *)blob:(NSString *)blobPath;
- (NSString *)rawBlob:(NSString *)blobPath;
 */
 

@end
