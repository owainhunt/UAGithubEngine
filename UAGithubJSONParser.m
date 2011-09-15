//
//  UAGithubJSONParser.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 27/07/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubJSONParser.h"
#import "NSArray+Utilities.h"
#import "NSString+UAGithubEngineUtilities.h"

@implementation UAGithubJSONParser

- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    if ((self = [super init])) 
	{
        json = [theJSON retain];
        delegate = theDelegate;
		connectionIdentifier = [theIdentifier retain];
        requestType = reqType;
		responseType = respType;
    }
	
    return self;
	
}


- (void)dealloc
{
	[json release];
	[connectionIdentifier release];
	[super dealloc];
	
}


- (void)parse
{
	NSError *error = nil;
    NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
	
	if (!error)
	{
		if ([[[jsonArray firstObject] allKeys] containsObject:@"error"])
		{
            NSDictionary *dictionary = [jsonArray firstObject];
			error = [NSError errorWithDomain:@"UAGithubEngineGithubError" code:0 userInfo:[NSDictionary dictionaryWithObject:[dictionary objectForKey:@"error"] forKey:@"errorMessage"]];
			[delegate parsingFailedForConnection:connectionIdentifier ofResponseType:responseType withError:error];
			return;
		}
		
		// Numbers and 'TRUE'/'FALSE' boolean are handled by the parser
		// We need to handle date elements and 0/1 boolean values 
		for (NSMutableDictionary *theDictionary in jsonArray)
		{
			for (NSString *keyString in dateElements)
			{
				if ([theDictionary objectForKey:keyString] && ![[theDictionary objectForKey:keyString] isEqual:nil]) {
					if ([[theDictionary objectForKey:keyString] respondsToSelector:@selector(dateFromGithubDateString)])
					{
						NSDate *date = [[theDictionary objectForKey:keyString] dateFromGithubDateString];
						if (date != nil) 
						{
							[theDictionary setObject:date forKey:keyString];
						}
					}
				}
			}
			
			for (NSString *keyString in boolElements)
			{
				if ([theDictionary objectForKey:keyString] && ![[theDictionary objectForKey:keyString] isEqual:nil]) {
					[theDictionary setObject:[NSNumber numberWithBool:[[theDictionary objectForKey:keyString] intValue]] forKey:keyString];
				}
			}
					 
		}

		[delegate parsingSucceededForConnection:connectionIdentifier ofResponseType:responseType withParsedObjects:jsonArray];
	}
	else 
	{
		[delegate parsingFailedForConnection:connectionIdentifier ofResponseType:responseType withError:error];
	}
}	



@end
