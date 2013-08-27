//
//  CSSocialServiceEvernote.h
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSOAuthService.h"

@interface CSSocialServiceEvernote : CSOAuthService
@property (nonatomic, getter = isProduction) BOOL production;
@end
