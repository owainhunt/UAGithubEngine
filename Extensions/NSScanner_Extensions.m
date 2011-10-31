//
//  NSScanner_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/08/2005.
//  Copyright 2005 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSScanner_Extensions.h"

#import "NSCharacterSet_Extensions.h"

@implementation NSScanner (NSScanner_Extensions)

- (NSString *)remainingString
{
return([[self string] substringFromIndex:[self scanLocation]]);
}

- (unichar)currentCharacter
{
return([[self string] characterAtIndex:[self scanLocation]]);
}

- (unichar)scanCharacter
{
NSUInteger theScanLocation = [self scanLocation];
unichar theCharacter = [[self string] characterAtIndex:theScanLocation];
[self setScanLocation:theScanLocation + 1];
return(theCharacter);
}

- (BOOL)scanCharacter:(unichar)inCharacter
{
NSUInteger theScanLocation = [self scanLocation];
if ([[self string] characterAtIndex:theScanLocation] == inCharacter)
	{
	[self setScanLocation:theScanLocation + 1];
	return(YES);
	}
else
	return(NO);
}

- (void)backtrack:(unsigned)inCount
{
NSUInteger theScanLocation = [self scanLocation];
if (inCount > theScanLocation)
	[NSException raise:NSGenericException format:@"Backtracked too far."];
[self setScanLocation:theScanLocation - inCount];
}

- (BOOL)scanCStyleComment:(NSString **)outComment
{
if ([self scanString:@"/*" intoString:NULL] == YES)
	{
	NSString *theComment = NULL;
	if ([self scanUpToString:@"*/" intoString:&theComment] == NO)
		[NSException raise:NSGenericException format:@"Started to scan a C style comment but it wasn't terminated."];
		
	if ([theComment rangeOfString:@"/*"].location != NSNotFound)
		[NSException raise:NSGenericException format:@"C style comments should not be nested."];
	
	if ([self scanString:@"*/" intoString:NULL] == NO)
		[NSException raise:NSGenericException format:@"C style comment did not end correctly."];
		
	if (outComment != NULL)
		*outComment = theComment;

	return(YES);
	}
else
	{
	return(NO);
	}
}

- (BOOL)scanCPlusPlusStyleComment:(NSString **)outComment
{
if ([self scanString:@"//" intoString:NULL] == YES)
	{
	NSString *theComment = NULL;
	[self scanUpToCharactersFromSet:[NSCharacterSet linebreaksCharacterSet] intoString:&theComment];
	[self scanCharactersFromSet:[NSCharacterSet linebreaksCharacterSet] intoString:NULL];

	if (outComment != NULL)
		*outComment = theComment;

	return(YES);
	}
else
	{
	return(NO);
	}
}

@end
