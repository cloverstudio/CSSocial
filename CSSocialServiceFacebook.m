//
//  CSSocialServiceFacebook.m
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSSocialServiceFacebook.h"
#import "CSSocialConstants.h"
#import "CSSocialUser.h"
#import "CSSocialParameter.h"
#import "CSFacebookParameter.h"
#import "Facebook.h"
//#import "FBRequest.h"

#define kFBAppID @"490866077597155"

/*
 FACEBOOK PERMISSIONS LIST:
 user_about_me              friends_about_me
 user_activities            friends_activities
 user_birthday              friends_birthday
 user_checkins              friends_checkins
 user_education_history     friends_education_history
 user_events                friends_events
 user_groups                friends_groups
 user_hometown              friends_hometown
 user_interests             friends_interests
 user_likes                 friends_likes
 user_locations             friends_locations
 user_notes                 friends_notes
 user_photos                friends_photos
 user_questions             friends_questions
 user_relationships         friends_relationships
 user_relationship_details  friends_relationship_details
 user_religion_politics     friends_religion_politics
 user_status                friends_status
 
 FACEBOOK EXTENDED PERMISSIONS LIST: (user can always disable, don't rely on these permissions)
 read_friendlists
 read_insights
 read_mailbox
 read_requests
 read_stream
 xmpp_login
 create_event
 manage_friendlists
 manage_notifications
 user_online_presence
 friends_online_presence
 publish_checkins
 publish_stream
 rsvp_event
 
 FACEBOOK OPENGRAPH PERMISSIONS LIST:
 publish_actions                N/A
 user_actions.music             friends_actions.music
 user_actions.news              friends_actions.news
 user_actions.video             friends_actions.video
 user_actions:APP_NAMESPACE     friends_actions:APP_NAMESPACE
 user_games_activity            friends_games_activity
 
 FACEBOOK PAGE PERMISSIONS LIST:
 manage_pages
 */

#define kCSFBAccessTokenKey @"FBAccessTokenKey"
#define kCSFBExpirationDateKey @"FBExpirationDateKey"

///graph paths
#define kCSGraphPathMe @"me"
#define kCSGraphPathFriends @"me/friends"
#define kCSGraphPathFeed @"me/feed"
#define kCSGraphPathPhotos @"me/photos"
#define kCSGraphPathUserImage @"me/picture"

#pragma mark - Custom User

@interface CSSocialUserFacebook : CSSocialUser
@end

@implementation CSSocialUserFacebook
-(id) initWithResponse:(id) response
{
    self = [super init];
    if (self) 
    {
        if ([response isKindOfClass:[NSDictionary class]]) 
        {
            CSLog(@"%@", response);
            self.name = [response objectForKey:@"name"];
            self.firstName = [response objectForKey:@"first_name"];
            self.lastName = [response objectForKey:@"last_name"];
            self.userName = [response objectForKey:@"username"];
            self.location = [response objectForKey:@"location"];
            self.gender = [response objectForKey:@"gender"];
            self.ID = [response objectForKey:@"id"];
            self.pageURL = [response objectForKey:@"link"];
        }
    }
    return self;
}
@end

#pragma mark - Custom Requests

@interface CSSocialRequestFacebook : CSSocialRequest <FBRequestDelegate>
@end

@implementation CSSocialRequestFacebook

