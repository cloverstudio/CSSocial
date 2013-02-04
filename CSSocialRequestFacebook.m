//
//  CSSocialRequestFacebook.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequestFacebook.h"
#import "CSSocialUserFacebook.h"

///graph paths
#define kCSGraphPathMe @"me"
#define kCSGraphPathFriends @"me/friends"
#define kCSGraphPathFeed @"me/feed"
#define kCSGraphPathPhotos @"me/photos"
#define kCSGraphPathUserImage @"me/picture"

@implementation CSSocialRequestFacebook

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{
    NSAssert([service isKindOfClass:[Facebook class]], @"Service has to be of class Facebook");
    
    self = [super initWithService:service parameters:parameters];
    if (self) {
        
    }
    return self;
}

-(void) start
{
    [super start];
    
    Facebook *facebook = (Facebook*) self.service;
    [facebook requestWithGraphPath:[self APIcall]
                         andParams:[NSMutableDictionary dictionaryWithDictionary:[self params]]
                     andHttpMethod:[self method]
                       andDelegate:self];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    self.responseBlock(self, nil, error);
    [self receivedResponse];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    self.responseBlock(self, result, nil);
    [self receivedResponse];
}
@end


@implementation CSSocialRequestLogin
-(NSString*) APIcall { return nil; }
-(id) method { return nil; }
@end



@implementation CSSocialRequestFacebookUser

- (void)request:(FBRequest *)request didLoad:(id)result
{
    self.responseBlock(self, [CSSocialUserFacebook userWithResponse:result], nil);
    [self receivedResponse];
}

-(NSString*) APIcall { return kCSGraphPathMe; }
-(id) method { return @"GET"; }
@end

@implementation CSSocialRequestFacebookFriends

- (void)request:(FBRequest *)request didLoad:(id)result
{
    self.responseBlock(self, [CSSocialUserFacebook usersWithResponse:result], nil);
    [self receivedResponse];
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

- (void)request:(FBRequest *)request didLoad:(id)result
{
    //CSLog(@"%@", result);
}

-(void) request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    if(image) self.responseBlock(self,image, nil);
    else self.responseBlock(self, nil, [NSError errorWithDomain:@""
                                                           code:0
                                                       userInfo:[NSDictionary dictionaryWithObject:@"Image is nil" forKey:NSLocalizedDescriptionKey]]);
    [self receivedResponse];
}

-(NSString*) APIcall { return kCSGraphPathUserImage; }
-(id) method  { return @"GET"; }
@end
