//
//  CSSocial.m
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

#import "CSSocial.h"
#import "CSSocialService.h"
#import "CSConstants.h"

@interface CSSocial ()
@property (nonatomic, retain) NSMutableDictionary *services;
@property (nonatomic, assign) id<CSSocialService> lastService;
@property (nonatomic, assign) UIViewController *presentingViewController;
@end

@implementation CSSocial

+ (CSSocial *)sharedManager {
    static CSSocial *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
        return _sharedInstance;
    }
}

- (void)dealloc {
    CS_RELEASE(_services);
    CS_SUPER_DEALLOC;
}

- (id)init {
    self = [super init];
    if (self) {
        _services = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (UIViewController *)viewController {
    ///if no view controller has been assigned, try to assign the main window's rootviewcontroller
    if (![CSSocial sharedManager].presentingViewController) {
        [CSSocial sharedManager].presentingViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }

    NSParameterAssert([CSSocial sharedManager].presentingViewController != nil);
    return [CSSocial sharedManager].presentingViewController;
}

+ (void)setViewController:(UIViewController *)viewController {
    [CSSocial sharedManager].presentingViewController = viewController;
}

///TODO: this is potentially dangerous if two services want to handleOpenURL:
+ (BOOL)handleOpenURL:(NSURL *)url {
    CSSocial *manager = [CSSocial sharedManager];
    if ([manager.lastService respondsToSelector:@selector(handleOpenURL:)]) {
        return [manager.lastService handleOpenURL:url];
    }

    return NO;
}

///TODO: this is potentially dangerous if two services want to openURL:
+ (BOOL)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    CSSocial *manager = [CSSocial sharedManager];
    if ([manager.lastService respondsToSelector:@selector(openURL:sourceApplication:annotation:)]) {
        return [manager.lastService openURL:url sourceApplication:sourceApplication annotation:annotation];
    }

    return NO;
}

+ (CSSocialService *)facebook {
    return [[CSSocial sharedManager] serviceWithClass:[CSSocialServiceFacebook class]];
}

+ (CSSocialService *)twitter {
    return [[CSSocial sharedManager] serviceWithClass:[CSSocialServiceTwitter class]];
}

+ (CSSocialService *)google {
    return [[CSSocial sharedManager] serviceWithClass:[CSSocialServiceGoogle class]];
}

- (CSSocialService *)serviceWithClass:(Class)class {
    NSString *className = NSStringFromClass(class);
    CSSocialService *service = [self.services objectForKey:className];
    if (!service) {
        service = CS_AUTORELEASE([[class alloc] init]);
        [self.services setObject:service forKey:className];
    }
    self.lastService = service;
    return service;
}

+ (NSDictionary *)configDictionary {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CSSocial" ofType:@"plist"]];
    NSAssert(plist, @"CSSocial.plist not found. Please read the manual to learn how to set up the CSSocial.framework");
    return plist;
}

@end

#pragma mark - Helpers
#pragma mark Facebook
@implementation CSSocialServiceFacebook (Helper)

///postToWall:completionBlock:
///posts a simple message to the facebook wall
///@param message message to post to wall
///@param responseBlock contains error if there was an error when posting or nil if all went OK
- (CSSocialRequest *)postToWall:(NSString *)message completionBlock:(CSSocialResponseBlock)responseBlock {
    CSFacebookParameter *parameter = [CSFacebookParameter message:message
                                                             name:nil
                                                             link:nil
                                                       pictureURL:nil
                                                          caption:nil
                                                      description:nil
                                                             icon:nil];

    CSSocialRequest *request = [CSFacebook requestWithParameter:parameter];
    [CSFacebook sendRequest:request
                   response:^(CSSocialRequest *request, id response, NSError *error)
    {
        if (responseBlock) responseBlock(request, response, error);
    }];
    return request;
}

///postPhoto:caption:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param caption album caption of the image
///@param responseBlock contains error if there was an error when posting or nil if all went OK
- (CSSocialRequest *)postPhoto:(UIImage *)photo
                       caption:(NSString *)caption
               completionBlock:(CSSocialResponseBlock)responseBlock {
    CSFacebookParameter *parameter = [CSFacebookParameter photo:photo
                                                        message:caption];

    CSSocialRequest *request = [CSFacebook requestWithParameter:parameter];
    [CSFacebook sendRequest:request
                   response:^(CSSocialRequest *request, id response, NSError *error)
    {
        if (responseBlock) responseBlock(request, response, error);
    }];
    return request;
}

///postPhoto:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param responseBlock contains error if there was an error when posting or nil if all went OK
- (CSSocialRequest *)postPhoto:(UIImage *)photo completionBlock:(CSSocialResponseBlock)responseBlock {
    return [self postPhoto:photo caption:nil completionBlock:responseBlock];
}

@end

#pragma mark Twitter
@implementation CSSocialServiceTwitter (Helper)

///tweet:completionBlock:
///posts a simple tweet to selected Twitter account
///@param tweet tweet to post
///@param responseBlock contains error if there was an error when posting or nil if all went OK
- (CSSocialRequest *)tweet:(NSString *)tweet completionBlock:(CSSocialResponseBlock)responseBlock {
    CSTwitterParameter *parameter = [CSTwitterParameter message:tweet];

    CSSocialRequest *request = [CSTwitter requestWithParameter:parameter];
    [CSTwitter sendRequest:request
                  response:^(CSSocialRequest *request, id response, NSError *error)
    {
        if (responseBlock) responseBlock(request, response, error);
    }];
    return request;
}

@end
