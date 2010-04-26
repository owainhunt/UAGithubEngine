//
//  UAGithubParserDelegate.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UAGithubEngineRequestTypes.h"


@protocol UAGithubParserDelegate

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier withParsedObjects:(NSArray *)parsedObjects;
- (void)parsingFailedForRequestOfType:(UAGithubRequestType)requestType withError:(NSError *)parseError;

@end
