//
//  CSSocialRequest.h
//  CSUtilities
//
//  Created by marko.hlebar on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSConstants.h"

@class CSSocialRequest;
@class CSSocialService;
typedef void (^CSSocialResponseBlock)(CSSocialRequest *request, id response, NSError *error);
@interface CSSocialRequest : NSOperation
{
    BOOL _cancelled;
    BOOL _finished;
    BOOL _executing;
}

//@property (nonatomic, retain) id method;
///API call
@property (nonatomic, retain) NSString *APIcall;
///custom parameters
@property (nonatomic, retain) NSDictionary *params;
///response
@property (nonatomic, copy) CSSocialResponseBlock responseBlock;
///service
///this is an object instance of the service in use, for instance Facebook object when using Facebook. 
@property (nonatomic, assign, readonly) id service;

///HTTP method (GET, POST, PUT)
-(id) method;
-(id) initWithService:(id) service parameters:(NSDictionary*) parameters;
+(CSSocialRequest*) requestWithService:(id)service parameters:(NSDictionary*) parameters;
-(void) receivedResponse;
-(void) receivedResponse:(id) result error:(NSError*) error;
-(id) parseResponse:(id) rawResponse;
@end


