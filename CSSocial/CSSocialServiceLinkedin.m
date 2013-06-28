//
//  CSSocialServiceLinkedin.m
//  CSSocial
//
//  Created by marko.hlebar on 6/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialServiceLinkedin.h"
#import "OAuthLoginView.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@interface CSSocialServiceLinkedin ()
@property (nonatomic, strong) OAuthLoginView *loginViewController;
@property (nonatomic, copy) CSErrorBlock dialogHandlerBlock;
@end

@implementation CSSocialServiceLinkedin

-(id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(BOOL) isAuthenticated
{
    return self.loginViewController.accessToken != nil;
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
        NSString *nibName = @"OAuthLoginView";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = [nibName stringByAppendingString:@"~iPad"];
        }
        
        self.loginViewController = [[OAuthLoginView alloc] initWithNibName:nil bundle:nil];
        _loginViewController.apiKey = [self consumerKey];
        _loginViewController.secretkey = [self consumerSecret];
        [[CSSocial viewController] presentModalViewController:_loginViewController animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginViewDidFinish:)
                                                     name:@"loginViewDidFinish"
                                                   object:_loginViewController];
    }
    else {
        if(self.loginSuccessBlock) self.loginSuccessBlock();
    }
}

-(void) loginViewDidFinish:(NSNotification*)notification
{
	if (_loginViewController.accessToken) {
        if(self.loginSuccessBlock) self.loginSuccessBlock();
    }
    else {
        
        NSError *error = [notification userInfo][@"error"];
        if(self.loginFailedBlock) self.loginFailedBlock(error);
    }
}

-(void) logout
{
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
                                        consumer:_loginViewController.consumer
                                           token:_loginViewController.accessToken
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

@end
