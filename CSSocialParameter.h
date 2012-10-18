//
//  CSSocialParameter.h
//  CSSocial
//
//  Created by marko.hlebar on 10/15/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSRequests.h"

@protocol CSSocialParameter <NSObject>
-(NSDictionary*) parameters;
-(CSRequestName) requestName;
@end

@interface CSSocialParameter : NSObject <CSSocialParameter>
@property (nonatomic, retain, readonly) NSDictionary *parameters;
@property (nonatomic, readonly) CSRequestName requestName;
+(id)parameter;
@end