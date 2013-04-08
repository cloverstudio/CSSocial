//
//  CSSocialService.m
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
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
    return [NSOperationQueue currentQueue];
    //return [[NSOperationQueue alloc] init];
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    NSAssert(NO, @"Override me");
}

-(void) logout
{
    NSAssert(NO, @"Override me");
}

-(BOOL) isAuthenticated
{
    NSAssert(NO, @"Override me");
    return NO;
}

-(void) sendRequest:(CSSocialRequest*) request
           response:(CSSocialResponseBlock) responseBlock
{
    request.responseBlock = responseBlock;
    [self login:^
     {
         [self requestPermissionsForRequest:request
                           permissionsBlock:^(NSError* error)
          {
              if (!error)
              {
                  [self.requestQueue addOperation:request];
              }
              else
              {
                  responseBlock(request, nil, error);
              }
          }
          ];
     }
          error:^(NSError *error) {
              responseBlock(request, nil, error);
          }];
}

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>)parameter
{
    return [self constructRequestWithParameter:parameter];
}

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>) parameter
                                response:(CSSocialResponseBlock) responseBlock
{
    CSSocialRequest *request = [self requestWithParameter:parameter];
    [self sendRequest:request
             response:responseBlock];
    return request;
}

-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock
{
    ///override this in a subclass to support dialog.
    handlerBlock([self errorWithLocalizedDescription:@"Dialog unavaliable"]);
    return nil;
}

-(BOOL) permissionGranted:(NSString*) permission
{    
    ///the default value is that the permissions are granted.
    ///some services like Facebook need to extend these to make request possible.
    return YES;
}

-(void) requestPermissionsForRequest:(CSSocialRequest *)request permissionsBlock:(CSErrorBlock)permissionsBlock
{
    if (![self permissionGranted:nil]) return;
    ///implement this in service where you need extended permissions for the request to succeed
    permissionsBlock(nil);
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

-(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation
{
    NSAssert(NO, @"Override me");
    return NO;
}

-(NSError*) errorWithLocalizedDescription:(NSString*) description
{
    return [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

@end
