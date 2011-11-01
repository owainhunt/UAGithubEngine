//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAReachability.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubEngineConstants.h"

@interface UAGithubEngine : NSObject {
	NSString *username;
	NSString *password;
	NSMutableDictionary *connections;
	UAReachability *reachability;
	BOOL isReachable;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSMutableDictionary *connections;
@property (nonatomic, retain) UAReachability *reachability;
@property (nonatomic, assign, readonly) BOOL isReachable;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword withReachability:(BOOL)withReach;

/*
 Where methods take a 'whateverPath' argument, supply the full path to 'whatever'.
 For example, if the method calls for 'repositoryPath', supply @"username/repository".

 Where methods take a 'whateverName' argument, supply just the name of 'whatever'. The username used will be that set in the engine instance.
 
 For methods that take an NSDictionary as an argument, this should contain the relevant keys and values for the required API call.
 See the documentation for more details on updating repositories, and adding and editing issues.
*/

#pragma mark
#pragma mark Gists
#pragma mark

- (id)gistsForUser:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)gistsSuccess:(id(^)(id obj))successBlock_;
- (id)publicGistsSuccess:(id(^)(id obj))successBlock_;
- (id)starredGistsSuccess:(id(^)(id obj))successBlock_;
- (id)gist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)createGist:(NSDictionary *)gistDictionary success:(id(^)(id obj))successBlock_;
- (id)editGist:(NSInteger)gistId withDictionary:(NSDictionary *)gistDictionary success:(id(^)(id obj))successBlock_;
- (id)starGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)unstarGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)gistIsStarred:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)forkGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)deleteGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;


#pragma mark Comments

- (id)commentsForGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)gistComment:(NSString *)commentId success:(id(^)(id obj))successBlock_;
- (id)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSInteger)gistId success:(id(^)(id obj))successBlock_;
- (id)editGistComment:(NSString *)commentId withDictionary:(NSDictionary *)commentDictionary success:(id(^)(id obj))successBlock_;
- (id)deleteGistComment:(NSString *)commentId success:(id(^)(id obj))successBlock_;


#pragma mark
#pragma mark Issues 
#pragma mark

- (id)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType success:(id(^)(id obj))successBlock_;
- (id)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(id(^)(id obj))successBlock_;
- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary success:(id(^)(id obj))successBlock_;
- (id)closeIssue:(NSString *)issuePath success:(id(^)(id obj))successBlock_;
- (id)reopenIssue:(NSString *)issuePath success:(id(^)(id obj))successBlock_;
- (id)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Comments 

- (id)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody success:(id(^)(id obj))successBlock_;
- (id)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Events

- (id)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)issueEventsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Labels

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (id)labelsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)label:(NSString *)labelName inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(id(^)(id obj))successBlock_;
- (id)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary success:(id(^)(id obj))successBlock_;
- (id)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (id)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels success:(id(^)(id obj))successBlock_;
- (id)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Milestones 

- (id)milestonesForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_;
- (id)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark
#pragma mark Pull Requests
#pragma mark

- (id)pullRequestsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary success:(id(^)(id obj))successBlock_;
- (id)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Comments

- (id)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary success:(id(^)(id obj))successBlock_;
- (id)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark
#pragma mark Repositories
#pragma mark

- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched success:(id(^)(id obj))successBlock_;
- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page success:(id(^)(id obj))successBlock_;
- (id)repositoriesSuccess:(id(^)(id obj))successBlock_;
- (id)createRepositoryWithInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_;
- (id)repository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_;
- (id)contributorsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)languageBreakdownForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)teamsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)annotatedTagsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)branchesForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Collaborators

- (id)collaboratorsForRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
- (id)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Commits

- (id)commitsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Commit Comments

- (id)commitCommentsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary success:(id(^)(id obj))successBlock_;
- (id)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Downloads

- (id)downloadsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
// See http://developer.github.com/v3/repos/downloads for more information: this is a two-part process.
- (id)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary success:(id(^)(id obj))successBlock_;
- (id)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Forks

