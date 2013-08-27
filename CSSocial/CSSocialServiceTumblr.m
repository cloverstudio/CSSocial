//
//  CSSocialServiceTumblr.m
//  CSSocial
//
//  Created by marko.hlebar on 7/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialServiceTumblr.h"

@implementation CSSocialServiceTumblr

#pragma mark - CSOAuthService

-(NSString*) apiKey {
    return @"UGbXbt64JeKPTLAjUmY0X2Oe3MSZHJH24AGFXkgET81Jm8INy2";
}

-(NSString*) secretKey {
    return @"OyEJYhoTpFV1NPbTSFmE3r3awfQMXEOigI85YeAc4Jk3iF2qiV";
}

-(NSString*) realm {
    return @"http://api.tumblr.com/";
}

-(NSURL*) requestTokenURL {
    return [NSURL URLWithString:@"http://www.tumblr.com/oauth/request_token"];
}

-(NSURL*) accessTokenURL {
    return [NSURL URLWithString:@"http://www.tumblr.com/oauth/access_token"];
}

-(NSURL*) loginURL {
    return [NSURL URLWithString:@"http://www.tumblr.com/oauth/authorize"];
}

-(NSURL*) callbackURL {
    return [NSURL URLWithString:@"http://www.tumblr.com"];
}

///OK       https://www.tumblr.com/?oauth_token=n7Qt1CzEbeeCtDgUBR6QQPOMTcDZWcXpGwxLJFAXF2ZwI00OFl&oauth_verifier=CDitI5m4hT8gwJcFE1ad2xC6bj4DJv4W0fQwsfm0wuxHNeho2Z
///Cancel   http://www.tumblr.com/dashboard

-(NSString*) cancelAuthenticationKeyword {
    return @"dashboard";
}

-(NSString*) socialPlistApiKeyName {
    return kCSTumblrConsumerKey;
}

-(NSString*) socialPlistSecretKeyName {
    return kCSTumblrConsumerSecret;
}

-(BOOL) isCancellationURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:self.cancelAuthenticationKeyword].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
