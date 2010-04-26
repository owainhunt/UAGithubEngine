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

@end
