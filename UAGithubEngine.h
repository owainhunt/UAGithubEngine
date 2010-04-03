//
//  UAGithubEngine.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UAGithubEngineDelegate.h"

@interface UAGithubEngine : NSObject {
	id <UAGithubEngineDelegate> delegate;
	NSString *username;
	NSString *apiKey;
	NSString *dataFormat;
}

@property (assign) id <UAGithubEngineDelegate> delegate;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *dataFormat;

- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate;
- (id)sendRequest:(NSString *)path withParameters:(NSDictionary *)params;
- (id)getRepositoriesForUser:(NSString *)aUser withWatched:(BOOL)watched;
@end
