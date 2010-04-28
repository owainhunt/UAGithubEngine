//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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

- (void)getUser:(NSString *)user;


#pragma mark Repositories

- (void)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched;
- (void)getRepository:(NSString *)repositoryPath;


#pragma mark Commits

- (void)getCommitsForBranch:(NSString *)branchPath;
- (void)getCommit:(NSString *)commitPath;


#pragma mark Issues 

- (void)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType;
- (void)getIssue:(NSString *)issuePath;
- (void)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (void)closeIssue:(NSString *)issuePath;
- (void)reopenIssue:(NSString *)issuePath;


#pragma mark Labels

- (void)getLabelsForRepository:(NSString *)repositoryPath;
- (void)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath;
- (void)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath;
- (void)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;
- (void)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath;


#pragma mark Comments

- (void)getCommentsForIssue:(NSString *)issuePath;
- (void)addComment:(NSString *)comment toIssue:(NSString *)issuePath;
 

@end
