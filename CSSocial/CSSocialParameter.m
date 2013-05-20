//
//  CSSocialParameter.m
//  CSSocial
//
//  Created by marko.hlebar on 10/15/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialParameter.h"

@interface CSSocialParameter()
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic) CSRequestName requestName;
@end

@implementation CSSocialParameter
+(id)parameter
{
    return CS_AUTORELEASE([[self alloc] init]);
}
@end
