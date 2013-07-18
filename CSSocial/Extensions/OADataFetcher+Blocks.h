//
//  OADataFetcher+Blocks.h
//  CSSocial
//
//  Created by marko.hlebar on 7/18/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "OADataFetcher.h"

typedef void (^OATicketBlock)(OAServiceTicket* ticket, id responseData, NSError* error);

@interface OADataFetcher (Blocks)
+ (void) fetchDataWithRequest:(OAMutableURLRequest *) request ticketBlock:(OATicketBlock) ticketBlock;
@end
