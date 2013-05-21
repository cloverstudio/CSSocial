//
//  CSSocialUserFacebook.m
//  CSSocial
//
//  Created by Marko Hlebar on 12/19/12.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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

