//
//  CSSocialServiceFacebook.h
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialService.h"
#import "External/Facebook/FBSession.h"

@interface CSSocialServiceFacebook : CSSocialService
///Facebook specific, people you want to share your published stuff with
///@default FBSessionDefaultAudienceEveryone
@property (nonatomic) FBSessionDefaultAudience audience;

///returns accessToken of the current FBSession
@property (nonatomic, readonly) NSString *accessToken;

///requests read permissions for the current session
///@param permissions an array of permissions
///@parama errorBlock returns an error if one occured or nil 
-(void) requestReadPermissions:(NSArray*) permissions errorBlock:(CSErrorBlock) errorBlock;

///requests publish permissions for the current session
///@param permissions an array of permissions
///@parama errorBlock returns an error if one occured or nil
-(void) requestPublishPermissions:(NSArray*) permissions errorBlock:(CSErrorBlock) errorBlock;
@end
