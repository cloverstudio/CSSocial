//
//  CSSocialRequestFacebook.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequestFacebook.h"
#import "CSSocialUserFacebook.h"
#import "FBRequestConnection.h"
#import "FBRequest.h"

///graph paths
#define kCSGraphPathMe @"me"
#define kCSGraphPathFriends @"me/friends"
#define kCSGraphPathFeed @"me/feed"
#define kCSGraphPathPhotos @"me/photos"
#define kCSGraphPathUserImage @"me/picture"

@implementation CSSocialRequestFacebook
{
    FBRequestConnection *_connection;
}

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{    
    self = [super initWithService:service parameters:parameters];
    if (self) {
        
    }
    return self;
}

-(void) start
{
    [super start];
    _connection = [FBRequestConnection startWithGraphPath:[self APIcall]
                                               parameters:[self params]
                                               HTTPMethod:[self method]
                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                   {
                       [self receivedResponse:result error:error];
                   }];
}
@end

@implementation CSSocialRequestLogin

-(NSString*) APIcall { return nil; }

-(id) method { return nil; }

@end

@implementation CSSocialRequestFacebookUser

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook userWithResponse:rawResponse];
}

-(NSString*) APIcall { return kCSGraphPathMe; }

-(id) method { return @"GET"; }

@end

@implementation CSSocialRequestFacebookFriends

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook usersWithResponse:rawResponse];
}

-(NSString*) APIcall { return kCSGraphPathFriends; }

-(id) method { return @"GET"; }

@end

@implementation CSSocialRequestFacebookFriendsPaging
@end

@implementation CSSocialRequestFacebookPostWall

-(NSString*) APIcall { return kCSGraphPathFeed; }

-(id) method  { return @"POST"; }

@end

@implementation CSSocialRequestFacebookPostPhoto

-(NSString*) APIcall { return kCSGraphPathPhotos; }

-(id) method  { return @"POST"; }

@end

@implementation CSSocialRequestFacebookGetUserImage
///TODO: test this.
-(id) parseResponse:(id)rawResponse
{
    return [UIImage imageWithData:rawResponse];
}

-(NSString*) APIcall { return kCSGraphPathUserImage; }

-(id) method  { return @"GET"; }

@end
