//
//  UAGithubEngineAppDelegate.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	githubEngine = [[UAGithubEngine alloc] initWithUsername:@"owainhunt" apiKey:@"cb67aaa5fe26f4a0509b5a04d8a4a19b" delegate:self];
	
	//[githubEngine getUser:@"owainhunt"];
	//[githubEngine searchUsers:@"owainhunt" byEmail:NO];
	
	//[githubEngine getRepositoriesForUser:@"owainhunt" includeWatched:YES];
	//[githubEngine getRepository:@"owainhunt/uagithubengine"];
	//[githubEngine searchRepositories:@"rails"];
	//[githubEngine updateRepository:@"owainhunt/uagithubengine" withInfo:[NSDictionary dictionaryWithObject:@"1" forKey:@"has_downloads"]];
	//[githubEngine watchRepository:@"github/markup"];
	//[githubEngine unwatchRepository:@"github/markup"];
	//[githubEngine forkRepository:@"github/markup"];
	//[githubEngine createRepositoryWithInfo:[NSDictionary dictionaryWithObject:@"APICreation" forKey:@"name"]];
	//[githubEngine publiciseRepository:@"uagithubengine"];
	//[githubEngine privatiseRepository:@"uagithubengine"];
	[githubEngine getDeployKeysForRepository:@"uagithubengine"];
	
	//[githubEngine addLabel:@"Major Bug No Really" toRepository:@"owainhunt/uagithubengine"];
	//[githubEngine removeLabel:@"Feature Request" fromRepository:@"owainhunt/uagithubengine"];
	//[githubEngine getCollaboratorsForRepository:@"rails/rails"];

	//[githubEngine getCommitsForBranch:@"owainhunt/uagithubengine/master"];
	//[githubEngine getCommit:@"owainhunt/uagithubengine/f7e0012470166d8e1a88"];

	//[githubEngine getIssuesForRepository:@"owainhunt/uagithubengine" withRequestType:UAGithubOpenIssuesRequest];
	//[githubEngine getIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine editIssue:@"owainhunt/uagithubengine/1" withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Issue [edited]", @"title", @"Test body [edited again]", @"body", nil]];
	//[githubEngine addIssueForRepository:@"owainhunt/UAGithubEngine" withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"Test issue mkII", @"title", @"Test body", @"body", nil]];
	//[githubEngine closeIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine reopenIssue:@"owainhunt/uagithubengine/1"];

	//[githubEngine getLabelsForRepository:@"owainhunt/uagithubengine"];
	//[githubEngine addLabel:@"Mega Bug" toIssue:1 inRepository:@"owainhunt/uagithubengine"];
	//[githubEngine removeLabel:@"Bug" fromIssue:1 inRepository:@"owainhunt/uagithubengine"];
	
	//[githubEngine getCommentsForIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine addComment:@"This thing is still awesome." toIssue:@"owainhunt/uagithubengine/1"];
	
	//[githubEngine getBlobsForSHA:@"owainhunt/uagithubengine/f4667fc9a965b8f9438b8776ad61f0d5c5074e88"];
	//[githubEngine getBlob:@"owainhunt/uagithubengine/f4667fc9a965b8f9438b8776ad61f0d5c5074e88/main.m"];
	//[githubEngine getRawBlob:@"owainhunt/uagithubengine/14d56058704dd3e046edaec20e93597867ef761e"];
	
}

- (void)dealloc
{
	[githubEngine release];
	[super dealloc];
	
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


- (void)deployKeysReceived:(NSArray *)deployKeys forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received deployKeys for connection: %@, %@", connectionIdentifier, deployKeys);

}


- (void)collaboratorsReceived:(NSArray *)collaborators forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received collaborators for connection: %@, %@", connectionIdentifier, collaborators);

}


- (void)languagesReceieved:(NSArray *)languages forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received languages for connection: %@, %@", connectionIdentifier, languages);

}


- (void)tagsReceived:(NSArray *)tags forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received tags for connection: %@, %@", connectionIdentifier, tags);

}


- (void)branchesReceived:(NSArray *)branches forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received branches for connection: %@, %@", connectionIdentifier, branches);

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


- (void)blobsReceieved:(NSArray *)blobs forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received blobs for connection: %@, %@", connectionIdentifier, blobs);

}


- (void)blobReceived:(NSArray *)blob forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received blob for connection: %@, %@", connectionIdentifier, blob);

}


- (void)rawBlobReceived:(NSData *)blob forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received blob for connection: %@, %@", connectionIdentifier, [[[NSString alloc] initWithData:blob encoding:NSASCIIStringEncoding] autorelease]);

}


@end
