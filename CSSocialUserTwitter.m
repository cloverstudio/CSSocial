//
//  CSSocialUserTwitter.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialUserTwitter.h"

@implementation CSSocialUserTwitter
-(id) initWithResponse:(id) response
{
    self = [super init];
    if (self)
    {
        if ([response isKindOfClass:[NSArray class]])
        {
            NSDictionary *dict = [response objectAtIndex:0];
            if ([dict isKindOfClass:[NSDictionary class]])
            {
                self.name = [dict objectForKey:@"screen_name"];
                self.ID = [dict objectForKey:@"id_str"];
            }
        }
        else
        {
            self.ID = [response stringValue];
        }
    }
    return self;
}

+(NSArray*) usersWithResponse:(id) response
{
    NSMutableArray *array = [NSMutableArray array];
    if ([response isKindOfClass:[NSDictionary class]])
    {
        for (NSDictionary *userDict in [response objectForKey:@"ids"])
        {
            [array addObject:[CSSocialUserTwitter userWithResponse:userDict]];
        }
    }
    return (NSArray*)array;
}

@end