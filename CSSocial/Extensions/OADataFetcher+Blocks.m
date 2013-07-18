//
//  OADataFetcher+Blocks.m
//  CSSocial
//
//  Created by marko.hlebar on 7/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "OADataFetcher+Blocks.h"
#import "OAServiceTicket.h"

@implementation OADataFetcher (Blocks)
+(void) fetchDataWithRequest:(OAMutableURLRequest *) request ticketBlock:(OATicketBlock) ticketBlock {
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (ticketBlock) {
                                   if (!error) {
                                       OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                                                 response:response
                                                                                                     data:data
                                                                                               didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
                                       ticketBlock(ticket, data, error);
                                   }
                                   else {
                                       ticketBlock(nil,nil,error);
                                   }
                               }
                           }];
}
@end
