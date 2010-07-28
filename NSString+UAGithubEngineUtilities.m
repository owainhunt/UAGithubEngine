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
	
	// Because Github returns two different date string formats throughout the API, 
	// we need to check how to process the string based on the format used
	if ([[self substringWithRange:NSMakeRange(10, 1)] isEqualToString:@"T"]) 
	{
		return [NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ %@%@%@", [self substringToIndex:10], [self substringWithRange:NSMakeRange(11, 8)], [self substringWithRange:NSMakeRange(19, 1)], [self substringWithRange:NSMakeRange(20, 2)], [self substringFromIndex:23]]];
	}	
		
	return [NSDate dateWithString:[self stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
	
}


- (NSString *)encodedString
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);

}


@end
