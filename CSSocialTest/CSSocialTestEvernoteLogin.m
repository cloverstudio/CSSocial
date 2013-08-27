//
//  CSSocialTestEvernoteLogin.m
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestEvernoteLogin.h"

@implementation CSSocialTestEvernoteLogin
-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    
    if (![CSEvernote isAuthenticated])
    {
        [CSEvernote login:^
         {
             CSLog(@"Evernote login succeeded");
             resultBlock(nil,nil,nil);
         }
                  error:^(NSError *error)
         {
             CSLog(@"Evernote login failed : %@, %d", [error localizedDescription], [error code]);
             resultBlock(nil,nil,error);
             
         }];
    }
    else
    {
        [CSEvernote logout];
        resultBlock(nil,nil,nil);
    }
}

-(BOOL) passed
{
    return [CSEvernote isAuthenticated];
}

-(NSString*) name
{
    return @"Evernote Login";
}
@end
