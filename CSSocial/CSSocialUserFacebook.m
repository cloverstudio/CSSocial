//
//  CSSocialUserFacebook.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialUserFacebook.h"

@implementation CSSocialUserFacebook
-(id) initWithResponse:(id) response
{
    self = [super init];
    if (self)
    {
        if ([response isKindOfClass:[NSDictionary class]])
        {
            self.name = [response objectForKey:@"name"];
            self.firstName = [response objectForKey:@"first_name"];
            self.lastName = [response objectForKey:@"last_name"];
            self.userName = [response objectForKey:@"username"];
            self.location = [response objectForKey:@"location"];
            self.gender = [response objectForKey:@"gender"];
            self.ID = [response objectForKey:@"id"];
            self.pageURL = [response objectForKey:@"link"];
            self.photoURL = [NSURL URLWithString:response[@"picture"][@"data"][@"url"]];
        }
    }
    return self;
}

+(NSArray*) usersWithResponse:(id) response
{
    NSDictionary *dictionary = [response objectForKey:@"data"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userDict in dictionary)
    {
        [array addObject:[CSSocialUserFacebook userWithResponse:userDict]];
    }
    return [array copy];
}

@end

