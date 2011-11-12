//
//  UAGithubURLConnection.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 26/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubURLConnection.h"
#import "NSString+UUID.h"


@implementation UAGithubURLConnection

@synthesize data, requestType, responseType, identifier;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(UAGithubRequestType)reqType responseType:(UAGithubResponseType)respType
{
    if ((self = [super initWithRequest:request delegate:delegate])) 
    {
        data = [[NSMutableData alloc] initWithCapacity:0];
        identifier = [[NSString stringWithNewUUID] retain];
        requestType = reqType;
		responseType = respType;
    }
	NSLog(@"New %@ connection: %@, %@", request.HTTPMethod, request, identifier);
    
    return self;
}

// Can probably remove reqtype and resptype from here
+ (id)asyncRequest:(NSURLRequest *)request success:(id(^)(NSData *, NSURLResponse *))successBlock_ failure:(id(^)(NSError *))failureBlock_ 
{
    // This has to be dispatch_sync rather than _async, otherwise our successBlock executes before the request is done and we're all bass-ackwards.
	//dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        @autoreleasepool 
        {    
            NSLog(@"New %@ connection: %@", request.HTTPMethod, request);

            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error) {
                return failureBlock_(error);
            } else {
                return successBlock_(data,response);
            }
        }
        
	//});
}


- (void)resetDataLength
{
    [data setLength:0];	
}


- (void)appendData:(NSData *)newData
{
    [data appendData:newData];
}

- (void)dealloc
{
    [data release];
    [identifier release];
    
    [super dealloc];
}


@end
