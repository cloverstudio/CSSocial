//
//  CSSocialService.m
//  CSCocialManager2.0
//
//  Created by Marko Hlebar on 6/21/12.
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
                    handler:(CSErrorBlock) handlerBlock {
    return [self showDialogWithMessage:message url:nil photo:photo handler:handlerBlock];
}

-(id) showDialogWithMessage:(NSString*) message
                        url:(NSURL*) url
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock{
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
