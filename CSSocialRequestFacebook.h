//
//  CSSocialRequestFacebook.h
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequest.h"
#import "Facebook.h"

@interface CSSocialRequestFacebook : CSSocialRequest <FBRequestDelegate>
@end

///login
///this is a special case that doesn't call for APICall and method it is just a dummy class
@interface CSSocialRequestLogin : CSSocialRequestFacebook
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