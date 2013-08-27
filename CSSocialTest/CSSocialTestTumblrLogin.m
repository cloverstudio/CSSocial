//
//  CSSocialTestTumblrLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 7/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestTumblrLogin.h"

@implementation CSSocialTestTumblrLogin
-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSTumblr isAuthenticated])
    {
        [CSTumblr login:^
         {
             CSLog(@"Tumblr login succeeded");
             resultBlock(nil,nil,nil);
         }
                    error:^(NSError *error)
         {
             CSLog(@"Tumblr login failed : %@, %d", [error localizedDescription], [error code]);
             resultBlock(nil,nil,error);
             
         }];
    }
    else
    {
        [CSTumblr logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSTumblr isAuthenticated];
}

-(NSString*) name
{
    return @"Tumblr Login";
}
@end
