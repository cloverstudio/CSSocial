//
//  CSSocialUser.m
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSSocialUser.h"
#import "CSSocialService.h"
#import "CSConstants.h"

@implementation CSSocialUser
@synthesize name;
@synthesize firstName;
@synthesize lastName;
@synthesize userName;
@synthesize location;
@synthesize gender;
@synthesize ID;
@synthesize photoURL;
@synthesize pageURL;

-(void) dealloc
{
    CS_RELEASE(name);
    CS_RELEASE(firstName);
    CS_RELEASE(lastName);
    CS_RELEASE(userName);
    CS_RELEASE(location);
    CS_RELEASE(gender);
    CS_RELEASE(ID);
    CS_RELEASE(photoURL);
    CS_RELEASE(pageURL);
    CS_SUPER_DEALLOC;
}

+(id) userWithResponse:(id) response
{
    return CS_AUTORELEASE([[self alloc] initWithResponse:response]);
}

-(id) initWithResponse:(id) response
{
    NSAssert(NO, @"Initialize in a subclass");
    return nil;
}

///returns an array of users from response
///@param response social response
///@return array of CSSocialUser objects
+(NSArray*) usersWithResponse:(id) response
{
    NSAssert(NO, @"Override in a subclass");
    return nil;
}

@end
