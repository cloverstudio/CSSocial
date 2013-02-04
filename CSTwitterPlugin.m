//
//  CSTwitterPlugin.m
//  CSSocial
//
//  Created by marko.hlebar on 11/26/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "SimpleKeychain.h"
#import "CSSocialConstants.h"
#import "CSTwitterPlugin.h"
#import "OAuth.h"

@implementation CSTwitterPlugin

///chooses the correct plugin based on iOS version and config settings and instantiates it
///@return an instance of CSTwitterPlugin
+(CSTwitterPlugin*) plugin
{
    CSTwitterPlugin *plugin = nil;
    
    if(NO)//NSClassFromString(@"SLComposeViewController"))
    {
        ///iOS 6
        
    }
    else if(NO)//NSClassFromString(@"TWTweetComposeViewController"))
    {
        ///iOS 5
        plugin = [[NSClassFromString(@"CSTwitteriOS5Plugin") alloc] init];
    }
    else
    {
        ///iOS 4
        plugin = [[NSClassFromString(@"CSTwitteriOS4Plugin") alloc] init];
    }
    return plugin;
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
        self.loginSuccessBlock();
    }
}

-(void) authenticate
{
    ///implement me!
}

-(BOOL) isAuthenticated
{
   return self.oAuth.oauth_token_authorized;
}

#pragma mark - OAuth

-(void) saveOAuth:(OAuth*) oAuth
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                _oAuth.oauth_token, kCSTwitterOAuthToken,
                                _oAuth.oauth_token_secret, kCSTwitterOAuthTokenSecret,
                                NSStringFromBOOL(oAuth.oauth_token_authorized), kCSTwitterOAuthTokenAuthorized,
                                nil];
    [SimpleKeychain save:kCSTwitterOAuthDictionary data:dictionary];
}

-(void) loadOAuth:(OAuth*) oAuth
{
    NSDictionary *dictionary = [SimpleKeychain load:kCSTwitterOAuthDictionary];
    _oAuth.oauth_token = [dictionary objectForKey:kCSTwitterOAuthToken];
    _oAuth.oauth_token_secret = [dictionary objectForKey:kCSTwitterOAuthTokenSecret];
    _oAuth.oauth_token_authorized = [[dictionary objectForKey:kCSTwitterOAuthTokenAuthorized] boolValue];
}

-(void) resetOAuth
{
    [SimpleKeychain delete:kCSTwitterOAuthDictionary];
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
