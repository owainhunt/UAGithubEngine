//
//  UAGithubParserDelegate.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 05/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAGithubEngineRequestTypes.h"


@protocol UAGithubParserDelegate

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withParsedObjects:(NSArray *)parsedObjects;
- (void)parsingFailedForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withError:(NSError *)parseError;

@end
