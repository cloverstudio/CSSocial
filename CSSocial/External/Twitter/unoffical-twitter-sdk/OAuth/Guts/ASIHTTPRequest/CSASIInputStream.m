//
//  CSASIInputStream.m
//  Part of CSASIHTTPRequest -> http://allseeing-i.com/CSASIHTTPRequest
//
//  Created by Ben Copsey on 10/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "CSASIInputStream.h"
#import "CSASIHTTPRequest.h"

// Used to ensure only one request can read data at once
static NSLock *readLock = nil;

@implementation CSASIInputStream

+ (void)initialize
{
	if (self == [CSASIInputStream class]) {
		readLock = [[NSLock alloc] init];
	}
}

+ (id)inputStreamWithFileAtPath:(NSString *)path request:(CSASIHTTPRequest *)request
{
	CSASIInputStream *stream = [[[self alloc] init] autorelease];
	[stream setRequest:request];
	[stream setStream:[NSInputStream inputStreamWithFileAtPath:path]];
	return stream;
}

+ (id)inputStreamWithData:(NSData *)data request:(CSASIHTTPRequest *)request
{
	CSASIInputStream *stream = [[[self alloc] init] autorelease];
	[stream setRequest:request];
	[stream setStream:[NSInputStream inputStreamWithData:data]];
	return stream;
}

- (void)dealloc
{
	[stream release];
	[super dealloc];
}

// Called when CFNetwork wants to read more of our request body
// When throttling is on, we ask CSASIHTTPRequest for the maximum amount of data we can read
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	[readLock lock];
	unsigned long toRead = len;
	if ([CSASIHTTPRequest isBandwidthThrottled]) {
		toRead = [CSASIHTTPRequest maxUploadReadLength];
		if (toRead > len) {
			toRead = len;
		} else if (toRead == 0) {
			toRead = 1;
		}
		[request performThrottling];
	}
	[CSASIHTTPRequest incrementBandwidthUsedInLastSecond:toRead];
	[readLock unlock];
	return [stream read:buffer maxLength:toRead];
}

/*
 * Implement NSInputStream mandatory methods to make sure they are implemented
 * (necessary for MacRuby for example) and avoir the overhead of method
 * forwarding for these common methods.
 */
- (void)open
{
    [stream open];
}

- (void)close
{
    [stream close];
}

- (id)delegate
{
    return [stream delegate];
}

- (void)setDelegate:(id)delegate
{
    [stream setDelegate:delegate];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [stream removeFromRunLoop:aRunLoop forMode:mode];
}

- (id)propertyForKey:(NSString *)key
{
    return [stream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return [stream setProperty:property forKey:key];
}

- (NSStreamStatus)streamStatus
{
    return [stream streamStatus];
}

- (NSError *)streamError
{
    return [stream streamError];
}

// If we get asked to perform a method we don't have (probably internal ones),
// we'll just forward the message to our stream

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [stream methodSignatureForSelector:aSelector];
}
	 
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:stream];
}

@synthesize stream;
@synthesize request;
@end
