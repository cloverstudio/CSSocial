//
//  CSTwitterParameter.h
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 26.6.2012..
//  Copyright (c) 2012. Clover Studio. All rights reserved.
//

#import "CSSocialParameter.h"
#import "CSRequests.h"

@interface CSTwitterParameter : CSSocialParameter

///Constructs parameters for post Twitter status
///@param message status message
+(id<CSSocialParameter>) message:(NSString*) message;

@end
