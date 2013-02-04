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
#import "CSSocial.h"
#import "CSSocialRequestFacebook.h"
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


#pragma mark - CSSocialServiceFacebook

@interface CSSocialServiceFacebook  () <FBRequestDelegate, FBSessionDelegate>
-(NSArray*) permissions;
@end

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kCSFBAccessTokenKey];
    [defaults removeObjectForKey:kCSFBExpirationDateKey];

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
    NSString *appID = [[CSSocial configDictionary] objectForKey:kCSFacebookAppID];
    NSString *message = [NSString stringWithFormat:@"Add array of permissions with %@ key to CSSocial.plist", kCSFacebookAppID];
    NSAssert(appID, message);
    return appID;
}

-(NSArray*) permissions
{
    NSArray *permissions = [[CSSocial configDictionary] objectForKey:kCSFacebookPermissions];
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
    
    self.loginFailedBlock([NSError errorWithDomain:@""
                                              code:cancelled ? CSSocialErrorCodeUserCancelled : CSSocialErrorCodeLoginFailed
                                          userInfo:[NSDictionary dictionaryWithObject:@"fbDidNotLogin:"
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




