//
//  CSOAuthService.m
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSOAuthService.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAConsumer.h"
#import "CSOAuthViewController.h"
#import "JSONKit.h"

@interface CSOAuthService()

@end

@implementation CSOAuthService
@synthesize requestToken;

-(id) init
{
    self = [super init];
    if (self) {
        self.consumer = [[OAConsumer alloc] initWithKey:self.apiKey
                                                 secret:self.secretKey
                                                  realm:self.realm];
    }
    return self;
}

-(NSOperationQueue*) operationQueue
{
    return CS_AUTORELEASE([[NSOperationQueue alloc] init]);
}

-(BOOL) isAuthenticated {
    return self.accessToken && self.accessToken.isValid;
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if (!self.isAuthenticated) {
        UIViewController *viewController = [CSOAuthViewController viewControllerWithService:self
                                                                               successBlock:success
                                                                                 errorBlock:error];
        
        [[CSSocial viewController] presentModalViewController:viewController animated:YES];
    }
    else {
        if(self.loginSuccessBlock) self.loginSuccessBlock();
    }
}

-(void) logout {
    self.accessToken = nil;
}

-(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation
{
    return YES;
}

#pragma mark - CSOAuthService

-(NSString*) apiKey {
    NSString *consumerKey = [[CSSocial configDictionary] objectForKey:self.socialPlistApiKeyName];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Key with %@ key to CSSocial.plist", self.socialPlistApiKeyName];
    NSAssert(consumerKey, message);
    return consumerKey;
}

-(NSString*) secretKey {
    NSString *consumerSecret = [[CSSocial configDictionary] objectForKey:self.socialPlistSecretKeyName];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Secret with %@ key to CSSocial.plist", self.socialPlistSecretKeyName];
    NSAssert(consumerSecret, message);
    return consumerSecret;
}

-(NSString*) realm {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSURL*) requestTokenURL {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSURL*) accessTokenURL {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSURL*) loginURL {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSURL*) callbackURL {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString*) cancelAuthenticationKeyword {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString*) socialPlistApiKeyName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString*) socialPlistSecretKeyName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(BOOL) isCancellationURL:(NSURL*) url {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)isVerifierURL:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSString *urlString = [url absoluteString];
    *error = nil;
    
    if ([urlString rangeOfString:@"oauth_verifier"].location != NSNotFound) {
        return YES;
    }
    
    if ([self isCancellationURL:url]) {
        *error = [self oAuthErrorWithMessage:@"Cancelled"
                                        code:CSSocialErrorCodeUserCancelled];
        return NO;
    }

    return NO;
    
}





-(NSError*) oAuthErrorWithMessage:(NSString*) message code:(CSSocialServiceErrorCode) code {
    return [NSError errorWithDomain:CSSocialErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
