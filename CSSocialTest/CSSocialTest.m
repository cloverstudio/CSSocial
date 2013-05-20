//
//  CSSocialTest.m
//  CSSocial
//
//  Created by marko.hlebar on 10/18/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialTest.h"

@implementation CSSocialTest

+(id) test
{
    return CS_AUTORELEASE([[self alloc] init]);
}

-(void)performTest:(CSSocialResponseBlock) resultBlock
{
    ///override me;
}

-(UIViewController*) resultsViewController
{
    return nil;
}

@end
