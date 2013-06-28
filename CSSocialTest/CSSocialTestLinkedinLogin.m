//
//  CSSocialTestLinkedinLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 6/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestLinkedinLogin.h"

@implementation CSSocialTestLinkedinLogin
-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSLinkedin isAuthenticated])
    {
        [CSLinkedin login:^
         {
             CSLog(@"Linkedin login succeeded");
             resultBlock(nil,nil,nil);
         }
                  error:^(NSError *error)
         {
             CSLog(@"Linkedin login failed : %@, %d", [error localizedDescription], [error code]);
             resultBlock(nil,nil,error);
             
         }];
    }
    else
    {
        [CSLinkedin logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSLinkedin isAuthenticated];
}

-(NSString*) name
{
    return @"Linkedin Login";
}
@end
