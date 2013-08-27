//
//  CSSocialTestEvernoteCreateNote.m
//  CSSocial
//
//  Created by marko.hlebar on 7/19/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestEvernoteCreateNote.h"

@implementation CSSocialTestEvernoteCreateNote

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSEvernote createNote:[CSKit loremIpsum]
           completionBlock:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(!error) self.passed = YES;
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];
}

-(NSString*) name
{
    return @"Evernote Create Note";
}

@end
