//
//  CSSocialError.h
//  CSSocial
//
//  Created by marko.hlebar on 3/14/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CSSocialErrorCodeLoginFailed = 10000,
    CSSocialErrorCodeUserCancelled = 10001
}
CSSocialServiceErrorCode;

@interface CSSocialError : NSObject

@end
