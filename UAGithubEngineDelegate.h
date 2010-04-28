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
- (void)issuesReceived:(NSArray *)issues forConnection:(NSString *)connectionIdentifier;
- (void)issueCommentsReceived:(NSArray *)issueComments forConnection:(NSString *)connectionIdentifier;
- (void)labelsReceived:(NSArray *)labels forConnection:(NSString *)connectionIdentifier;
- (void)usersReceived:(NSArray *)users forConnection:(NSString *)connectionIdentifier;
- (void)commitsReceived:(NSArray *)commits forConnection:(NSString *)connectionIdentifier;


@end
