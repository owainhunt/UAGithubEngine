//
//  UAGithubJSONParser.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngineGlobalHeader.h"
#import "UAGithubParserDelegate.h"
#import "UAGithubEngineRequestTypes.h"

@interface UAGithubJSONParser : NSObject {
	id <UAGithubParserDelegate> delegate;
    NSString *connectionIdentifier;
    UAGithubRequestType requestType;
	UAGithubResponseType responseType;
    NSData *json;
	
	NSString *baseElement;
	NSArray *numberElements;
	NSArray *boolElements;
	NSArray *dateElements;
	NSArray *dictionaryElements;
	NSArray *arrayElements;
	
}

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType;
- (void)parse;

@end
