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
- (void)gistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicGistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)starredGistsWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)gist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createGist:(NSDictionary *)gistDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editGist:(NSString *)gistId withDictionary:(NSDictionary *)gistDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)starGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)unstarGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)gistIsStarred:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)forkGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Comments

- (void)commentsForGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)gistComment:(NSInteger)commentId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addCommitComment:(NSDictionary *)commentDictionary forGist:(NSString *)gistId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editGistComment:(NSInteger)commentId withDictionary:(NSDictionary *)commentDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteGistComment:(NSInteger)commentId completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark
#pragma mark Issues 
#pragma mark

- (void)issuesForRepository:(NSString *)repositoryPath withParameters:(NSDictionary *)parameters requestType:(UAGithubRequestType)requestType completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)issue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)closeIssue:(NSString *)issuePath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)reopenIssue:(NSString *)issuePath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Comments 

- (void)commentsForIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)issueComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addComment:(NSString *)comment toIssue:(NSInteger)issueNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath withBody:(NSString *)commentBody completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteComment:(NSInteger)commentNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Events

- (void)eventsForIssue:(NSInteger)issueId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)issueEventsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)issueEvent:(NSInteger)eventId forRepository:(NSString*)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Labels

// NOTE where it says ':id' in the documentation for a label, it actually should say ':name'
- (void)labelsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)label:(NSString *)labelName inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addLabelToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editLabel:(NSString *)labelName inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)labelDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeLabel:(NSString *)labelName fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)labelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
// Note labels supplied to the following method must already exist within the repository (-addLabelToRepository:...)
- (void)addLabels:(NSArray *)labels toIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeLabel:(NSString *)labelNamed fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeLabelsFromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)replaceAllLabelsForIssue:(NSInteger)issueId inRepository:(NSString *)repositoryPath withLabels:(NSArray *)labels completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)labelsForIssueInMilestone:(NSInteger)milestoneId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Milestones 

- (void)milestonesForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)milestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createMilestoneWithInfo:(NSDictionary *)infoDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updateMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteMilestone:(NSInteger)milestoneNumber forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark
#pragma mark Organisations
#pragma mark

- (void)organizationsForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)organizationsWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)organization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updateOrganization:(NSString *)org withDictionary:(NSDictionary *)orgDictionary completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Members

- (void)membersOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)user:(NSString *)user isMemberOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeUser:(NSString *)user fromOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicMembersOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)user:(NSString *)user isPublicMemberOfOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicizeMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)concealMembershipOfUser:(NSString *)user inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Teams

- (void)teamsInOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)team:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createTeam:(NSDictionary *)teamDictionary inOrganization:(NSString *)org withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editTeam:(NSInteger)teamId withDictionary:(NSDictionary *)teamDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)membersOfTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)user:(NSString *)user isMemberOfTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addUser:(NSString *)user toTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeUser:(NSString *)user fromTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repositoriesForTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repository:(NSString *)repositoryPath isManagedByTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addRepository:(NSString *)repositoryPath toTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeRepository:(NSString *)repositoryPath fromTeam:(NSInteger)teamId withCompletion:(UAGithubEngineSuccessBlock)successBlock;
                                                             

#pragma mark
#pragma mark Pull Requests
#pragma mark

- (void)pullRequestsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)pullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createPullRequest:(NSDictionary *)pullRequestDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updatePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)pullRequestDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)commitsInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)filesInPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)pullRequest:(NSInteger)pullRequestId isMergedForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)mergePullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Comments

- (void)commentsForPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)pullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createPullRequestComment:(NSDictionary *)commentDictionary forPullRequest:(NSInteger)pullRequestId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editPullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)commentDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deletePullRequestComment:(NSInteger)commentId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark
#pragma mark Repositories
#pragma mark

- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched page:(int)page completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repositoriesWithCompletion:(UAGithubEngineSuccessBlock)successBlock failure:(UAGithubEngineFailureBlock)failureBlock;
- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)contributorsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)languageBreakdownForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)teamsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)annotatedTagsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)branchesForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Collaborators

