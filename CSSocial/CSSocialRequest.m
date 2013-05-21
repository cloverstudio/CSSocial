//
//  CSSocialRequest.m
//  CSUtilities
//
//  Created by Marko Hlebar on 7/4/12.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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

