//
//  CSSocialService.m
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSSocialService.h"

@interface CSSocialService() <CSSocialService>
@end

@implementation CSSocialService
-(void) dealloc
{
    CS_RELEASE(_requestQueue);
    CS_SUPER_DEALLOC;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.requestQueue = [self operationQueue];
    }
    return self;
}

-(NSOperationQueue*) operationQueue
{
    return [NSOperationQueue mainQueue];
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    NSAssert(NO, @"Override me");
}

-(void) request:(CSSocialRequest*) request
       response:(CSSocialResponseBlock) responseBlock;
{
    NSAssert(NO, @"Override me");
}

-(BOOL) isAuthenticated
{
    NSAssert(NO, @"Override me");
    return NO;
}

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>) parameter
                                response:(CSSocialResponseBlock) responseBlock
{
    __block CSSocialRequest *request = [self constructRequestWithParameter:parameter];
    request.responseBlock = responseBlock;
    [self login:^
     {
         [self.requestQueue addOperation:request];
     }
          error:^(NSError *error) {
              responseBlock(request, nil, error);
          }];
    
    return request;
}

-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>) parameter
{
    NSAssert(NO, @"Override me");
    return nil;
}

-(NSString*) serviceName
{
    return [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:@"CSSocialService" withString:@""];
}

-(BOOL) handleOpenURL:(NSURL *)url
{
    NSAssert(NO, @"Override me");
    return NO;
}

-(NSError*) errorWithLocalizedDescription:(NSString*) description
{
    return [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

@end
