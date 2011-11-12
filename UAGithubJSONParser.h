//
//  UAGithubJSONParser.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UAGithubEngineRequestTypes.h"

@interface UAGithubJSONParser : NSObject {
    NSString *connectionIdentifier;
    UAGithubRequestType requestType;
	UAGithubResponseType responseType;
    NSData *json;
	
	NSArray *dateElements;

}

+ (id)parseJSON:(NSData *)theJSON error:(NSError **)error;

@end
