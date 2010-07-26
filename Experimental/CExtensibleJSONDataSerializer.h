//
//  CExtensibleJSONDataSerializer.h
//  CouchNotes
//
//  Created by Jonathan Wight on 06/20/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CJSONDataSerializer.h"

typedef NSString *(^JSONConversionTest)(id inObject);
typedef id (^JSONConversionConverter)(id inObject);

@interface CExtensibleJSONDataSerializer : CJSONDataSerializer {
	NSSet *tests;
	NSDictionary *convertersByName;
}

@property (readwrite, nonatomic, retain) NSSet *tests;
@property (readwrite, nonatomic, retain) NSDictionary *convertersByName;

@end
