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
	
	// Because Github returns three different date string formats throughout the API, 
	// we need to check how to process the string based on the format used
	if ([[self substringWithRange:NSMakeRange(10, 1)] isEqualToString:@"T"])
	{
		if ([[self substringWithRange:NSMakeRange([self length] - 1, 1)] isEqualToString:@"Z"])
			// eg 2010-05-23T21:26:03.921Z (UTC with milliseconds)
		{
			return [NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ +0000", [self substringToIndex:10], [self substringWithRange:NSMakeRange(11, 8)]]];
		}
		else 
			// eg 2010-04-07T12:50:15-07:00
		{
			return [NSDate dateWithString:[NSString stringWithFormat:@"%@ %@ %@%@", [self substringToIndex:10], [self substringWithRange:NSMakeRange(11, 8)], [self substringWithRange:NSMakeRange(19, 3)], [self substringFromIndex:23]]];
		}
	}	
		
	// eg 2010/07/28 21:21:00 +0100
	return [NSDate dateWithString:[self stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
	
}


- (NSString *)encodedString
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);

}


@end
