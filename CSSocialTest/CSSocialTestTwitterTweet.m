//
//  CSSocialTestTwitterTweet.m
//  CSSocial
//
//  Created by marko.hlebar on 10/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialTestTwitterTweet.h"

@implementation CSSocialTestTwitterTweet
-(void) performTest:(CSSocialResponseBlock)resultBlock
{

    [CSTwitter tweet:@"This is a test tweet"
     completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
         if(!error) self.passed = YES;
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];
}

-(NSString*) name
{
    return @"Twitter Tweet";
}

@end
