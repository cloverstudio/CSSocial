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
@property (nonatomic, assign) id<CSSocialService> lastService;
@property (nonatomic, assign) UIViewController *presentingViewController;
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

+(UIViewController*) viewController
{
    ///if no view controller has been assigned, try to assign the main window's rootviewcontroller 
    if (![CSSocial sharedManager].presentingViewController) {
        [CSSocial sharedManager].presentingViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    
    NSParameterAssert([CSSocial sharedManager].presentingViewController != nil);
    return [CSSocial sharedManager].presentingViewController;
}

+(void) setViewController:(UIViewController*) viewController
{
    [CSSocial sharedManager].presentingViewController = viewController;
}


///TODO: this is potentially dangerous if two services want to handleOpenURL:
+(BOOL) handleOpenURL:(NSURL *)url
{
    /*
    CSSocial *manager = [CSSocial sharedManager];
    for (NSString *key in [manager.services allKeys])
    {
        CSSocialService *service = [manager.services objectForKey:key];
        if (service && [service respondsToSelector:@selector(handleOpenURL:)])
            return [service handleOpenURL:url];
    }
     */
    CSSocial *manager = [CSSocial sharedManager];
    if ([manager.lastService respondsToSelector:@selector(handleOpenURL:)])
    {
        return [manager.lastService handleOpenURL:url];
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
    manager.lastService = service;
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
    manager.lastService = service;
    return service;
}

+(NSDictionary*) configDictionary
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CSSocial" ofType:@"plist"]];
    NSAssert(plist, @"CSSocial.plist not found. Please read the manual to learn how to set up the CSSocial.framework");
    return plist;
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
    CSFacebookParameter *parameter = [CSFacebookParameter message:message
                                                           name:nil
                                                           link:nil
                                                     pictureURL:nil
                                                        caption:nil
                                                    description:nil
                                                           icon:nil];

    [CSFacebook sendRequest:[CSFacebook requestWithParameter:parameter]
                   response:^(CSSocialRequest *request, id response, NSError *error)
    {
        if(responseBlock)responseBlock(request, response, error);
    }];
}

///postPhoto:caption:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param caption album caption of the image
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postPhoto:(UIImage*) photo
          caption:(NSString*) caption
  completionBlock:(CSSocialResponseBlock) responseBlock
{
    CSFacebookParameter *parameter = [CSFacebookParameter photo:photo
                                                        message:caption];
    
    [CSFacebook sendRequest:[CSFacebook requestWithParameter:parameter]
                   response:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(responseBlock)responseBlock(request, response, error);
     }];
}

///postPhoto:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postPhoto:(UIImage*) photo completionBlock:(CSSocialResponseBlock) responseBlock
{
    [self postPhoto:photo caption:nil completionBlock:responseBlock];
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
    
    [CSTwitter sendRequest:[CSTwitter requestWithParameter:parameter]
                  response:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(responseBlock)responseBlock(request, response, error);
     }];
}

@end


