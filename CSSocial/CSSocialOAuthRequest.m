//
//  CSSocialOAuthRequest.m
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialOAuthRequest.h"
#import "CSOAuthService.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher+Blocks.h"

@implementation CSSocialOAuthRequest

+ (CSSocialOAuthRequest *)requestWithService:(id<CSOAuthService>)service
                                     apiCall:(NSString *)apiCall
                                  httpMethod:(NSString *)method
                                  parameters:(NSDictionary *)parameters {
    return [[self alloc] initWithService:service apiCall:apiCall httpMethod:method parameters:parameters];
}

- (id)initWithService:(id)service
              apiCall:(NSString *)apiCall
           httpMethod:(NSString *)method
           parameters:(NSDictionary *)parameters {
    self = [super initWithService:service parameters:parameters];
    if (self) {
        self.APIcall = apiCall;
        self.method = method;
    }
    return self;
}

- (void)makeRequest {
    CSOAuthService *service = self.service;
    NSURL *url = [NSURL URLWithString:self.APIcall];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:service.consumer
                                                                      token:service.accessToken
                                                                   callback:nil
                                                          signatureProvider:nil];
    NSError *error = nil;
    NSData *httpData = [NSJSONSerialization dataWithJSONObject:self.params
                                                       options:0
                                                         error:&error];
    if (!error) {
        [request setHTTPBody:httpData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        __block CSSocialOAuthRequest *this = self;;
        [OADataFetcher fetchDataWithRequest:request
                                ticketBlock:^(OAServiceTicket *ticket, id responseData, NSError *error) {
                                    [this receivedResponse:responseData error:error];
                                }];
    }
    else {
        ///JSON parameters error
        [self receivedResponse:nil error:error];
    }

}

@end
