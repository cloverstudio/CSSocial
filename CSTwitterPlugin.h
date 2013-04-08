//
//  CSTwitterPlugin.h
//  CSSocial
//
//  Created by marko.hlebar on 11/26/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OAuth;
@class UIViewController;
@protocol CSTwitterPlugin <NSObject>
-(void) login:(CSVoidBlock)success error:(CSErrorBlock) error;
-(void) logout;
-(OAuth*) oAuth;
-(UIViewController*) presentingViewController;
-(BOOL) isAuthenticated;
-(void) authenticate;
-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock;
@end

@interface CSTwitterPlugin : NSObject <CSTwitterPlugin>
@property(nonatomic, copy) CSVoidBlock loginSuccessBlock;
@property(nonatomic, copy) CSErrorBlock loginFailedBlock;
@property(nonatomic, strong) OAuth *oAuth;
@property(nonatomic, readonly, strong) NSString *consumerKey;
@property(nonatomic, readonly, strong) NSString *consumerSecret;

///chooses the correct plugin based on iOS version and config settings and instantiates it
///@return an instance of CSTwitterPlugin
+(CSTwitterPlugin*) plugin;

-(void) saveOAuth:(OAuth*) oAuth;
-(void) loadOAuth:(OAuth*) oAuth;
-(void) resetOAuth;

-(NSError*) errorWithLocalizedDescription:(NSString*) description errorCode:(NSInteger) errorCode;
-(NSError*) errorWithLocalizedDescription:(NSString*) description;
-(NSError*) errorInvalidReturnValue;
-(NSError*) errorAccountNotFound;
-(NSError*) errorUnsupportedSDK;
-(NSError*) errorTwitterLoginFailed;
-(NSError*) errorTwitterUserCancelled;

@end
