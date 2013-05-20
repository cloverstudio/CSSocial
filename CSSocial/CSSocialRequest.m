//
//  CSSocialRequest.m
//  CSUtilities
//
//  Created by marko.hlebar on 7/4/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequest.h"
#import <UIKit/UIApplication.h>

@interface CSSocialRequest ()
@property (nonatomic, assign) id service;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@end

@implementation CSSocialRequest
@synthesize APIcall;
@synthesize params;
@synthesize responseBlock;
@synthesize service = _service;

-(void) dealloc
{
    _service = nil;
    CS_RELEASE(APIcall);
    CS_RELEASE(params);
    CS_RELEASE(responseBlock);
    CS_SUPER_DEALLOC;
}

+(CSSocialRequest*) requestWithService:(id)service parameters:(NSDictionary*) parameters
{
    return CS_AUTORELEASE([[self alloc] initWithService:service parameters:parameters]);
}

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{
    self = [super init];
    if (self) 
    {
        self.queuePriority = NSOperationQueuePriorityHigh;
        self.service = service;
        self.params = parameters;
        _cancelled = NO;
        _executing = NO;
        _finished = NO;
        
        [self beginBackgroundTask];
    }
    return self;
}

-(void) beginBackgroundTask
{
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }];
}

-(void) endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

-(void) start
{
    _executing = YES;
    _finished = NO;
    [self makeRequest];
}

-(void) finish
{
    [self endBackgroundTask];
}

-(void) makeRequest
{
    NSAssert(NO, @"Override me in subclass");
}


-(void) receivedResponse:(id)result error:(NSError *)error
{
    self.responseBlock(self, [self parseResponse:result], error);
    [self receivedResponse];
    [self finish];
}

///each subclass can parse its own response or just return the raw response
-(id) parseResponse:(id)rawResponse
{
    return rawResponse;
}

-(void) receivedResponse
{
    if (!_executing) return;
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void) cancel
{
    _cancelled = YES;
}

-(BOOL) isConcurrent
{
    return YES;
}

-(BOOL) isExecuting
{
    return _executing;
}

-(BOOL) isFinished
{
    return _finished;
}

@end

