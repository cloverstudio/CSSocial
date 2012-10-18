//
//  CSSocialRequest.m
//  CSUtilities
//
//  Created by marko.hlebar on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSSocialRequest.h"

@interface CSSocialRequest ()
@property (nonatomic, assign) id service;
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

+(CSSocialRequest*) requestWithService:(id)service
{
    return CS_AUTORELEASE([[self alloc] initWithService:service]);
}

-(id) initWithService:(id) service
{
    self = [super init];
    if (self) 
    {
        self.service = service;
    }
    return self;
}

-(void) start
{
    _executing = YES;
    _finished = NO;
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

-(id) method
{
    return nil;
}

@end

