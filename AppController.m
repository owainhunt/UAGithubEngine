//
//  UAGithubEngineAppDelegate.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	githubEngine = [[UAGithubEngine alloc] initWithUsername:@"owainhunt" apiKey:@"cb67aaa5fe26f4a0509b5a04d8a4a19b" delegate:self];
	//[githubEngine getCommit:@"owainhunt/uagithubengine/251c735cdd8285c63fc952bd58e5f48e22a26e6b"];
	//[githubEngine getIssuesForRepository:@"owainhunt/iscore" withRequestType:UAGithubAllIssuesRequest];
	[githubEngine getUser:@"owainhunt"];

}


#pragma mark UAGithubEngineDelegate Methods

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
	NSLog(@"Request succeeded: %@", connectionIdentifier);

}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    NSLog(@"Request failed: %@, error: %@ (%@)", connectionIdentifier, [error localizedDescription], [error userInfo]);
	
}


- (void)repositoriesReceived:(NSArray *)repositories forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received repositories for connection: %@, %@", connectionIdentifier, repositories);

}


- (void)issuesReceived:(NSArray *)issues forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received issues for connection: %@, %@", connectionIdentifier, issues);

}


- (void)issueCommentsReceived:(NSArray *)issueComments forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received issueComments for connection: %@, %@", connectionIdentifier, issueComments);

	
}


- (void)labelsReceived:(NSArray *)labels forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received labels for connection: %@, %@", connectionIdentifier, labels);

}


- (void)usersReceived:(NSArray *)users forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received users for connection: %@, %@", connectionIdentifier, users);

	
}


- (void)commitsReceived:(NSArray *)commits forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received commits for connection: %@, %@", connectionIdentifier, commits);

	
}


@end
