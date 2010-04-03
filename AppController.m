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
	// Insert code here to initialize your application 
	githubEngine = [[UAGithubEngine alloc] initWithUsername:@"owainhunt" apiKey:@"cb67aaa5fe26f4a0509b5a04d8a4a19b" delegate:self];
	NSLog(@"%@", [githubEngine getRepository:@"owainhunt/ics"]);
	[NSApp terminate:self];

}

@end
