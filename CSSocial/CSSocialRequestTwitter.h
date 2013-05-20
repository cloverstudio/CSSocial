//
//  CSSocialRequestTwitter.h
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequest.h"

@interface CSSocialRequestTwitter : CSSocialRequest
@end

///tweet
@interface CSSocialRequestTwitterMessage : CSSocialRequestTwitter
@end

///user image
@interface CSSocialRequestTwitterGetUserImage : CSSocialRequestTwitter
@end

///friends
@interface CSSocialRequestTwitterFriends : CSSocialRequestTwitter
@end