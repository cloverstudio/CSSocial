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

@end

#pragma mark - Helpers
#pragma mark Facebook
@implementation CSSocialServiceFacebook (Helper)

///postToWall:completionBlock:
///posts a simple message to the facebook wall
///@param message message to post to wall
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postToWall:(NSString*) message completionBlock:(CSSocialResponseBlock) responseBlock
{
    [CSFacebook requestWithParameter:[CSFacebookParameter message:message
                                                             name:nil
                                                             link:nil
                                                       pictureURL:nil
                                                          caption:nil
                                                      description:nil
                                                             icon:nil]
                            response:^(CSSocialRequest *request, id response, NSError *error)
     {
         responseBlock(request, response, error);
     }];
}

///postPhoto:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postPhoto:(UIImage*) photo completionBlock:(CSSocialResponseBlock) responseBlock
{
    CSFacebookParameter *parameter = [CSFacebookParameter photo:photo
                                                        message:nil];
    [CSFacebook requestWithParameter:parameter
                            response:^(CSSocialRequest *request, id response, NSError *error)
     {
         responseBlock(request, response, error);
     }];
}

@end

#pragma mark Twitter
@implementation CSSocialServiceTwitter (Helper)

///tweet:completionBlock:
///posts a simple tweet to selected Twitter account
///@param tweet tweet to post
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) tweet:(NSString*) tweet completionBlock:(CSSocialResponseBlock) responseBlock
{
    CSTwitterParameter *parameter = [CSTwitterParameter message:tweet];
    [CSTwitter requestWithParameter:parameter
                           response:^(CSSocialRequest *request, id response, NSError *error)
     {
         responseBlock(request, response, error);
     }];
}

@end


