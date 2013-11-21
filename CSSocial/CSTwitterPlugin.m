//
//  CSTwitterPlugin.m
//  CSSocial
//
//  Created by Marko Hlebar on 11/26/12.
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

#import "CSSocialConstants.h"
#import "CSTwitterPlugin.h"
#import "OAuth.h"
#import "CSSocial.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>

//plugins
#import "CSTwitteriOS4Plugin.h"
#import "CSTwitteriOS5Plugin.h"
#import "CSTwitteriOS6Plugin.h"

@implementation CSTwitterPlugin

///chooses the correct plugin based on iOS version, config settings and service availability and instantiates it
///@return an instance of CSTwitterPlugin
+(CSTwitterPlugin*) plugin
{
    if([SLComposeViewController class])
    {
        ///iOS 6+
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            return [CSTwitteriOS6Plugin new];
        }
    }
    
    if([TWTweetComposeViewController class])
    {
        ///iOS 5
        if([TWTweetComposeViewController canSendTweet])
        {
            return [CSTwitteriOS5Plugin new];
        }
    }
    
    ///final fallback = iOS 4
    return [CSTwitteriOS4Plugin new];
}

-(NSString*) consumerKey
{
    NSString *consumerKey = [[CSSocial configDictionary] objectForKey:kCSTwitterConsumerKey];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Key with %@ key to CSSocial.plist", kCSTwitterConsumerKey];
    NSAssert(consumerKey, message);
    return consumerKey;
}

-(NSString*) consumerSecret
{
    NSString *consumerSecret = [[CSSocial configDictionary] objectForKey:kCSTwitterConsumerSecret];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Secret with %@ key to CSSocial.plist", kCSTwitterConsumerSecret];
    NSAssert(consumerSecret, message);
    return consumerSecret;
}

-(id) init
{
    if (self = [super init])
    {
        _oAuth = [[OAuth alloc] initWithConsumerKey:self.consumerKey
                                  andConsumerSecret:self.consumerSecret];
        [self loadOAuth:_oAuth];
    }
    return self;
}

-(UIViewController*) presentingViewController
{
    return [CSSocial viewController];
}

-(void) login:(CSVoidBlock)success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if (![self isAuthenticated])
    {
        [self authenticate];
    }
    else
    {
        if(self.loginSuccessBlock) self.loginSuccessBlock();
    }
}

-(void) logout
{
    [self resetOAuth];
    self.oAuth.oauth_token = nil;
    self.oAuth.oauth_token_secret = nil;
    self.oAuth.oauth_token_authorized = NO;
    
}

-(void) authenticate
{
    ///implement me!
}

-(BOOL) isAuthenticated
{
   return self.oAuth.oauth_token_authorized;
}

-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock
{
    handlerBlock([self errorUnsupportedSDK]);
    return nil;
}

#pragma mark - OAuth

-(void) saveOAuth:(OAuth*) oAuth
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_oAuth.oauth_token forKey:kCSTwitterOAuthToken];
    [defaults setObject:_oAuth.oauth_token_secret forKey:kCSTwitterOAuthTokenSecret];
    [defaults setBool:oAuth.oauth_token_authorized forKey:kCSTwitterOAuthTokenAuthorized];
}

-(void) loadOAuth:(OAuth*) oAuth
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _oAuth.oauth_token = [defaults objectForKey:kCSTwitterOAuthToken];
    _oAuth.oauth_token_secret = [defaults objectForKey:kCSTwitterOAuthTokenSecret];
    _oAuth.oauth_token_authorized = [defaults boolForKey:kCSTwitterOAuthTokenAuthorized];
}

-(void) resetOAuth
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kCSTwitterOAuthToken];
    [defaults removeObjectForKey:kCSTwitterOAuthTokenSecret];
    [defaults removeObjectForKey:kCSTwitterOAuthTokenAuthorized];
}

#pragma mark - Errors

-(NSError*) errorWithLocalizedDescription:(NSString*) description errorCode:(NSInteger) errorCode
{
    return [NSError errorWithDomain:@"" code:errorCode userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]];
}

-(NSError*) errorWithLocalizedDescription:(NSString*) description
{
    return [self errorWithLocalizedDescription:description errorCode:0];
}

-(NSError*) errorInvalidReturnValue
{
    return [self errorWithLocalizedDescription:@"Invalid return value"];
}

-(NSError*) errorAccountNotFound
{
    return [self errorWithLocalizedDescription:@"Account not found"];
}

-(NSError*) errorUnsupportedSDK
{
    return [self errorWithLocalizedDescription:@"Unsupported SDK"];
}

-(NSError*) errorTwitterLoginFailed
{
    return [self errorWithLocalizedDescription:@"Twitter login failed" errorCode:CSSocialErrorCodeLoginFailed];
}

-(NSError*) errorTwitterUserCancelled
{
    return [self errorWithLocalizedDescription:@"Twitter user cancelled" errorCode:CSSocialErrorCodeUserCancelled];
}

@end
