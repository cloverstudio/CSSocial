//
//  CSSocialService.h
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSConstants.h"
#import "CSRequests.h"
#import "CSSocialRequest.h"

@protocol CSSocialUser;
@protocol CSSocialParameter;

///private protocol classes
@protocol CSSocialService <NSObject>
@optional
-(NSError*) errorWithLocalizedDescription:(NSString*) description;

@required
-(NSDictionary*) configDictionary;
-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error;
-(void) request:(CSSocialRequest*) request response:(CSSocialResponseBlock) responseBlock;
-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>) parameter;

-(BOOL) isAuthenticated;
-(NSString*) serviceName;
-(NSArray*) permissions;

-(NSError*) errorWithLocalizedDescription:(NSString*) description;
@end

@interface CSSocialService : NSObject 
@property (nonatomic, retain) NSOperationQueue *requestQueue;
@property (nonatomic, copy) CSVoidBlock loginSuccessBlock;
@property (nonatomic, copy) CSErrorBlock loginFailedBlock;

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>) parameter
                                response:(CSSocialResponseBlock) responseBlock;
-(BOOL) handleOpenURL:(NSURL*)url;

@end
