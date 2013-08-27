//
//  CSOAuthViewController.m
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSOAuthViewController.h"
#import "CSSocialService.h"
#import "OAMutableURLRequest.h"
#import "OARequestParameter.h"
#import "OADataFetcher+Blocks.h"

@interface CSOAuthViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) id<CSOAuthService> service;
//@property (nonatomic, strong) OAToken *requestToken;
//@property (nonatomic, strong) OAToken *accessToken;
//@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, copy) CSVoidBlock successBlock;
@property (nonatomic, copy) CSErrorBlock errorBlock;
@end

@implementation CSOAuthViewController

+(id) viewControllerWithService:(id<CSOAuthService>) service
                   successBlock:(CSVoidBlock) successBlock
                     errorBlock:(CSErrorBlock) errorBlock {
    return [[self alloc] initWithService:service
                            successBlock:successBlock
                              errorBlock:errorBlock];
}

-(id) initWithService:(id<CSOAuthService>) service
         successBlock:(CSVoidBlock) successBlock
           errorBlock:(CSErrorBlock) errorBlock {
    self = [super init];
    if (self) {
        self.successBlock = successBlock;
        self.errorBlock = errorBlock;
        self.service = service;
    }
    return self;
}


-(void) loadView {
    self.webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    _webView.delegate = self;
    self.view = _webView;
}

-(void) viewDidLoad {
    [self requestTokenFromProvider];
}

//
// OAuth step 1a:
//
// The first step in the the OAuth process to make a request for a "request token".
// Yes it's confusing that the work request is mentioned twice like that, but it is whats happening.
//
// When this method is called it means we have successfully received a request token.
// We then show a webView that sends the user to the LinkedIn login page.
// The request token is added as a parameter to the url of the login page.
// LinkedIn reads the token on their end to know which app the user is granting access to.
//
- (void)requestTokenFromProvider {
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:_service.requestTokenURL
                                    consumer:_service.consumer
                                       token:nil
                                    callback:[_service.callbackURL absoluteString]
                           signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    
    OARequestParameter *nameParam = [[OARequestParameter alloc] initWithName:@"scope"
                                                                       value:@"r_basicprofile+rw_nus"];
    NSArray *params = [NSArray arrayWithObjects:nameParam, nil];
    [request setParameters:params];
    OARequestParameter *scopeParameter = [OARequestParameter requestParameter:@"scope" value:@"r_fullprofile rw_nus"];
    
    [request setParameters:[NSArray arrayWithObject:scopeParameter]];
    
    __block CSOAuthViewController *this = self;
    
    [OADataFetcher fetchDataWithRequest:request
                            ticketBlock:^(OAServiceTicket *ticket, id responseData, NSError *error) {
                                
                                NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                                
                                if (!error) {
                                    if (ticket.didSucceed) {
                                        NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                                                       encoding:NSUTF8StringEncoding];
                                        _service.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
                                        [this loadOAuthToken];
                                    }
                                    else {
                                        NSError *error = [NSError errorWithDomain:CSSocialErrorDomain
                                                                             code:0
                                                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Ticket Error", NULL)}];
                                        [this notifyAndDismissWithError:error];
                                    }
                                }
                                else {
                                    [this notifyAndDismissWithError:error];
                                }
                            }];
}

//
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.
// They type username/password and this is how they permit us to access their data
// We use a UIWebView for this.
//
// Sending the token information is required, but in this one case OAuth requires us
// to send URL query parameters instead of putting the token in the HTTP Authorization
// header as we do in all other cases.
//

-(void) loadOAuthToken {
    NSString *userLoginURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@",
                                       [_service.loginURL absoluteString], _service.requestToken.key];
    
    NSURL *userLoginURL = [NSURL URLWithString:userLoginURLWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL: userLoginURL];
    [_webView loadRequest:request];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
    CSLog(@"CSOAuthViewController webView url: %@", url);
    NSError *error = nil;
    BOOL isVerifierURL = [_service isVerifierURL:url error:&error];
    if (isVerifierURL) {
        if (!error) {
            [_service.requestToken setVerifierWithUrl:url];
            [self requestAccessToken];
            
            ///we don't need any more load requests from here on.
            return NO;
        }
    }
    
    if (error) {
        [self notifyAndDismissWithError:error];
    }
    
    return YES;
}

-(void) requestAccessToken {

    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:_service.accessTokenURL
                                     consumer:_service.consumer
                                        token:_service.requestToken
                                     callback:nil
                            signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    
    __block CSOAuthViewController *this = self;
    
    [OADataFetcher fetchDataWithRequest:request
                            ticketBlock:^(OAServiceTicket *ticket, id responseData, NSError *error) {
                                if (!error) {
                                    NSString *responseBody = [[NSString alloc] initWithData:responseData
                                                                                   encoding:NSUTF8StringEncoding];
                                    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
                                    if (!problem ) {
                                        
                                  
                                        OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
                                        [_service setAccessToken: accessToken];
                                        
                                        [this notifyAndDismissWithError:nil];
                                    }
                                    else {
                                        [this notifyAndDismissWithError:[self oAuthErrorWithMessage:@"Request access token failed."
                                                                                               code:CSSocialErrorCodeLoginFailed]];
                                    }
                                    
                                }
                                else {
                                    [this notifyAndDismissWithError:error];
                                }
                            }];
}

-(NSError*) oAuthErrorWithMessage:(NSString*) message code:(CSSocialServiceErrorCode) code {
    return [NSError errorWithDomain:CSSocialErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey : message}];
}

-(void) notifyAndDismissWithError:(NSError*) error {

    if (error) {
        if (_errorBlock) {
            _errorBlock(error);
        }
    }
    else {
        if (_successBlock) {
            _successBlock();
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
