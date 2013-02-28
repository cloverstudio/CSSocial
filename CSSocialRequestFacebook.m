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
#import "FBURLConnection.h"

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
    id _connection;
}

+(CSSocialRequestFacebook*) requestWithApiCall:(NSString*) apiCall
                                    httpMethod:(NSString*) method
                                    parameters:(NSDictionary*) parameters
                                    permission:(NSString*) permission
{
    return CS_AUTORELEASE([[self alloc] initWithService:nil
                                                apiCall:apiCall
                                             httpMethod:method
                                             parameters:parameters
                                             permission:permission]);
}

-(id) initWithService:(id) service
              apiCall:(NSString*) apiCall
           httpMethod:(NSString*) method
           parameters:(NSDictionary*) parameters
           permission:(NSString*) permission
{
    self = [super initWithService:service parameters:parameters];
    if (self)
    {
        self.APIcall = apiCall;
        self.method = method;
        self.permission = permission;
    }
    return self;
    
}

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{    
    self = [self initWithService:service
                         apiCall:nil
                      httpMethod:nil
                      parameters:parameters
                      permission:nil];
    if (self)
    {
        
    }
    return self;
}

-(void) makeRequest
{
    _connection = [FBRequestConnection startWithGraphPath:[self APIcall]
                                               parameters:[self params]
                                               HTTPMethod:[self method]
                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                   {
                       [self receivedResponse:result error:error];
                   }];
}

@end

@implementation CSSocialRequestFacebookUser

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook userWithResponse:rawResponse];
}

-(NSString*) APIcall { return kCSGraphPathMe; }

-(id) method { return @"GET"; }

-(NSString*) permission {return @"user_about_me";}

@end

@implementation CSSocialRequestFacebookFriends

-(id) parseResponse:(id)rawResponse
{
    return [CSSocialUserFacebook usersWithResponse:rawResponse];
}

-(NSString*) APIcall { return kCSGraphPathFriends; }

-(id) method { return @"GET"; }

-(NSString*) permission {return @"user_about_me";}

@end

@implementation CSSocialRequestFacebookFriendsPaging
@end

@implementation CSSocialRequestFacebookPostWall

-(NSString*) APIcall { return kCSGraphPathFeed; }

-(id) method  { return @"POST"; }

-(NSString*) permission {return @"publish_stream";}

@end

@implementation CSSocialRequestFacebookPostPhoto

-(NSString*) APIcall { return kCSGraphPathPhotos; }

-(id) method  { return @"POST"; }

-(NSString*) permission {return @"publish_stream";}

@end

@implementation CSSocialRequestFacebookGetUserImage
{
    FBRequestConnection *_connection;
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

-(NSString*) APIcall { return kCSGraphPathMe; }

-(id) method  { return @"GET"; }

-(NSString*) permission {return @"user_photos";}

@end
