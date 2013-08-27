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
    [CSLinkedin comment:[CSKit loremIpsum]
        completionBlock:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(!error) self.passed = YES;
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];
}

-(NSString*) name
{
    return @"Linekdin Message";
}

@end
