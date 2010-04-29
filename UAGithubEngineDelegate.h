//
//  UAGithubEngineDelegate.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol UAGithubEngineDelegate

- (void)requestSucceeded:(NSString *)connectionIdentifier;
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;


@optional

- (void)repositoriesReceived:(NSArray *)repositories forConnection:(NSString *)connectionIdentifier;
- (void)deployKeysReceieved:(NSArray *)deployKeys forConnection:(NSString *)connectionIdentifier;
- (void)collaboratorsReceievd:(NSArray *)collaborators forConnection:(NSString *)connectionIdentifier;
- (void)languagesReceieved:(NSArray *)languages forConnection:(NSString *)connectionIdentifier;
- (void)tagsReceived:(NSArray *)tags forConnection:(NSString *)connectionIdentifier;
- (void)branchesReceived:(NSArray *)branches forConnection:(NSString *)connectionIdentifier;
- (void)issuesReceived:(NSArray *)issues forConnection:(NSString *)connectionIdentifier;
- (void)issueCommentsReceived:(NSArray *)issueComments forConnection:(NSString *)connectionIdentifier;
- (void)labelsReceived:(NSArray *)labels forConnection:(NSString *)connectionIdentifier;
- (void)usersReceived:(NSArray *)users forConnection:(NSString *)connectionIdentifier;
- (void)commitsReceived:(NSArray *)commits forConnection:(NSString *)connectionIdentifier;
- (void)blobsReceieved:(NSArray *)blobs forConnection:(NSString *)connectionIdentifier;
- (void)blobReceived:(NSArray *)blob forConnection:(NSString *)connectionIdentifier;
- (void)rawBlobReceived:(NSData *)blob forConnection:(NSString *)connectionIdentifier;



@end
