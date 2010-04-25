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
	//[githubEngine getCommitsForBranch:@"owainhunt/ics/master"];
	//[githubEngine getIssuesForRepository:@"owainhunt/iscore" withRequestType:UAGithubAllIssuesRequest];
	[githubEngine getUser:@"owainhunt"];
	[NSApp terminate:self];

}

@end