- (id)forksForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org success:(id(^)(id obj))successBlock_;
- (id)forkRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Keys

- (id)deployKeysForRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
- (id)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
- (id)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_;
- (id)removeDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;


#pragma mark Watching

- (id)watchersForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)watchedRepositoriesForUser:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)watchedRepositoriesSuccess:(id(^)(id obj))successBlock_;
- (id)repositoryIsWatched:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)watchRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)unwatchRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Hooks

- (id)hooksForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary success:(id(^)(id obj))successBlock_;
- (id)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)removeHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;

/* NOT YET IMPLEMENTED
 - (id)searchRepositories:(NSString *)query success:(id(^)(id obj))successBlock_;
 - (id)deleteRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
 - (id)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken success:(id(^)(id obj))successBlock_;
 - (id)privatiseRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
 - (id)publiciseRepository:(NSString *)repositoryName success:(id(^)(id obj))successBlock_;
 - (id)pushableRepositories success:(id(^)(id obj))successBlock_;
 - (id)networkForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
 */


#pragma mark
#pragma mark Users
#pragma mark

- (id)user:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)userSuccess:(id(^)(id obj))successBlock_;
- (id)editUser:(NSDictionary *)userDictionary success:(id(^)(id obj))successBlock_;


#pragma mark Emails

- (id)emailAddressesSuccess:(id(^)(id obj))successBlock_;
- (id)addEmailAddresses:(NSArray *)emails success:(id(^)(id obj))successBlock_;
- (id)deleteEmailAddresses:(NSArray *)emails success:(id(^)(id obj))successBlock_;


#pragma mark Followers

- (id)followers:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)followersSuccess:(id(^)(id obj))successBlock_;
- (id)following:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)followedBy:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)follows:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)follow:(NSString *)user success:(id(^)(id obj))successBlock_;
- (id)unfollow:(NSString *)user success:(id(^)(id obj))successBlock_;


#pragma mark Keys

- (id)publicKeysSuccess:(id(^)(id obj))successBlock_;
- (id)publicKey:(NSInteger)keyId success:(id(^)(id obj))successBlock_;
- (id)addPublicKey:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_;
- (id)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary success:(id(^)(id obj))successBlock_;
- (id)deletePublicKey:(NSInteger)keyId success:(id(^)(id obj))successBlock_;


#pragma mark
#pragma mark Events
#pragma mark

- (id)eventsWithCompletion:(id(^)(id obj))successBlock_;
- (id)eventsForRepository:(NSString *)repositoryPath completion:(id(^)(id obj))successBlock_;
- (id)eventsForNetwork:(NSString *)networkPath completion:(id(^)(id obj))successBlock;
- (id)eventsReceivedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)eventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)publicEventsPerformedByUser:(NSString *)user completion:(id(^)(id obj))successBlock;
- (id)eventsForOrganization:(NSString *)organization completion:(id(^)(id obj))successBlock;
- (id)publicEventsForOrganization:(NSString *)organization completion:(id(^)(id obj))successBlock;


#pragma mark -
#pragma mark Git Database API
#pragma mark -

// The following methods access the Git Database API.
// See http://developer.github.com/v3/git/ for more information.

#pragma mark Trees

- (id)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive success:(id(^)(id obj))successBlock_;
- (id)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Blobs

- (id)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
/*
- (id)blob:(NSString *)blobPath success:(id(^)(id obj))successBlock_;
- (id)rawBlob:(NSString *)blobPath success:(id(^)(id obj))successBlock_;
 */
 

#pragma mark References

- (id)reference:(NSString *)reference inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)referencesInRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)tagsForRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary success:(id(^)(id obj))successBlock_;


#pragma mark Tags

- (id)tag:(NSString *)sha inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


#pragma mark Raw Commits

- (id)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;
- (id)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath success:(id(^)(id obj))successBlock_;


@end
