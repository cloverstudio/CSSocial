//
//  CSSocialServiceGoogle.m
//  CSSocial
//
//  Created by Marko Hlebar on 3/1/13.
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

#import "CSSocialServiceGoogle.h"
#import "GTLPlusConstants.h"
#import "GPPSignIn.h"
#import "GPPShare.h"
#import "CSSocial.h"

@interface CSSocialServiceGoogle () <GPPSignInDelegate, GPPShareDelegate>
@property (nonatomic, copy) CSErrorBlock shareBlock;
@end

@implementation CSSocialServiceGoogle
{
    GPPSignIn *_session;
}

-(NSString*) clientID
{
    NSString *clientID = [[CSSocial configDictionary] objectForKey:kCSGoogleClientID];
    NSString *message = [NSString stringWithFormat:@"Add google ClientID with %@ key to CSSocial.plist", kCSGoogleClientID];
    NSAssert(clientID, message);
    return clientID;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _session = [GPPSignIn sharedInstance];
        _session.clientID = [self clientID];
        _session.scopes = @[kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe];
        _session.delegate = self;
    }
    return self;
}

-(BOOL) isAuthenticated
{
    return nil != [_session authentication];
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if ([self isAuthenticated])
    {
        [_session trySilentAuthentication];
    }
    else
    {
        [_session authenticate];
    }
}

-(void) logout
{
    [_session signOut];
}

-(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation
{
    [[GPPShare sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
    return [_session handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - GPPSignInDelegate

// The authorization has finished and is successful if |error| is |nil|.
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    if (error)
    {
        self.loginFailedBlock(error);
    }
    else
    {
        self.loginSuccessBlock();
    }
}

// Finished disconnecting user from the app.
// The operation was successful if |error| is |nil|.
- (void)didDisconnectWithError:(NSError *)error
{
    
}

- (void)finishedSharing:(BOOL)shared {
    self.shareBlock(shared ?
                    nil :
                    [self errorWithLocalizedDescription:@"Google Plus Sharing failed"]);
    self.shareBlock = nil;
}

-(id) showDialogWithMessage:(NSString *)message
                      photo:(UIImage *)photo
                    handler:(CSErrorBlock)handlerBlock
{
    self.shareBlock = handlerBlock;
    
    GPPShare *share = [GPPShare sharedInstance];
    [share setDelegate:self];
    id<GPPShareBuilder> shareBuilder = [share shareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder open];
    return shareBuilder;
}

@end
