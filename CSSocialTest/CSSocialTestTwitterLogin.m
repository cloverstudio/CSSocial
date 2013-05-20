//
//  CSSocialTestTwitterLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 1/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestTwitterLogin.h"

@implementation CSSocialTestTwitterLogin

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSTwitter isAuthenticated])
    {
        [CSTwitter login:^
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
        [CSTwitter logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSTwitter isAuthenticated];
}

-(NSString*) name
{
    return @"Twitter Login";
}

@end