-(id) initWithService:(id) service parameters:(NSDictionary*) parameters
{
    NSAssert([service isKindOfClass:[Facebook class]], @"Service has to be of class Facebook");
    
    self = [super initWithService:service parameters:parameters];
    if (self) {
        Facebook *facebook = (Facebook*) service;
        [facebook requestWithGraphPath:[self APIcall]
                             andParams:[NSMutableDictionary dictionaryWithDictionary:[self params]] 
                         andHttpMethod:[self method]
                           andDelegate:self];
    }
    return self;
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

///login
///this is a special case that doesn't call for APICall and method it is just a dummy class
@interface CSSocialRequestLogin : CSSocialRequestFacebook
@end

@implementation CSSocialRequestLogin
-(NSString*) APIcall { return nil; }
-(id) method { return nil; }
@end


///user
@interface CSSocialRequestFacebookUser : CSSocialRequestFacebook
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

///friends
@interface CSSocialRequestFacebookFriends : CSSocialRequestFacebook
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

///friends paging
@interface CSSocialRequestFacebookFriendsPaging : CSSocialRequestFacebookFriends
@end

@implementation CSSocialRequestFacebookFriendsPaging
@end

///post wall
@interface CSSocialRequestFacebookPostWall : CSSocialRequestFacebook
@end
@implementation CSSocialRequestFacebookPostWall
-(NSString*) APIcall { return kCSGraphPathFeed; }
-(id) method  { return @"POST"; }
@end

///post photo
@interface CSSocialRequestFacebookPostPhoto : CSSocialRequestFacebook
@end
@implementation CSSocialRequestFacebookPostPhoto
-(NSString*) APIcall { return kCSGraphPathPhotos; }
-(id) method  { return @"POST"; }
@end

///get picture
@interface CSSocialRequestFacebookGetUserImage : CSSocialRequestFacebook
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


@interface CSSocialServiceFacebook  () <CSSocialService, FBRequestDelegate, FBSessionDelegate>
-(NSDictionary*) permissions;
@end

#pragma mark - CSSocialServiceFacebook

@implementation CSSocialServiceFacebook
{
    Facebook *_facebook;
}

-(void) dealloc
{
    CS_RELEASE(_facebook);
    CS_SUPER_DEALLOC;
}

-(id) init
{
    if ((self = [super init])) 
    {
        _facebook = [[Facebook alloc] initWithAppId:[self appID] andDelegate:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:kCSFBAccessTokenKey] 
            && [defaults objectForKey:kCSFBExpirationDateKey]) {
            _facebook.accessToken = [defaults objectForKey:kCSFBAccessTokenKey];
            _facebook.expirationDate = [defaults objectForKey:kCSFBExpirationDateKey];
        }
    }
    return self;
}

-(BOOL) isAuthenticated
{
    return _facebook.isSessionValid;
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    [_facebook extendAccessTokenIfNeeded];
    
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if ([self isAuthenticated]) 
    {
        //session is valid, load all data here at the start of application
        self.loginSuccessBlock();
    }
    else 
    {
        //[_facebook authorize:[self permissions] useSSO:NO];
        [_facebook authorize:[self permissions]];
    }
}

-(void) logout
{
    [_facebook logout:self];
}

-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>) parameter
{
    CSSocialRequest *request = nil;
    
    switch (parameter.requestName) {
        case CSRequestLogin:
            break;
        case CSRequestLogout:
            break;
        case CSRequestUser:
            request = [CSSocialRequestFacebookUser requestWithService:_facebook parameters:[parameter parameters]];
            break;
        case CSRequestFriends:
            request = [CSSocialRequestFacebookFriends requestWithService:_facebook parameters:[parameter parameters]];
            break;
        case CSRequestFriendsPaging:
            request = [CSSocialRequestFacebookFriendsPaging requestWithService:_facebook parameters:[parameter parameters]];
            break;
        case CSRequestPostMessage:
            request = [CSSocialRequestFacebookPostWall requestWithService:_facebook parameters:[parameter parameters]];
            break;
        case CSRequestPostPhoto:
            request = [CSSocialRequestFacebookPostPhoto requestWithService:_facebook parameters:[parameter parameters]];
            break;
        case CSRequestGetUserImage:
            request = [CSSocialRequestFacebookGetUserImage requestWithService:_facebook parameters:[parameter parameters]];
            break;
        default:
            break;
    }

    return request;
}

-(NSString*) appID
{
    NSString *appID = [[self configDictionary] objectForKey:kCSFacebookAppID];
    NSString *message = [NSString stringWithFormat:@"Add array of permissions with %@ key to CSSocial.plist", kCSFacebookAppID];
    NSAssert(appID, message);
    return appID;
}

-(NSArray*) permissions
{
    NSArray *permissions = [[self configDictionary] objectForKey:kCSFacebookPermissions];
    NSString *message = [NSString stringWithFormat:@"Add array of permissions with %@ key to CSSocial.plist", kCSFacebookPermissions];
    NSAssert(permissions, message);
    return permissions;
}

-(BOOL) handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url];
}

#pragma mark Private

#pragma mark FBSessionDelegate

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:kCSFBAccessTokenKey];
    [defaults setObject:[_facebook expirationDate] forKey:kCSFBExpirationDateKey];
    [defaults synchronize];
    
    self.loginSuccessBlock();
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kCSFBAccessTokenKey];
    [defaults removeObjectForKey:kCSFBExpirationDateKey];
    [defaults synchronize];
    
    self.loginFailedBlock([NSError errorWithDomain:@"" code:0 userInfo:
                           [NSDictionary dictionaryWithObject:@"fbDidNotLogin:"
                                                       forKey:NSLocalizedDescriptionKey]]);
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:kCSFBAccessTokenKey];
    [defaults setObject:expiresAt forKey:kCSFBExpirationDateKey];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    //self.logoutBlock([self response:kCSSocialResponseOK]);
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    //self.logoutBlock([self response:kCSSocialResponseOK]);
}

@end




