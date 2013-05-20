//
//  CSSocialTestFacebookLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 1/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookLogin.h"

@implementation CSSocialTestFacebookLogin

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSFacebook isAuthenticated])
    {
        [CSFacebook login:^
         {
             CSLog(@"Facebook login succeeded");
             resultBlock(nil,nil,nil);

         }
                   error:^(NSError *error)
         {
             CSLog(@"Facebook login failed : %@ %d", [error localizedDescription], [error code]);
             resultBlock(nil,nil,nil);

         }];
    }
    else
    {
        [CSFacebook logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSFacebook isAuthenticated];
}

-(NSString*) name
{
    return @"Facebook Login";
}

@end
