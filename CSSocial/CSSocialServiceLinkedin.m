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
@end

@implementation CSSocialServiceLinkedin

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
    
    return _loginViewController;
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

//OK        hdlinked://linkedin/oauth?oauth_token=<token value>&oauth_verifier=63600
//Cancel    hdlinked://linkedin/oauth?user_refused

-(NSString*) cancelAuthenticationKeyword {
    return @"user_refused";
}

-(NSString*) socialPlistApiKeyName {
    return kCSLinkedinConsumerKey;
}

-(NSString*) socialPlistSecretKeyName {
    return kCSLinkedinConsumerSecret;
}

-(BOOL) isCancellationURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:self.cancelAuthenticationKeyword].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
