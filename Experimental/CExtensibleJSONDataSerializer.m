//
//  CExtensibleJSONDataSerializer.m
//  CouchNotes
//
//  Created by Jonathan Wight on 06/20/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CExtensibleJSONDataSerializer.h"

@implementation CExtensibleJSONDataSerializer

@synthesize tests;
@synthesize convertersByName;

- (void)dealloc
{
[tests release];
tests = NULL;
//
[convertersByName release];
convertersByName = NULL;
//
[super dealloc];
}

- (NSData *)serializeObject:(id)inObject error:(NSError **)outError
{
NSData *theData = NULL;
for (JSONConversionTest theTest in self.tests)
	{
	NSString *theName = theTest(inObject);
	if (theName != NULL)
		{
		JSONConversionConverter theConverter = [self.convertersByName objectForKey:theName];
		id theObject = theConverter(inObject);
		if (theObject)
			{
			NSError *theError = NULL;
			theData = [super serializeObject:theObject error:&theError];
			if (theData != NULL)
				break;
			}
		}
	}
	
if (theData == NULL)
	{
	theData = [super serializeObject:inObject error:outError];
	}
	
return(theData);
}

@end
