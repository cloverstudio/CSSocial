//
//  CSTwitterParameter.m
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 26.6.2012..
//  Copyright (c) 2012. Clover Studio. All rights reserved.
//

#import "CSTwitterParameter.h"
#import "CSConstants.h"

@interface CSTwitterParameter()
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic) CSRequestName requestName;
@end

@implementation CSTwitterParameter
+(CSTwitterParameter*) message:(NSString*) message
{
    CSTwitterParameter *object = [CSTwitterParameter parameter];
    object.requestName = CSRequestPostMessage;
    object.parameters = [NSDictionary dictionaryWithObjectsAndKeys:message, @"status", nil];
    return object;
}
@end
