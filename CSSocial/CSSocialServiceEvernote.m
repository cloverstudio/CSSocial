//
//  CSSocialServiceEvernote.m
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialServiceEvernote.h"

@implementation CSSocialServiceEvernote
{
    NSString *_evernoteHost;
}
#pragma mark - CSOAuthService

-(id) init {
    self = [super init];
    if (self) {
        self.production = NO;
    }
    return self;
}

-(void) setProduction:(BOOL)production {
    _production = production;
    _evernoteHost = _production ? @"www.evernote.com" : @"sandbox.evernote.com";
}

-(NSString*) apiKey {
    return @"markohlebar";
}

-(NSString*) secretKey {
    return @"013bd6ee1aca7f1d";
}

-(NSString*) realm {
    return @"https://www.evernote.com";
}

-(NSURL*) requestTokenURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/oauth", _evernoteHost]];
}

-(NSURL*) accessTokenURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/oauth", _evernoteHost]];
}

-(NSURL*) loginURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/OAuth.action", _evernoteHost]];
}

-(NSURL*) callbackURL {
    return [NSURL URLWithString:@"http://evernote.com/"];
}

///OK       https://www.tumblr.com/?oauth_token=n7Qt1CzEbeeCtDgUBR6QQPOMTcDZWcXpGwxLJFAXF2ZwI00OFl&oauth_verifier=CDitI5m4hT8gwJcFE1ad2xC6bj4DJv4W0fQwsfm0wuxHNeho2Z
///Cancel   http://www.tumblr.com/dashboard

-(NSString*) cancelAuthenticationKeyword {
    return @"dashboard";
}

-(NSString*) socialPlistApiKeyName {
    return kCSEvernoteConsumerKey;
}

-(NSString*) socialPlistSecretKeyName {
    return kCSEvernoteConsumerSecret;
}

-(BOOL) isCancellationURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:[self.callbackURL absoluteString]].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
