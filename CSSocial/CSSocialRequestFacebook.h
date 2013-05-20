//
//  CSSocialRequestFacebook.h
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequest.h"

@interface CSSocialRequestFacebook : CSSocialRequest
///Facebook permission needed to do the request.
///List of all permissions is here https://developers.facebook.com/docs/howtos/ios-6/
@property (nonatomic, strong) NSArray *permissions;

///interface to use when creating a custom request
///@param apiCall path to graph api, for instance me/friends
///@param method HTTP method (GET, POST, PUT)
///@param parameters parameters to use when making a request
///@param permission permission needed for this API
///@return CSSocialRequestFacebook object
+(CSSocialRequestFacebook*) requestWithApiCall:(NSString*) apiCall
                                    httpMethod:(NSString*) method
                                    parameters:(NSDictionary*) parameters
                                    permissions:(NSArray*) permissions;
@end

///user
@interface CSSocialRequestFacebookUser : CSSocialRequestFacebook
@end

///friends
@interface CSSocialRequestFacebookFriends : CSSocialRequestFacebook
@end

///friends paging
@interface CSSocialRequestFacebookFriendsPaging : CSSocialRequestFacebookFriends
@end

///post wall
@interface CSSocialRequestFacebookPostWall : CSSocialRequestFacebook
@end

///post photo
@interface CSSocialRequestFacebookPostPhoto : CSSocialRequestFacebook
@end

///get picture
@interface CSSocialRequestFacebookGetUserImage : CSSocialRequestFacebook
@end