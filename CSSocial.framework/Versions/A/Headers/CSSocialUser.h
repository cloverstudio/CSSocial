//
//  CSSocialUser.h
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSSocialService;
@protocol CSSocialUser <NSObject>
-(NSString*) name;
-(NSString*) firstName;
-(NSString*) lastName;
-(NSString*) userName;
-(NSString*) ID;
-(NSString*) location; 
-(NSString*) gender; 
-(NSURL*) pageURL;
-(NSURL*) photoURL;
@end

@interface CSSocialUser : NSObject <CSSocialUser>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSURL *photoURL;
@property (nonatomic, retain) NSURL *pageURL;

///initializes a user based on the response
///@param response a response obtained when calling an API on a social service
///@return a CSSocialUser instance
-(id) initWithResponse:(id) response;

///initializes a user based on the response
///@param response a response obtained when calling an API on a social service
///@return a CSSocialUser instance
+(id) userWithResponse:(id) response;

///returns an array of users from response
///@param response social response
///@return array of CSSocialUser objects
+(NSArray*) usersWithResponse:(id) response;
@end
