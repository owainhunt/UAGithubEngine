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
    return [self initWithJSON:theJSON delegate:theDelegate connectionIdentifier:theIdentifier requestType:reqType responseType:respType dateElements:nil];	
}


- (id)initWithJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType dateElements:(NSArray *)dates
{
    
    NSMutableArray *standardDateElements = [NSMutableArray arrayWithObjects:@"created_at", @"updated_at", @"closed_at", @"due_on", @"pushed_at", @"committed_at", @"merged_at", @"date", @"expirationdate", nil];
    
    if ((self = [super init])) 
	{
        json = [theJSON retain];
        delegate = theDelegate;
		connectionIdentifier = [theIdentifier retain];
        requestType = reqType;
		responseType = respType;
        dateElements = [[standardDateElements arrayByAddingObjectsFromArray:dates] retain];
    }
	
    //[self parse];
    
    return self;
    
}


/*
+ (void)parseJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType success:(void(^)(id))successBlock_ failure:(void(^)(id, NSError *))failureBlock_;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:theJSON options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
        
        NSMutableArray *jsonArray;
        
        if ([jsonObj isKindOfClass:[NSDictionary class]])
        {
            jsonArray = [NSMutableArray arrayWithObject:jsonObj]; 
        }
        else
        {
            jsonArray = [jsonObj mutableCopy];
        }
        
        if (!error)
        {
            if ([[[jsonArray firstObject] allKeys] containsObject:@"error"])
            {
                NSDictionary *dictionary = [jsonArray firstObject];
                error = [NSError errorWithDomain:@"UAGithubEngineGithubError" code:0 userInfo:[NSDictionary dictionaryWithObject:[dictionary objectForKey:@"error"] forKey:@"errorMessage"]];
                return;
            }
            
            successBlock_(jsonArray);
        }
        else 
        {
            failureBlock_(jsonArray, error);
        }
    });
}
*/


+ (id)parseJSON:(NSData *)theJSON delegate:(id)theDelegate connectionIdentifier:(NSString *)theIdentifier requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    NSMutableArray *jsonArray;
    NSError *error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:theJSON options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
    
    
    if ([jsonObj isKindOfClass:[NSDictionary class]])
    {
        jsonArray = [NSMutableArray arrayWithObject:jsonObj]; 
    }
    else
    {
        jsonArray = [jsonObj mutableCopy];
    }
    
    if (!error)
    {
        if ([[[jsonArray firstObject] allKeys] containsObject:@"error"])
        {
            NSDictionary *dictionary = [jsonArray firstObject];
            error = [NSError errorWithDomain:@"UAGithubEngineGithubError" code:0 userInfo:[NSDictionary dictionaryWithObject:[dictionary objectForKey:@"error"] forKey:@"errorMessage"]];
            NSLog(@"Error: %@", error);
            return nil;
        }
        
    }
    else
    {
#pragma mark TODO do something with error
    }
    
    return jsonArray;
}


- (void)dealloc
{
	[json release];
	[connectionIdentifier release];
    [dateElements release];
	[super dealloc];
	
}


@end
