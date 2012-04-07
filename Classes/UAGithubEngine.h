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

typedef void (^UAGithubEngineSuccessBlock)(id);
typedef void (^UAGithubEngineFailureBlock)(NSError *);

@interface UAGithubEngine : NSObject 

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

- (void)gistsForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (id)gistsWithCompletion:(id(^)(id))successBlock;
- (id)publicGistsWithCompletion:(id(^)(id))successBlock;
- (id)starredGistsWithCompletion:(id(^)(id))successBlock;
- (id)gist:(NSString *)gistId completion:(id(^)(id))successBlock;
- (id)createGist:(NSDictionary *)gistDictionary completion:(id(^)(id))successBlock;
- (id)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary completion:(id(^)(id))successBlock;
- (BOOL)starGist:(NSString *)gistId completion:(BOOL(^)(id))successBlock;
- (BOOL)unstarGist:(NSString *)gistId completion:(BOOL(^)(id))successBlock;
- (BOOL)gistIsStarred:(NSString *)gistId completion:(BOOL(^)(id))successBlock;
- (id)forkGist:(NSString *)gistId completion:(id(^)(id))successBlock;
- (BOOL)deleteGist:(NSString *)gistId completion:(BOOL(^)(id))successBlock;


#pragma mark Comments

- (id)commentsForGist:(NSString *)gistId completion:(id(^)(id))successBlock;
- (id)gistComment:(NSInteger)commentId completion:(id(^)(id))successBlock;
- (id)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId completion:(id(^)(id))successBlock;
- (id)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteGistComment:(NSInteger)commentId completion:(BOOL(^)(id))successBlock;


#pragma mark
#pragma mark Issues 
#pragma mark

- (id)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType completion:(id(^)(id))successBlock;
- (id)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id))successBlock;
- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(id(^)(id))successBlock;
- (id)closeIssue:(NSString *)issuePath completion:(id(^)(id))successBlock;
- (id)reopenIssue:(NSString *)issuePath completion:(id(^)(id))successBlock;
- (BOOL)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Comments 

- (id)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody completion:(id(^)(id))successBlock;
- (BOOL)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Events

- (id)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)issueEventsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Labels

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (id)labelsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)label:(NSString *)labelName inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id))successBlock;
- (id)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(id(^)(id))successBlock;
- (BOOL)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (id)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (id)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (BOOL)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (id)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels completion:(id(^)(id))successBlock;
- (id)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Milestones 

- (id)milestonesForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark
#pragma mark Organisations
#pragma mark

- (id)organizationsForUser:(NSString *)user completion:(id(^)(id))successBlock;
- (id)organizationsWithCompletion:(id(^)(id))successBlock;
- (id)organization:(NSString *)org withCompletion:(id(^)(id))successBlock;
- (id)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary completion:(id(^)(id))successBlock;


#pragma mark Members

- (id)membersOfOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock;
- (BOOL)user:(NSString *)user isMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)removeUser:(NSString *)user fromOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock;
- (id)publicMembersOfOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock;
- (BOOL)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(BOOL(^)(id))successBlock;


#pragma mark Teams

- (id)teamsInOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock;
- (id)team:(NSInteger)teamId withCompletion:(id(^)(id))successBlock;
- (id)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withCompletion:(id(^)(id))successBlock;
- (id)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (id)membersOfTeam:(NSInteger)teamId withCompletion:(id(^)(id))successBlock;
- (BOOL)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)addUser:(NSString *)user toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (id)repositoriesForTeam:(NSInteger)teamId withCompletion:(id(^)(id))successBlock;
- (BOOL)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
- (BOOL)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withCompletion:(BOOL(^)(id))successBlock;
                                                             

#pragma mark
#pragma mark Pull Requests
#pragma mark

- (id)pullRequestsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary completion:(id(^)(id))successBlock;
- (id)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (BOOL)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (id)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Comments

- (id)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary completion:(id(^)(id))successBlock;
- (BOOL)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark
#pragma mark Repositories
#pragma mark

- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched completion:(id(^)(id))successBlock;
- (id)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page completion:(id(^)(id))successBlock;
- (void)repositoriesWithCompletion:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (id)createRepositoryWithInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock;
- (id)repository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock;
- (id)contributorsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)languageBreakdownForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)teamsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)annotatedTagsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)branchesForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Collaborators

- (id)collaboratorsForRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
- (BOOL)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Commits

- (id)commitsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Commit Comments

- (id)commitCommentsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Downloads

- (id)downloadsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
// See http://developer.github.com/v3/repos/downloads for more information: this is a two-part process.
- (id)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Forks

- (id)forksForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org completion:(id(^)(id))successBlock;
- (id)forkRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Keys

- (id)deployKeysForRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
- (id)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
- (id)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock;
- (BOOL)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName completion:(BOOL(^)(id))successBlock;


#pragma mark Watching

- (id)watchersForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)watchedRepositoriesForUser:(NSString *)user completion:(id(^)(id))successBlock;
- (id)watchedRepositoriescompletion:(id(^)(id))successBlock;
- (BOOL)repositoryIsWatched:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)watchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)unwatchRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;


#pragma mark Hooks

- (id)hooksForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary completion:(id(^)(id))successBlock;
- (BOOL)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;
- (BOOL)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath completion:(BOOL(^)(id))successBlock;

/* NOT YET IMPLEMENTED
 - (id)searchRepositories:(NSString *)query completion:(id(^)(id))successBlock;
 - (id)deleteRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
 - (id)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken completion:(id(^)(id))successBlock;
 - (id)privatiseRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
 - (id)publiciseRepository:(NSString *)repositoryName completion:(id(^)(id))successBlock;
 - (id)pushableRepositories completion:(id(^)(id))successBlock;
 - (id)networkForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
 */


#pragma mark
#pragma mark Users
#pragma mark

- (id)user:(NSString *)user completion:(id(^)(id))successBlock;
- (id)userWithCompletion:(id(^)(id))successBlock;
- (id)editUser:(NSDictionary *)userDictionary completion:(id(^)(id))successBlock;


#pragma mark Emails

- (id)emailAddressescompletion:(id(^)(id))successBlock;
- (id)addEmailAddresses:(NSArray *)emails completion:(id(^)(id))successBlock;
- (BOOL)deleteEmailAddresses:(NSArray *)emails completion:(BOOL(^)(id))successBlock;


#pragma mark Followers

- (id)followers:(NSString *)user completion:(id(^)(id))successBlock;
- (id)followersWithCompletion:(id(^)(id))successBlock;
- (id)following:(NSString *)user completion:(id(^)(id))successBlock;
- (BOOL)follows:(NSString *)user completion:(BOOL(^)(id))successBlock;
- (BOOL)follow:(NSString *)user completion:(BOOL(^)(id))successBlock;
- (BOOL)unfollow:(NSString *)user completion:(BOOL(^)(id))successBlock;


#pragma mark Keys

- (id)publicKeysWithCompletion:(id(^)(id))successBlock;
- (id)publicKey:(NSInteger)keyId completion:(id(^)(id))successBlock;
- (id)addPublicKey:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock;
- (id)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary completion:(id(^)(id))successBlock;
- (BOOL)deletePublicKey:(NSInteger)keyId completion:(BOOL(^)(id))successBlock;


#pragma mark
#pragma mark Events
#pragma mark

- (id)eventsWithCompletion:(id(^)(id))successBlock;
- (id)eventsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
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

- (id)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive completion:(id(^)(id))successBlock;
- (id)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Blobs

- (id)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
/*
- (id)blob:(NSString *)blobPath completion:(id(^)(id))successBlock;
- (id)rawBlob:(NSString *)blobPath completion:(id(^)(id))successBlock;
 */
 

#pragma mark References

- (id)reference:(NSString *)reference inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)referencesInRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)tagsForRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary completion:(id(^)(id))successBlock;


#pragma mark Tags

- (id)tag:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


#pragma mark Raw Commits

- (id)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;
- (id)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath completion:(id(^)(id))successBlock;


@end
