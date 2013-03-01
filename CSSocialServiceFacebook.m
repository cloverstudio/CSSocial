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
#import "CSSocial.h"
#import "CSSocialRequestFacebook.h"
#import "FacebookSDK.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

#define kFBAppID @"490866077597155"

/*
 FACEBOOK READ PERMISSIONS
 user_about_me                  friends_about_me                user_activities
 friends_activities             user_birthday                   friends_birthday
 user_checkins                  friends_checkins                user_education_history
 friends_education_history      user_events                     friends_events
 user_groups                    friends_groups                  user_hometown
 friends_hometown               user_interests                  friends_interests
 user_likes                     friends_likes                   user_notes
 friends_notes                  user_online_presence            friends_online_presence
 user_interests                 friends_interests               user_likes
 friends_likes                  user_notes                      friends_notes
 user_online_presence           friends_online_presence         user_religion_politics
 friends_religion_politics      user_status                     friends_status
 user_subscriptions             friends_subscriptions           user_videos
 friends_videos                 user_website                    friends_website
 user_work_history              friends_work_history            read_friendlists
 read_mailbox                   read_requests                   read_stream
 read_insights                  xmpp_login
 
 FACEBOOK PUBLISH PERMISSIONS
 publish_actions                publish_stream                  publish_checkins
 ads_management                 create_event                    rsvp_event
 manage_friendlists             manage_notifications            manage_pages
 */

#define kCSFBAccessTokenKey @"FBAccessTokenKey"
#define kCSFBExpirationDateKey @"FBExpirationDateKey"

///Get permissions here https://developers.facebook.com/docs/howtos/ios-6/
#define kCSFBAllReadPermissionsArray [NSArray arrayWithObjects:\
@"user_about_me",                  @"friends_about_me",                @"user_activities",\
@"friends_activities",             @"user_birthday",                   @"friends_birthday",\
@"user_checkins",                  @"friends_checkins",                @"user_education_history",\
@"friends_education_history",      @"user_events",                     @"friends_events",\
@"user_groups",                    @"friends_groups",                  @"user_hometown",\
@"friends_hometown",               @"user_interests",                  @"friends_interests",\
@"user_likes",                     @"friends_likes",                   @"user_notes",\
@"friends_notes",                  @"user_online_presence",            @"friends_online_presence",\
@"user_interests",                 @"friends_interests",               @"user_likes",\
@"friends_likes",                  @"user_notes",                      @"friends_notes",\
@"user_online_presence",           @"friends_online_presence",         @"user_religion_politics",\
@"friends_religion_politics",      @"user_status",                     @"friends_status",\
@"user_subscriptions",             @"friends_subscriptions",           @"user_videos",\
@"friends_videos",                 @"user_website",                    @"friends_website",\
@"user_work_history",              @"friends_work_history",            @"read_friendlists",\
@"read_mailbox",                   @"read_requests",                   @"read_stream",\
@"read_insights",                  @"xmpp_login",                      nil]

#define kCSFBAllPublishPermissionsArray [NSArray arrayWithObjects:\
@"publish_actions",                @"publish_stream",                  @"publish_checkins",\
@"ads_management",                 @"create_event",                    @"rsvp_event",\
@"manage_friendlists",             @"manage_notifications",            @"manage_pages",\
nil]

#pragma mark - CSSocialServiceFacebook

@interface CSSocialServiceFacebook ()
-(NSArray*) readPermissions;
-(NSArray*) publishPermissions;
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
        self.loginSuccessBlock();
    }
    else 
    {
        [FBSession openActiveSessionWithReadPermissions:[self readPermissions]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
        {
            ///session is updated and returns a new session object here
            [self handleSession:session status:status error:error];
        }];        
    }
    _session = [FBSession activeSession];

}

-(void) handleSession:(FBSession*) session status:(FBSessionState) status error:(NSError*) error
{
    _session = session;
    
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

-(NSArray*) readPermissions
{
    NSArray *permissions = [[CSSocial configDictionary] objectForKey:kCSFacebookPermissionsRead];
    NSString *message = [NSString stringWithFormat:@"Add array of permissions with %@ key to CSSocial.plist", kCSFacebookPermissionsRead];
    NSAssert(permissions, message);
    return permissions;
}

-(NSArray*) publishPermissions
{
    NSArray *permissions = [[CSSocial configDictionary] objectForKey:kCSFacebookPermissionsPublish];
    NSString *message = [NSString stringWithFormat:@"Add array of permissions with %@ key to CSSocial.plist", kCSFacebookPermissionsPublish];
    NSAssert(permissions, message);
    return permissions;
}

-(BOOL) handleOpenURL:(NSURL *)url {
    return [_session handleOpenURL:url];
}
 
#pragma mark - Permissions And Permission handling

-(BOOL) permissionGranted:(NSString *)permission
{   
    return [[_session permissions] containsObject:permission];
}

-(void) requestPermissionsForRequest:(CSSocialRequest *)request permissionsBlock:(CSErrorBlock)permissionsBlock
{
    CSSocialRequestFacebook *facebookRequest = (CSSocialRequestFacebook*) request;
    
    NSString *permission = facebookRequest.permission;
    if (![self permissionGranted:permission])
    {
        if ([self isPublishPermission:permission])
        {
            [_session requestNewPublishPermissions:@[permission]
                                   defaultAudience:FBSessionDefaultAudienceOnlyMe
                                 completionHandler:^(FBSession *session, NSError *error) {
                                     permissionsBlock(error);
                                 }];
        }
        else
        {
            [_session requestNewReadPermissions:@[permission]
                              completionHandler:^(FBSession *session, NSError *error) {
                                  permissionsBlock(error);
                              }];
        }
    }
    else permissionsBlock(nil);
}

-(BOOL) isPublishPermission:(NSString*) permission
{
    return [kCSFBAllPublishPermissionsArray containsObject:permission];
}

-(BOOL) isReadPermission:(NSString*) permission
{
    return [kCSFBAllReadPermissionsArray containsObject:permission];
}

#pragma mark - Dialogs 

-(void) showDialogWithMessage:(NSString*) message
                        photo:(UIImage*) photo
                      handler:(CSErrorBlock) handlerBlock
{
    [self login:^
     {
         
         if ([SLComposeViewController class])
         {
             SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
             [viewController setInitialText:message];
             [viewController addImage:photo];
             [viewController setCompletionHandler:^(SLComposeViewControllerResult result)
              {
                  switch (result) {
                      case SLComposeViewControllerResultDone:
                          handlerBlock(nil);
                          break;
                      case SLComposeViewControllerResultCancelled:
                          handlerBlock([self errorWithLocalizedDescription:@"Dialog cancelled."]);
                          break;
                      default:
                          break;
                  }
              }];
             [[CSSocial viewController] presentViewController:viewController animated:YES completion:nil];
         }
         else
         {
             handlerBlock([self errorWithLocalizedDescription:@"Dialog not supported on this platform"]);
             /*
             NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                         //UIImageJPEGRepresentation(photo, 1.0f), @"source",
                                         message, @"caption",
                                         nil];
             
             [FBWebDialogs presentFeedDialogModallyWithSession:_session
                                                    parameters:parameters
                                                       handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                           handlerBlock(error);
                                                       }];
              */
         }
     }
     error:^(NSError *error) {
         handlerBlock([self errorWithLocalizedDescription:@"Login failed"]);
     }];
}

@end




