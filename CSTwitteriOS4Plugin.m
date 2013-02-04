//
//  CSTwitteriOS4Plugin.m
//  CSSocial
//
//  Created by marko.hlebar on 11/26/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSTwitteriOS4Plugin.h"
#import "CSSocial.h"
#import "OAuth.h"

@implementation CSTwitteriOS4Plugin

-(void) authenticate
{
    TwitterDialog *dialog = [[TwitterDialog alloc] init];
    dialog.twitterOAuth = self.oAuth;
    dialog.logindelegate = self;
    [dialog show];
    CS_RELEASE(dialog);
}

-(void) logout
{
    [self resetOAuth];
    self.oAuth.oauth_token = nil;
    self.oAuth.oauth_token_secret = nil;
    self.oAuth.oauth_token_authorized = NO;

}

-(UIViewController*) presentingViewController
{
    return nil;
}

- (void)twitterDidLogin
{
    [self saveOAuth:self.oAuth];
    self.loginSuccessBlock();
}

- (void)twitterDidNotLogin:(BOOL)cancelled
{
    
    [self resetOAuth];
    self.loginFailedBlock([self errorTwitterLoginFailed]);
    self.loginFailedBlock(nil);
}

@end
