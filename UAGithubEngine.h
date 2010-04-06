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
}

@property (assign) id <UAGithubEngineDelegate> delegate;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *dataFormat;

- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate;
- (NSData *)sendRequest:(NSString *)path withParameters:(NSDictionary *)params;


#pragma mark Repositories

- (void)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched;
- (void)getRepository:(NSString *)repositoryPath;


#pragma mark Issues 

- (id)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType;
- (void)getIssue:(NSString *)issuePath;
- (id)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
- (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
- (id)closeIssue:(NSString *)issuePath;
- (id)reopenIssue:(NSString *)issuePath;


#pragma mark Labels

- (void)getLabelsForRepository:(NSString *)repositoryPath;
- (id)addLabel:(NSString *)label toIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath;
- (id)removeLabel:(NSString *)label fromIssue:(NSInteger *)issueNumber inRepository:(NSString *)repositoryPath;;


#pragma mark Comments

- (void)getCommentsForIssue:(NSString *)issuePath;
- (id)addComment:(NSString *)comment toIssue:(NSString *)issuePath;
 

#pragma mark Users

- (void)getUser:(NSString *)user;
 

@end
