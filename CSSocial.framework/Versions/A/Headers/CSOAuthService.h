//
//  CSOAuthService.h
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialService.h"

@class OAConsumer;
@class OAToken;
@interface CSOAuthService : CSSocialService <CSOAuthService>
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *accessToken;
-(NSString*) cancelAuthenticationKeyword;
-(NSString*) socialPlistApiKeyName;
-(NSString*) socialPlistSecretKeyName;
-(BOOL) isCancellationURL:(NSURL*) url;
@end
