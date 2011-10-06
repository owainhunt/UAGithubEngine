//
//  NSString+UAGithubEngineUtilities.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 08/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "NSString+UAGithubEngineUtilities.h"


@implementation NSString(UAGithubEngineUtilities)

- (NSDate *)dateFromGithubDateString {
	
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	NSString *dateString = self;
    
    if (![[self substringWithRange:NSMakeRange([self length] - 1, 1)] isEqualToString:@"Z"])
    {
        NSMutableString *newDate = [self mutableCopy];
        [newDate deleteCharactersInRange:NSMakeRange(19, 1)];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        [dateString release];
        dateString = newDate;
        [newDate release];
    }
    else
    {    
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
				
    return [df dateFromString:dateString];

}


- (NSString *)encodedString
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);

}


@end