- (void)collaboratorsForRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)user:(NSString *)user isCollaboratorForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Commits

- (void)commitsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)commit:(NSString *)commitSha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Commit Comments

- (void)commitCommentsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)commitCommentsForCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addCommitComment:(NSDictionary *)commentDictionary forCommit:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)commitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)infoDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteCommitComment:(NSInteger)commentId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Downloads

- (void)downloadsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)download:(NSInteger)downloadId inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
// See http://developer.github.com/v3/repos/downloads for more information: this is a two-part process.
- (void)addDownloadToRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)downloadDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteDownload:(NSInteger)downloadId fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Forks

- (void)forksForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)forkRepository:(NSString *)repositoryPath inOrganization:(NSString *)org completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)forkRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Keys

- (void)deployKeysForRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deployKey:(NSInteger)keyId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editDeployKey:(NSInteger)keyId inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteDeployKey:(NSInteger)keyId fromRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Watching

- (void)watchersForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)watchedRepositoriesForUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)watchedRepositoriescompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)repositoryIsWatched:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)watchRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)unwatchRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Hooks

- (void)hooksForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)hook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addHook:(NSDictionary *)hookDictionary forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)hookDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)testHook:(NSInteger)hookId forRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteHook:(NSInteger)hookId fromRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;

/* NOT YET IMPLEMENTED
 - (void)searchRepositories:(NSString *)query completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)deleteRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)privatiseRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)publiciseRepository:(NSString *)repositoryName completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)pushableRepositories completion:(UAGithubEngineSuccessBlock)successBlock;
 - (void)networkForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
 */


#pragma mark
#pragma mark Users
#pragma mark

- (void)user:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)userWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)editUser:(NSDictionary *)userDictionary completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Emails

- (void)emailAddressescompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addEmailAddresses:(NSArray *)emails completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deleteEmailAddresses:(NSArray *)emails completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Followers

- (void)followers:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)followersWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)following:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)follows:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)follow:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)unfollow:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Keys

- (void)publicKeysWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicKey:(NSInteger)keyId completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)addPublicKey:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updatePublicKey:(NSInteger)keyId withInfo:(NSDictionary *)keyDictionary completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)deletePublicKey:(NSInteger)keyId completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark
#pragma mark Events
#pragma mark

- (void)eventsWithCompletion:(UAGithubEngineSuccessBlock)successBlock;
- (void)eventsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)eventsForNetwork:(NSString *)networkPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)eventsReceivedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)eventsPerformedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicEventsPerformedByUser:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)eventsForOrganization:(NSString *)organization user:(NSString *)user completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)publicEventsForOrganization:(NSString *)organization completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark -
#pragma mark Git Database API
#pragma mark -

// The following methods access the Git Database API.
// See http://developer.github.com/v3/git/ for more information.

#pragma mark Trees

- (void)tree:(NSString *)sha inRepository:(NSString *)repositoryPath recursive:(BOOL)recursive completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createTree:(NSDictionary *)treeDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Blobs

- (void)blobForSHA:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createBlob:(NSDictionary *)blobDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
/*
- (void)blob:(NSString *)blobPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)rawBlob:(NSString *)blobPath completion:(UAGithubEngineSuccessBlock)successBlock;
 */
 

#pragma mark References

- (void)reference:(NSString *)reference inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)referencesInRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)tagsForRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createReference:(NSDictionary *)refDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)updateReference:(NSString *)reference inRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)referenceDictionary completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Tags

- (void)tag:(NSString *)sha inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createTagObject:(NSDictionary *)tagDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


#pragma mark Raw Commits

- (void)rawCommit:(NSString *)commit inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;
- (void)createRawCommit:(NSDictionary *)commitDictionary inRepository:(NSString *)repositoryPath completion:(UAGithubEngineSuccessBlock)successBlock;


@end
