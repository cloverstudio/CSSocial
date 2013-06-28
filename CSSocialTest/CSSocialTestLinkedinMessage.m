//
//  CSSocialTestLinkedinMessage.m
//  CSSocial
//
//  Created by marko.hlebar on 6/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestLinkedinMessage.h"

@implementation CSSocialTestLinkedinMessage

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSLinkedin showDialogWithMessage:[CSKit loremIpsum]
                                photo:[UIImage imageNamed:@"test"]
                              handler:^(NSError *error)
     {
         if (!error) self.passed = YES;
         resultBlock(nil,nil,error);
     }];
}

-(NSString*) name
{
    return @"Linekdin Show Dialog";
}

@end
