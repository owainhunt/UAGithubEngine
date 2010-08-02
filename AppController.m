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
	//githubEngine = [[UAGithubEngine alloc] initWithUsername:@"orhunt" apiKey:@"21b32f25a201e29005ec14d2f39361ff" delegate:self];
	
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
	//[githubEngine getDeployKeysForRepository:@"uagithubengine"];
	//[githubEngine addDeployKey:@"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzavRnP2iPCTjhh6gOsAmQSS59zrMwR+YVsGYHmu4qlbKJNUvY1R1SGIe7+GBRsxiB/OV+esC9tgWFVSI7uZzDKNoCVnvmJzfueIxn7wddoHglbJ8vT2bI2G1hdQ/8tn11TaaEUcsopEMPp6Asx1UzLqtkTmP4kKdBMem3G2yfbe0va89NSah1wUow8YZkvxKaVl/ghvlV2byRpr5KSAQ2RYqyJdwZCNtFWZs6SgsJUXMBUp2Ahhb7g1vQWhjMj+PLPTtH24KWpTxXcZtwF0G7Gj8SdCP71b06BD3zEi3J6LEoAyJCk8mEM7Lu59pT1w7KtY+twp94dZEuJEDgcS2+w== owain@underscoreapps.com" withTitle:@"Test Key" ToRepository:@"uagithubengine"];
	//[githubEngine removeDeployKey:@"391578" fromRepository:@"uagithubengine"];
	//[githubEngine getCollaboratorsForRepository:@"rails/rails"];
	//[githubEngine addCollaborator:@"orhunt" toRepository:@"uagithubengine"];
	//[githubEngine removeCollaborator:@"orhunt" fromRepository:@"uagithubengine"];
	//[githubEngine getPushableRepositories];
	//[githubEngine getNetworkForRepository:@"rails/rails"];
	//[githubEngine getLanguageBreakdownForRepository:@"rails/rails"];
	//[githubEngine getTagsForRepository:@"owainhunt/loops"];
	//[githubEngine getBranchesForRepository:@"owainhunt/uagithubengine"];
	
	//[githubEngine getCommitsForBranch:@"owainhunt/uagithubengine/json"];
	//[githubEngine getCommit:@"owainhunt/uagithubengine/e7777a70edc4f656678c6f79efcf82a44d5bd041"];

	//[githubEngine getIssuesForRepository:@"owainhunt/uagithubengine" withRequestType:UAGithubIssuesClosedRequest];
	//[githubEngine getIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine editIssue:@"owainhunt/uagithubengine/1" withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Issue [edited]", @"title", @"Test body [edited again]", @"body", nil]];
	//[githubEngine addIssueForRepository:@"owainhunt/UAGithubEngine" withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"Test issue mkII", @"title", @"Test body", @"body", nil]];
	//[githubEngine closeIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine reopenIssue:@"owainhunt/uagithubengine/1"];

	//[githubEngine getLabelsForRepository:@"owainhunt/uagithubengine"];
	//[githubEngine addLabel:@"Super_Hyper_Mega_Bug" toIssue:1 inRepository:@"owainhunt/uagithubengine"];
	//[githubEngine removeLabel:@"Mega Bug" fromIssue:1 inRepository:@"owainhunt/uagithubengine"];
	//[githubEngine addLabel:@"Major_Bug_No_Really" toRepository:@"owainhunt/uagithubengine"];
	//[githubEngine removeLabel:@"Feature Request" fromRepository:@"owainhunt/uagithubengine"];
	
	//[githubEngine getCommentsForIssue:@"owainhunt/uagithubengine/1"];
	//[githubEngine addComment:@"This thing is still awesome." toIssue:@"owainhunt/uagithubengine/1"];
	
	//[githubEngine getTree:@"owainhunt/uagithubengine/2af97f0e241c13345212"];
	
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


- (void)languagesReceived:(NSArray *)languages forConnection:(NSString *)connectionIdentifier
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


- (void)treeReceived:(NSArray *)treeContents forConnection:(NSString *)connectionIdentifier
{
	NSLog(@"Received tree contents for connection: %@, %@", connectionIdentifier, treeContents);
	
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
