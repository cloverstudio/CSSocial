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
#import "FacebookSDK.h"
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

@interface CSSocialServiceFacebook ()
-(NSArray*) permissions;
@end

@implementation CSSocialServiceFacebook
{
    FBSession *_session;
}

-(void) dealloc
{
    CS_RELEASE(_session);
    CS_SUPER_DEALLOC;
}

-(id) init
{
    if ((self = [super init])) 
    {
        ///TODO: add urlSchemeSuffix to plist, also allow for appID to be nil
        ///initialize session for the first time;
        [FBSession setDefaultAppID:[self appID]];
        _session = [FBSession activeSession];
    }
    return self;
}

-(BOOL) isAuthenticated
{
    return (nil != _session && (_session.isOpen || FBSessionStateCreatedTokenLoaded == _session.state));
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{        
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if (_session.isOpen)
    {
        //session is valid, load all data here at the start of application
        self.loginSuccessBlock();
    }
    else 
    {
        [FBSession openActiveSessionWithPublishPermissions:[self permissions]
                                           defaultAudience:FBSessionDefaultAudienceEveryone
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             [self handleSession:session status:status error:error];
                                         }];
        _session = [FBSession activeSession];
    }
}

-(void) handleSession:(FBSession*) session status:(FBSessionState) status error:(NSError*) error
{
    switch (status)
    {
        case FBSessionStateOpen:
            self.loginSuccessBlock();
            break;
        case FBSessionStateClosed:
            break;
        case FBSessionStateClosedLoginFailed:
            self.loginFailedBlock(error);
            break;
        default:
            break;
    }
}

-(void) logout
{
    [_session closeAndClearTokenInformation];
    _session = nil;
    [FBSession setActiveSession:_session];
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
            request = [CSSocialRequestFacebookUser requestWithService:_session parameters:[parameter parameters]];
            break;
        case CSRequestFriends:
            request = [CSSocialRequestFacebookFriends requestWithService:_session parameters:[parameter parameters]];
            break;
        case CSRequestFriendsPaging:
            request = [CSSocialRequestFacebookFriendsPaging requestWithService:_session parameters:[parameter parameters]];
            break;
        case CSRequestPostMessage:
            request = [CSSocialRequestFacebookPostWall requestWithService:_session parameters:[parameter parameters]];
            break;
        case CSRequestPostPhoto:
            request = [CSSocialRequestFacebookPostPhoto requestWithService:_session parameters:[parameter parameters]];
            break;
        case CSRequestGetUserImage:
            request = [CSSocialRequestFacebookGetUserImage requestWithService:_session parameters:[parameter parameters]];
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
    return [_session handleOpenURL:url];
}

@end




