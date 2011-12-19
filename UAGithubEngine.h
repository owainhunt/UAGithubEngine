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
	UAReachability *reachability;
	BOOL isReachable;
}

@property (strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UAReachability *reachability;
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

- (id)gistsForUser:(NSString *)user completion:(id(^)(id))successBlock_;
- (id)gistsWithCompletion:(id(^)(id))successBlock_;
- (id)publicGistsWithCompletion:(id(^)(id))successBlock_;
- (id)starredGistsWithCompletion:(id(^)(id))successBlock_;
- (id)gist:(NSInteger)gistId completion:(id(^)(id))successBlock_;
- (id)createGist:(NSDictionary *)gistDictionary completion:(id(^)(id))successBlock_;
- (id)editGist:(NSInteger)gistId withDictionary:(NSDictionary *)gistDictionary completion:(id(^)(id))successBlock_;
- (BOOL)starGist:(NSInteger)gistId completion:(BOOL(^)(id))successBlock_;
- (BOOL)unstarGist:(NSInteger)gistId completion:(BOOL(^)(id))successBlock_;
- (BOOL)gistIsStarred:(NSInteger)gistId completion:(BOOL(^)(id))successBlock_;
- (id)forkGist:(NSInteger)gistId completion:(id(^)(id))successBlock_;
- (BOOL)deleteGist:(NSInteger)gistId completion:(BOOL(^)(id))successBlock_;


#pragma mark Comments

- (id)commentsForGist:(NSInteger)gistId completion:(id(^)(id))successBlock_;
- (id)gistComment:(NSString *)commentId completion:(id(^)(id))successBlock_;
- (id)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSInteger)gistId completion:(id(^)(id))successBlock_;
- (id)editGistComment:(NSString *)commentId withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteGistComment:(NSString *)commentId completion:(BOOL(^)(id))successBlock_;


#pragma mark
#pragma mark Issues 
#pragma mark

- (id)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType completion:(id(^)(id))successBlock_;
- (id)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id))successBlock_;
- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id))successBlock_;
- (id)closeIssue:(NSString *)issuePath completion:(id(^)(id))successBlock_;
- (id)reopenIssue:(NSString *)issuePath completion:(id(^)(id))successBlock_;
- (BOOL)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Comments 

- (id)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody completion:(id(^)(id))successBlock_;
- (BOOL)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Events

- (id)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)issueEventsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Labels

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (id)labelsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)label:(NSString *)labelName inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id))successBlock_;
- (id)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id))successBlock_;
- (BOOL)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (id)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (id)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (BOOL)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (id)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels completion:(id(^)(id))successBlock_;
- (id)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Milestones 

- (id)milestonesForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark
#pragma mark Organisations
#pragma mark

- (id)organizationsForUser:(NSString *)user completion:(id(^)(id))successBlock_;
- (id)organizationsWithCompletion:(id(^)(id))successBlock_;
- (id)organization:(NSString *)org withCompletion:(id(^)(id))successBlock_;
- (id)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary completion:(id(^)(id))successBlock_;


#pragma mark Members

- (id)membersOfOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock_;
- (BOOL)user:(NSString *)user isMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock_;
- (BOOL)removeUser:(NSString *)user fromOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock_;
- (id)publicMembersOfOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock_;
- (BOOL)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock_;
- (BOOL)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock_;
- (BOOL)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock_;


#pragma mark Teams

- (id)teamsInOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock_;
- (id)team:(NSInteger)teamId withCompletion:(id(^)(id))successBlock_;
- (id)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock_;
- (id)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock_;
- (id)membersOfTeam:(NSInteger)teamId withCompletion:(id(^)(id))successBlock_;
- (BOOL)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock_;
- (BOOL)addUser:(NSString *)user toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock_;
- (BOOL)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock_;
- (id)repositoriesForTeam:(NSInteger)teamId withCompletion:(id(^)(id))successBlock_;
- (BOOL)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
                                                             

#pragma mark
#pragma mark Pull Requests
#pragma mark

- (id)pullRequestsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary completion:(id(^)(id))successBlock_;
- (id)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (BOOL)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (id)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Comments

- (id)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark
#pragma mark Repositories
#pragma mark

- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched completion:(id(^)(id))successBlock_;
- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page completion:(id(^)(id))successBlock_;
- (id)repositoriesWithCompletion:(id(^)(id))successBlock_;
- (id)createRepositoryWithInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock_;
- (id)repository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock_;
- (id)contributorsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)languageBreakdownForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)teamsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)annotatedTagsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)branchesForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Collaborators

