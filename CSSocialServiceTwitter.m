//
//  CSSocialServiceTwitter.m
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 21.6.2012..
//  Copyright (c) 2012. Clover Studio. All rights reserved.
//

#import "CSSocialServiceTwitter.h"
#import "CSConstants.h"
#import "CSSocial.h"
#import "CSSocialConstants.h"
#import "CSRequests.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "OAuth.h"
#import "SimpleKeychain.h"
#import "CSTwitterPlugin.h"
#import "CSSocialRequestTwitter.h"

#pragma mark - CSSocialServiceTwitter

@interface CSSocialServiceTwitter()

@end

@implementation CSSocialServiceTwitter
{
    CSTwitterPlugin *_plugin;

}


-(void) dealloc
{
    CS_SUPER_DEALLOC;
}

-(id) init {
    if ((self=[super init])) 
    {
        _plugin = [CSTwitterPlugin plugin];
    }
    return self;
}

-(NSOperationQueue*) operationQueue
{
    return CS_AUTORELEASE([[NSOperationQueue alloc] init]);
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    [_plugin login:success error:error];
    
}

-(BOOL) handleOpenURL:(NSURL *)url
{
    return NO;
}

-(void) logout
{
    [_plugin logout];
}

-(BOOL) isAuthenticated
{
    return [_plugin isAuthenticated];
}

-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>)parameter
{
    CSSocialRequest *request = nil;
    
    switch (parameter.requestName)
    {
        case CSRequestLogin:
            break;
        case CSRequestLogout:
            break;
        case CSRequestUser:
            //request = [CSSocialRequestTwitterUser requestWithService:nil parameters:[parameter parameters]];
            break;
        case CSRequestFriends:
            request = [CSSocialRequestTwitterFriends requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        case CSRequestPostMessage:
            request = [CSSocialRequestTwitterMessage requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        case CSRequestGetUserImage:
            request = [CSSocialRequestTwitterGetUserImage requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        default:
            break;
    }
    return request;
}


-(NSArray*) permissions {
    return nil;
}

-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock
{
    if (![self isAuthenticated]) {
        handlerBlock([self errorWithLocalizedDescription:@"Twitter not logged in. Please login before trying to use the dialog."]);
        return nil;
    }
    
    
}

@end
