//
//  CSSocialTestGoogleLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 3/3/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestGoogleLogin.h"

@implementation CSSocialTestGoogleLogin

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSGoogle isAuthenticated])
    {
        [CSGoogle login:^
         {
             CSLog(@"Twitter login succeeded");
             resultBlock(nil,nil,nil);
         }
                   error:^(NSError *error)
         {
             CSLog(@"Twitter login failed : %@, %d", [error localizedDescription], [error code]);
             resultBlock(nil,nil,error);
             
         }];
    }
    else
    {
        [CSGoogle logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSGoogle isAuthenticated];
}

-(NSString*) name
{
    return @"Google Plus Login";
}


@end