- (id)collaboratorsForRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
- (BOOL)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Commits

- (id)commitsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Commit Comments

- (id)commitCommentsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Downloads

- (id)downloadsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
// See http://developer.github.com/v3/repos/downloads for more information: this is a two-part process.
- (id)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Forks

- (id)forksForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org completion:(id(^)(id))successBlock_;
- (id)forkRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Keys

- (id)deployKeysForRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
- (id)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
- (id)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName completion:(BOOL(^)(id))successBlock_;


#pragma mark Watching

- (id)watchersForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)watchedRepositoriesForUser:(NSString *)user completion:(id(^)(id))successBlock_;
- (id)watchedRepositoriescompletion:(id(^)(id))successBlock_;
- (BOOL)repositoryIsWatched:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)watchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)unwatchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;


#pragma mark Hooks

- (id)hooksForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary completion:(id(^)(id))successBlock_;
- (BOOL)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;
- (BOOL)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock_;

/* NOT YET IMPLEMENTED
 - (id)searchRepositories:(NSString *)query completion:(id(^)(id))successBlock_;
 - (id)deleteRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
 - (id)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken completion:(id(^)(id))successBlock_;
 - (id)privatiseRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
 - (id)publiciseRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock_;
 - (id)pushableRepositories completion:(id(^)(id))successBlock_;
 - (id)networkForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
 */


#pragma mark
#pragma mark Users
#pragma mark

- (id)user:(NSString *)user completion:(id(^)(id))successBlock_;
- (id)userWithCompletion:(id(^)(id))successBlock_;
- (id)editUser:(NSDictionary *)userDictionary completion:(id(^)(id))successBlock_;


#pragma mark Emails

- (id)emailAddressescompletion:(id(^)(id))successBlock_;
- (id)addEmailAddresses:(NSArray *)emails completion:(id(^)(id))successBlock_;
- (BOOL)deleteEmailAddresses:(NSArray *)emails completion:(BOOL(^)(id))successBlock_;


#pragma mark Followers

- (id)followers:(NSString *)user completion:(id(^)(id))successBlock_;
- (id)followersWithCompletion:(id(^)(id))successBlock_;
- (id)following:(NSString *)user completion:(id(^)(id))successBlock_;
- (BOOL)follows:(NSString *)user completion:(BOOL(^)(id))successBlock_;
- (BOOL)follow:(NSString *)user completion:(BOOL(^)(id))successBlock_;
- (BOOL)unfollow:(NSString *)user completion:(BOOL(^)(id))successBlock_;


#pragma mark Keys

- (id)publicKeysWithCompletion:(id(^)(id))successBlock_;
- (id)publicKey:(NSInteger)keyId completion:(id(^)(id))successBlock_;
- (id)addPublicKey:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock_;
- (id)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock_;
- (BOOL)deletePublicKey:(NSInteger)keyId completion:(BOOL(^)(id))successBlock_;


#pragma mark
#pragma mark Events
#pragma mark

- (id)eventsWithCompletion:(id(^)(id))successBlock_;
- (id)eventsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)eventsForNetwork:(NSString *)networkPath completion:(id(^)(id))successBlock;
- (id)eventsReceivedByUser:(NSString *)user completion:(id(^)(id))successBlock;
- (id)eventsPerformedByUser:(NSString *)user completion:(id(^)(id))successBlock;
- (id)publicEventsPerformedByUser:(NSString *)user completion:(id(^)(id))successBlock;
- (id)eventsForOrganization:(NSString *)organization user:(NSString *)user completion:(id(^)(id))successBlock;
- (id)publicEventsForOrganization:(NSString *)organization completion:(id(^)(id))successBlock;


#pragma mark -
#pragma mark Git Database API
#pragma mark -

// The following methods access the Git Database API.
// See http://developer.github.com/v3/git/ for more information.

#pragma mark Trees

- (id)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive completion:(id(^)(id))successBlock_;
- (id)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Blobs

- (id)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
/*
- (id)blob:(NSString *)blobPath completion:(id(^)(id))successBlock_;
- (id)rawBlob:(NSString *)blobPath completion:(id(^)(id))successBlock_;
 */
 

#pragma mark References

- (id)reference:(NSString *)reference inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)referencesInRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)tagsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary completion:(id(^)(id))successBlock_;


#pragma mark Tags

- (id)tag:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


#pragma mark Raw Commits

- (id)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;
- (id)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock_;


@end
