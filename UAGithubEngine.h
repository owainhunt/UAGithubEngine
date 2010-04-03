//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UAGithubEngineDelegate.h"

@interface UAGithubEngine : NSObject {
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
- (id)sendRequest:(NSString *)path withParameters:(NSDictionary *)params;

#pragma mark Repositories

- (id)getRepositoriesForUser:(NSString *)aUser withWatched:(BOOL)watched;
- (id)getRepository:(NSString *)repositoryPath;

#pragma mark Issues 

/*
 
 - (id)getIssuesForRepository:(NSString *)repositoryPath;
 - (id)getIssue:(NSString *)issuePath;
 - (id)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary;
 - (id)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary;
 - (id)closeIssue:(NSString *)issuePath;
 - (id)reopenIssue:(NSString *)issuePath;

*/

#pragma mark Labels

/*
 
 - (id)getLabelsForRepository:(NSString *)repositoryPath;
 - (id)getIssuesForLabel:(NSString *)label;
 - (id)addLabelForRepository:(NSString *)repositoryPath;
 - (id)addLabel:(NSString *)label toIssue:(NSString *)issuePath;
 - (id)removeLabel:(NSString *)label fromIssue:(NSString *)issuePath;
 
*/

#pragma mark Comments

/*
 
 - (id)getCommentsForIssue:(NSString *)issuePath;
 - (id)addComment:(NSString *)comment toIssue:(NSString *)issuePath;

*/
 
#pragma mark Users

/*
 
 - (id)getUser:(NSString *)username;
 
*/

@end
