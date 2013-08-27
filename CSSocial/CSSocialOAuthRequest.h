//
//  CSSocialOAuthRequest.h
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <CSSocial/CSSocial.h>

@protocol CSOAuthService;
@interface CSSocialOAuthRequest : CSSocialRequest
///interface to use when creating a custom request
///@param service oauth service that is making the request, for instance CSLinkedIn
///@param apiCall path to graph api, for instance me/friends
///@param method HTTP method (GET, POST, PUT)
///@param parameters parameters to use when making a request
///@return CSSocialOAuthRequest object
+(CSSocialOAuthRequest*) requestWithService:(id<CSOAuthService>) service
                                    apiCall:(NSString*) apiCall
                                 httpMethod:(NSString*) method
                                 parameters:(NSDictionary*) parameters;
@end
