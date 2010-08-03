//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngineGlobalHeader.h"
#import "UAGithubEngineDelegate.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubParserDelegate.h"

@interface UAGithubEngine : NSObject <UAGithubParserDelegate> {
	id <UAGithubEngineDelegate> delegate;
	NSString *username;
	NSString *apiKey;
	NSString *dataFormat;
	NSMutableDictionary *connections;
}

@property (assign) id <UAGithubEngineDelegate> delegate;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *dataFormat;
@property (nonatomic, retain) NSMutableDictionary *connections;

- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate;


#pragma mark Users

- (NSString *)getUser:(NSString *)user;
- (NSString *)searchUsers:(NSString *)query byEmail:(BOOL)email;


#pragma mark Repositories

- (NSString *)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched;
- (NSString *)getRepository:(NSString *)repositoryPath;
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
- (NSString *)getDeployKeysForRepository:(NSString *)repositoryName;
- (NSString *)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName;
- (NSString *)removeDeployKey:(NSString *)keyID fromRepository:(NSString *)repositoryName;
- (NSString *)getCollaboratorsForRepository:(NSString *)repositoryName;
- (NSString *)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryName;
- (NSString *)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryPath;
- (NSString *)getPushableRepositories;
- (NSString *)getNetworkForRepository:(NSString *)repositoryPath;
- (NSString *)getLanguageBreakdownForRepository:(NSString *)repositoryPath;
- (NSString *)getTagsForRepository:(NSString *)repositoryPath;
- (NSString *)getBranchesForRepository:(NSString *)repositoryPath;


#pragma mark Commits

- (NSString *)getCommitsForBranch:(NSString *)branchPath;
- (NSString *)getCommit:(NSString *)commitPath;


#pragma mark Issues 

- (NSString *)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType;
- (NSString *)getIssue:(NSString *)issuePath;
- (NSString *)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (NSString *)closeIssue:(NSString *)issuePath;
- (NSString *)reopenIssue:(NSString *)issuePath;


#pragma mark Labels

- (NSString *)getLabelsForRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath;
- (NSString *)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (NSString *)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;


#pragma mark Comments

- (NSString *)getCommentsForIssue:(NSString *)issuePath;
- (NSString *)addComment:(NSString *)comment toIssue:(NSString *)issuePath;


#pragma mark Trees

- (NSString *)getTree:(NSString *)treePath;


#pragma mark Blobs

- (NSString *)getBlobsForSHA:(NSString *)shaPath;
- (NSString *)getBlob:(NSString *)blobPath;
- (NSString *)getRawBlob:(NSString *)blobPath;
 

@end
