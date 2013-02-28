//
//  CSTwitteriOS6Plugin.m
//  CSSocial
//
//  Created by marko.hlebar on 12/5/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSTwitteriOS6Plugin.h"

@implementation CSTwitteriOS6Plugin

-(void) canAccessTwitterAccounts:(CSErrorBlock) canAccessBlock
{
    [_accountStore requestAccessToAccountsWithType:_accountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error)
    {
                                            canAccessBlock(error);
                                        }];
}

@end
