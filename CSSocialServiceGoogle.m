//
//  CSSocialServiceGoogle.m
//  CSSocial
//
//  Created by marko.hlebar on 3/1/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialServiceGoogle.h"
#import "GTLPlusConstants.h"
#import "GPPSignIn.h"
#import "GPPShare.h"

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
