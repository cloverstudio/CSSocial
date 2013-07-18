//
//  CSSocialServiceLinkedin.m
//  CSSocial
//
//  Created by marko.hlebar on 6/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialServiceLinkedin.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAConsumer.h"
#import "CSOAuthViewController.h"
#import "JSONKit.h"

@interface CSSocialServiceLinkedin ()
@property (nonatomic, copy) CSErrorBlock dialogHandlerBlock;

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *accessToken;
@end

@implementation CSSocialServiceLinkedin

-(id) init
{
    self = [super init];
    if (self) {
        self.consumer = [[OAConsumer alloc] initWithKey:self.consumerKey
                                                 secret:self.consumerSecret
                                                  realm:self.realm];
    }
    return self;
}

-(BOOL) isAuthenticated
{
    return self.accessToken && self.accessToken.isValid;
}

-(NSString*) consumerKey
{
    NSString *consumerKey = [[CSSocial configDictionary] objectForKey:kCSLinkedinConsumerKey];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Key with %@ key to CSSocial.plist", kCSLinkedinConsumerKey];
    NSAssert(consumerKey, message);
    return consumerKey;
}

-(NSString*) consumerSecret
{
    NSString *consumerSecret = [[CSSocial configDictionary] objectForKey:kCSLinkedinConsumerSecret];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Secret with %@ key to CSSocial.plist", kCSLinkedinConsumerSecret];
    NSAssert(consumerSecret, message);
    return consumerSecret;
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
}

-(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation
{
    return YES;
}

#pragma mark - GPPSignInDelegate

-(id) showDialogWithMessage:(NSString *)message
                        url:(NSURL *)url
                      photo:(UIImage *)photo
                    handler:(CSErrorBlock)handlerBlock {
    self.dialogHandlerBlock = handlerBlock;
    [self login:^{
        CSLog(@"CSSocial Linkedin logged in, trying to post to linkedin");
        NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
        OAMutableURLRequest *request =
        [[OAMutableURLRequest alloc] initWithURL:url
                                        consumer:self.consumer
                                           token:self.accessToken
                                        callback:nil
                               signatureProvider:nil];
        
        NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [[NSDictionary alloc]
                                 initWithObjectsAndKeys:
                                 @"anyone",@"code",nil], @"visibility",
                                message, @"comment", nil];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *updateString = [update JSONString];
        
        [request setHTTPBodyWithString:updateString];
        [request setHTTPMethod:@"POST"];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request
                             delegate:self
                    didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                      didFailSelector:@selector(postUpdateApiCallResult:didFail:)];
    } error:^(NSError *error) {
        self.dialogHandlerBlock(error);
    }];
    
    return nil;
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data {
    self.dialogHandlerBlock(nil);
    CSLog(@"CSSocial Linkedin post success");
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error {
    NSString *errorString = [[NSString alloc] initWithBytes:[error bytes] length:error.length encoding:NSUTF8StringEncoding];
    CSLog(@"CSSocial Linkedin post fail: %@", errorString);
    
    self.dialogHandlerBlock([NSError errorWithDomain:nil
                                                code:0
                                            userInfo:@{NSLocalizedDescriptionKey: errorString}]);
}

#pragma mark - CSOAuthService

-(NSString*) apiKey {
    return [self consumerKey];
}

-(NSString*) secretKey {
    return [self consumerSecret];
}

-(NSString*) realm {
    return @"http://api.linkedin.com/";
}

-(NSURL*) requestTokenURL {
    return [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/requestToken"];
}

-(NSURL*) accessTokenURL {
    return [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/accessToken"];
}

-(NSURL*) loginURL {
    return [NSURL URLWithString:@"https://www.linkedin.com/uas/oauth/authorize"];
}

-(NSURL*) callbackURL {
    return [NSURL URLWithString:@"hdlinked://linkedin/oauth"];
}

@end
