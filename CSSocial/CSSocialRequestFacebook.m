//
//  CSSocialRequestFacebook.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequestFacebook.h"
#import "CSSocialUserFacebook.h"
#import "External/Facebook/FBRequestConnection.h"
#import "External/Facebook/FBRequest.h"
#import "External/Facebook/FBURLConnection.h"

///graph paths
#define kCSFacebookURL @"https://graph.facebook.com"
#define kCSGraphPathMe @"me"
#define kCSGraphPathFriends @"me/friends"
#define kCSGraphPathFeed @"me/feed"
#define kCSGraphPathPhotos @"me/photos"
#define kCSGraphPathUserImage @"me/picture"

@implementation CSSocialRequestFacebook
///some instances use FBRequestConnection, whereas some use NSURLConnection
{
    FBRequestConnection *_connection;
    FBRequest *_request;
}

+(CSSocialRequestFacebook*) requestWithApiCall:(NSString*) apiCall
                                    httpMethod:(NSString*) method
                                    parameters:(NSDictionary*) parameters
                                    permissions:(NSArray *)permissions
{
    return CS_AUTORELEASE([[self alloc] initWithService:nil
                                                apiCall:apiCall
                                             httpMethod:method
                                             parameters:parameters
                                             permissions:permissions]);
}

-(id) initWithService:(id) service
              apiCall:(NSString*) apiCall
           httpMethod:(NSString*) method
           parameters:(NSDictionary*) parameters
           permissions:(NSArray*) permissions
{
    self = [super initWithService:service parameters:parameters];
    if (self)
    {
        self.APIcall = apiCall;
        self.method = method;
        self.permissions = permissions;
    }
    return self;
    
}

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{    
    self = [self initWithService:service
                         apiCall:nil
                      httpMethod:nil
                      parameters:parameters
                      permissions:nil];
    if (self)
    {
        
    }
    return self;
}

-(void) makeRequest
{
    __block CSSocialRequestFacebook *this = self;
    FBRequest *request = [FBRequest requestWithGraphPath:[self APIcall]
                                              parameters:[self params]
                                              HTTPMethod:[self method]];
    _connection = [[FBRequestConnection alloc] initWithTimeout:30];
    [_connection addRequest:request
          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
              [this receivedResponse:result error:error];
          }];
    [_connection start];
}

@end

@implementation CSSocialRequestFacebookUser

-(id) initWithService:(id)service parameters:(NSDictionary *)parameters {
    return [self initWithService:service
                         apiCall:kCSGraphPathMe
                      httpMethod:@"GET"
                      parameters:parameters
                     permissions:@[@"user_about_me"]];
}

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook userWithResponse:rawResponse];
}

@end

@implementation CSSocialRequestFacebookFriends

-(id) initWithService:(id)service parameters:(NSDictionary *)parameters {
    return [self initWithService:service
                         apiCall:kCSGraphPathFriends
                      httpMethod:@"GET"
                      parameters:parameters
                     permissions:@[@"user_about_me"]];
}

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook usersWithResponse:rawResponse];
}

@end

@implementation CSSocialRequestFacebookFriendsPaging
@end

@implementation CSSocialRequestFacebookPostWall

-(id) initWithService:(id)service parameters:(NSDictionary *)parameters {
    return [self initWithService:service
                         apiCall:kCSGraphPathFeed
                      httpMethod:@"POST"
                      parameters:parameters
                     permissions:@[@"publish_stream"]];
}

@end

@implementation CSSocialRequestFacebookPostPhoto

-(id) initWithService:(id)service parameters:(NSDictionary *)parameters {
    return [self initWithService:service
                         apiCall:kCSGraphPathPhotos
                      httpMethod:@"POST"
                      parameters:parameters
                     permissions:@[@"publish_stream"]];
}

@end

@implementation CSSocialRequestFacebookGetUserImage
{
    FBRequestConnection *_connection;
}

-(id) initWithService:(id)service parameters:(NSDictionary *)parameters {
    return [self initWithService:service
                         apiCall:kCSGraphPathMe
                      httpMethod:@"GET"
                      parameters:parameters
                     permissions:@[@"user_photos"]];
}

-(void) makeRequest
{
    _connection = [FBRequestConnection startWithGraphPath:[self APIcall]
                                               parameters:[self params]
                                               HTTPMethod:[self method]
                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                   {
                       
                       if (error)
                       {
                           [self receivedResponse:result error:error];
                           return;
                       }
                       
                       FBGraphObject *graphObject = (FBGraphObject*) result;
                       NSMutableDictionary *dict = [graphObject objectForKey:@"picture"];
                       NSURL *url = [NSURL URLWithString:dict[@"data"][@"url"]];
                       
                       ///using synchronous request here because we are already on NSOperationQueue
                       NSURLResponse *response = nil;
                       NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                                            returningResponse:&response
                                                                        error:&error];
                       [self receivedResponse:data error:error];
                   }];
}

-(id) parseResponse:(id)rawResponse
{
    return [UIImage imageWithData:rawResponse];
}

@end
