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
@end
