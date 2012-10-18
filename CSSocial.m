//
//  CSSocial.m
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CSSocial.h"
#import "CSSocialService.h"
#import "CSSocialServiceFacebook.h"
#import "CSSocialServiceTwitter.h"
#import "CSConstants.h"

@interface CSSocial ()
@property (nonatomic, retain) NSMutableDictionary *services;
@end

@implementation CSSocial

+(CSSocial*) sharedManager
{
    static CSSocial *_sharedInstance = nil;
    @synchronized(self)
    {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
        return _sharedInstance;
    }
}

-(void) dealloc
{
    CS_RELEASE(_services);
    CS_SUPER_DEALLOC;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        _services = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(void) setDataSource:(id<CSSocialManagerDataSource>) dataSource
{
    CSSocial *manager = [CSSocial sharedManager];
    manager.dataSource = dataSource;
}

+(BOOL) handleOpenURL:(NSURL *)url
{
    CSSocial *manager = [CSSocial sharedManager];
    for (NSString *key in [manager.services allKeys])
    {
        CSSocialService *service = [manager.services objectForKey:key];
        if (service && [service respondsToSelector:@selector(handleOpenURL:)])
            return [service handleOpenURL:url];
    }
    return NO;
}

+(CSSocialService*) facebook
{
    CSSocial *manager = [CSSocial sharedManager];
    CSSocialService *service = [manager.services objectForKey:@"CSSocialServiceFacebook"];
    if (!service)
    {
        service = CS_AUTORELEASE([[CSSocialServiceFacebook alloc] init]);
        [manager.services setObject:service forKey:@"CSSocialServiceFacebook"];
    }
    return service;
}

+(CSSocialService*) twitter
{
    CSSocial *manager = [CSSocial sharedManager];
    CSSocialService *service = [manager.services objectForKey:@"CSSocialServiceTwitter"];
    if (!service)
    {
        service = CS_AUTORELEASE([[CSSocialServiceTwitter alloc] init]);
        [manager.services setObject:service forKey:@"CSSocialServiceTwitter"];
    }
    return service;
}

/*
+(CSSocialService*) mixi
{
    CSSocial *manager = [CSSocial sharedManager];
    CSSocialService *service = [manager.services objectForKey:@"CSSocialServiceMixi"];
    if (!service)
    {
        service = CS_AUTORELEASE([[CSSocialServiceMixi alloc] init]);
        [manager.services setObject:service forKey:@"CSSocialServiceMixi"];
    }
    return service;
}
 */



@end
