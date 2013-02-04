//
//  CSSocialRequestTwitter.m
//  CSSocial
//
//  Created by marko.hlebar on 12/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialRequestTwitter.h"
#import "OAuth.h"
#import <Twitter/TWRequest.h>
#import "CSSocialUserTwitter.h"

#pragma mark - CSSocialRequestTwitter

@interface CSSocialRequestTwitter (Private)

-(id) parseResponseData:(id)response error:(NSError**) error;
-(NSString*) paramsString;
- (NSString *)encodedURLParameterString:(NSString*) string;
@end

@implementation CSSocialRequestTwitter
{
    NSMutableData *_data;
}
-(void) dealloc
{
    CS_RELEASE(_data);
    CS_SUPER_DEALLOC;
}

-(void) start
{
    [super start];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        _data = (NSMutableData*)[NSURLConnection sendSynchronousRequest:[self request]
                                                      returningResponse:&response
                                                                  error:&error];
        [self buildResponse:_data error:error];
    }
    else
    {
        [NSURLConnection sendAsynchronousRequest:[self request]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             [self buildResponse:data error:error];
         }];
    }
}

-(void) buildResponse:(NSData*) data error:(NSError*) error
{
    if (error)
    {
        self.responseBlock(self, nil, error);
        return;
    }
    
    if (!data)
    {
        self.responseBlock(self, nil, [NSError errorWithDomain:@""
                                                          code:0
                                                      userInfo:[NSDictionary dictionaryWithObject:@"No data in response"
                                                                                           forKey:NSLocalizedDescriptionKey]]);
        return;
    }
    
    id parsedResponse = [self parseResponseData:data error:&error];
    if (!parsedResponse || error)
    {
        self.responseBlock(self, nil, error);
        return;
    }
    
    self.responseBlock(self, parsedResponse, nil);
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection*) connection
{
    [self buildResponse:_data error:nil];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseBlock(self, nil, error);
}

-(NSMutableURLRequest*) request
{
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", [self APIcall], [self paramsString]];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
}

///parse JSON by default.
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    if (responseData)
    {
        return [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:error];
    }
    else
    {
        return nil;
    }
}

-(NSString*) paramsString
{
    NSMutableString *paramsString = [NSMutableString string];
    
    [self.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsString appendFormat:@"%@=%@&", key, [self encodedURLParameterString:[self.params objectForKey:key]]];
    }];
    
    /*
     
     NSInteger keyCount = 0;
     NSArray *keys = [self.params allKeys];
     
     for (NSString *key in keys)
     {
     keyCount++;
     [paramsString appendFormat:@"%@=%@", key, [self encodedURLParameterString:[self.params objectForKey:key]]];
     if (keyCount != keys.count) [paramsString appendString:@"&"];
     }
     */
    
    return [NSString stringWithString:paramsString];
}

- (NSString *)encodedURLParameterString:(NSString*) string
{
    NSString *result = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                   (__bridge CFStringRef)string,
                                                                                   NULL,
                                                                                   CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                                   kCFStringEncodingUTF8);
	return CS_AUTORELEASE(result);
}

@end

@implementation CSSocialRequestTwitterMessage
-(NSString*) APIcall {return @"https://api.twitter.com/1/statuses/update.json";}

-(NSMutableURLRequest*) request
{
    OAuth *oAuth = (OAuth*)self.service;
    NSString *postBodyString = [self paramsString];
    NSString *postUrl = [self APIcall];
    NSMutableDictionary *postInfo = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:[oAuth oAuthHeaderForMethod:@"POST"
                                           andUrl:postUrl
                                        andParams:postInfo] forHTTPHeaderField:@"Authorization"];
    return request;
}
@end

@implementation CSSocialRequestTwitterGetUserImage
-(NSString*) APIcall { return @"https://api.twitter.com/1/users/profile_image"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    UIImage *image = [UIImage imageWithData:responseData];
    if (!image) {
        *error = [NSError errorWithDomain:@"com.clover-studio" code:100 userInfo:nil];
        return nil;
    }
    return image;
}
@end

@implementation CSSocialRequestTwitterFriends
-(NSString*) APIcall { return @"https://api.twitter.com/1/friends/ids.json"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    return [CSSocialUserTwitter usersWithResponse:responseData];
}
@end
