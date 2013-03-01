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
-(NSOperationQueue*) operationQueue;
-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error;
-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>) parameter;
-(BOOL) permissionGranted:(NSString*) permission;
-(void) requestPermissionsForRequest:(CSSocialRequest*) request permissionsBlock:(CSErrorBlock) permissionsBlock;
-(BOOL) isAuthenticated;
-(void) logout;
-(NSString*) serviceName;

@optional
-(BOOL) handleOpenURL:(NSURL*)url;
@end

@interface CSSocialService : NSObject <CSSocialService>
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, copy) CSErrorBlock permissionsBlock;
@property (nonatomic, copy) CSVoidBlock loginSuccessBlock;
@property (nonatomic, copy) CSErrorBlock loginFailedBlock;

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>) parameter
                                response:(CSSocialResponseBlock) responseBlock
__attribute__((deprecated));

///@abstract sends a request to a social service and handles a callback when the sevice has returned the result
///@param request a CSSocialRequest you constructed manually or by using requestWithParameter:
///@param responseBlock callback block with results
-(void) sendRequest:(CSSocialRequest*) request
           response:(CSSocialResponseBlock) responseBlock;

///@abstract this is a convenience method that you can use for automatic request construction based on the parameter object passed
///@param parameter an object that describes the main request details
///@return CSSocialRequest instance
-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>)parameter;

///@abstract shows the dialog box of the service (where available) with initial message and photo parameters
///@param message initial message
///@param photo photo to upload
///@param handlerBlock callback block containing an error if one occured.
-(void) showDialogWithMessage:(NSString*) message
                        photo:(UIImage*) photo
                      handler:(CSErrorBlock) handlerBlock;

@end
