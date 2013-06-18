//
//  CSASIDownloadCache.m
//  Part of CSASIHTTPRequest -> http://allseeing-i.com/CSASIHTTPRequest
//
//  Created by Ben Copsey on 01/05/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "CSASIDownloadCache.h"
#import "CSASIHTTPRequest.h"
#import <CommonCrypto/CommonHMAC.h>

static CSASIDownloadCache *sharedCache = nil;

static NSString *sessionCacheFolder = @"SessionStore";
static NSString *permanentCacheFolder = @"PermanentStore";

@interface CSASIDownloadCache ()
+ (NSString *)keyForRequest:(CSASIHTTPRequest *)request;
@end

@implementation CSASIDownloadCache

- (id)init
{
	self = [super init];
	[self setShouldRespectCacheControlHeaders:YES];
	[self setDefaultCachePolicy:CSASIReloadIfDifferentCachePolicy];
	[self setAccessLock:[[[NSRecursiveLock alloc] init] autorelease]];
	return self;
}

+ (id)sharedCache
{
	if (!sharedCache) {
		sharedCache = [[self alloc] init];
		[sharedCache setStoragePath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"CSASIHTTPRequestCache"]];

	}
	return sharedCache;
}

- (void)dealloc
{
	[storagePath release];
	[accessLock release];
	[super dealloc];
}

- (NSString *)storagePath
{
	[[self accessLock] lock];
	NSString *p = [[storagePath retain] autorelease];
	[[self accessLock] unlock];
	return p;
}


- (void)setStoragePath:(NSString *)path
{
	[[self accessLock] lock];
	[self clearCachedResponsesForStoragePolicy:CSASICacheForSessionDurationCacheStoragePolicy];
	[storagePath release];
	storagePath = [path retain];
	BOOL isDirectory = NO;
	NSArray *directories = [NSArray arrayWithObjects:path,[path stringByAppendingPathComponent:sessionCacheFolder],[path stringByAppendingPathComponent:permanentCacheFolder],nil];
	for (NSString *directory in directories) {
		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
		if (exists && !isDirectory) {
			[[self accessLock] unlock];
			[NSException raise:@"FileExistsAtCachePath" format:@"Cannot create a directory for the cache at '%@', because a file already exists",directory];
		} else if (!exists) {
			[[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
			if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
				[[self accessLock] unlock];
				[NSException raise:@"FailedToCreateCacheDirectory" format:@"Failed to create a directory for the cache at '%@'",directory];
			}
		}
	}
	[self clearCachedResponsesForStoragePolicy:CSASICacheForSessionDurationCacheStoragePolicy];
	[[self accessLock] unlock];
}

- (void)storeResponseForRequest:(CSASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge
{
	[[self accessLock] lock];
	
	if ([request error] || ![request responseHeaders] || ([request responseStatusCode] != 200)) {
		[[self accessLock] unlock];
		return;
	}
	
	if ([self shouldRespectCacheControlHeaders] && ![[self class] serverAllowsResponseCachingForRequest:request]) {
		[[self accessLock] unlock];
		return;
	}
	
	// If the request is set to use the default policy, use this cache's default policy
	CSASICachePolicy policy = [request cachePolicy];
	if (policy == CSASIDefaultCachePolicy) {
		policy = [self defaultCachePolicy];
	}
	
	if (policy == CSASIIgnoreCachePolicy) {
		[[self accessLock] unlock];
		return;
	}
	NSString *path = nil;
	if ([request cacheStoragePolicy] == CSASICacheForSessionDurationCacheStoragePolicy) {
		path = [[self storagePath] stringByAppendingPathComponent:sessionCacheFolder];
	} else {
		path = [[self storagePath] stringByAppendingPathComponent:permanentCacheFolder];
	}
	path = [path stringByAppendingPathComponent:[[self class] keyForRequest:request]];
	NSString *metadataPath = [path stringByAppendingPathExtension:@"cachedheaders"];
	NSString *dataPath = [path stringByAppendingPathExtension:@"cacheddata"];
	
	NSMutableDictionary *responseHeaders = [NSMutableDictionary dictionaryWithDictionary:[request responseHeaders]];
	if ([request isResponseCompressed]) {
		[responseHeaders removeObjectForKey:@"Content-Encoding"];
	}
	if (maxAge != 0) {
		[responseHeaders removeObjectForKey:@"Expires"];
		[responseHeaders setObject:[NSString stringWithFormat:@"max-age=%i",(int)maxAge] forKey:@"Cache-Control"];
	}
	// We use this special key to help expire the request when we get a max-age header
	[responseHeaders setObject:[[[self class] rfc1123DateFormatter] stringFromDate:[NSDate date]] forKey:@"X-CSASIHTTPRequest-Fetch-date"];
	[responseHeaders writeToFile:metadataPath atomically:NO];
	
	if ([request responseData]) {
		[[request responseData] writeToFile:dataPath atomically:NO];
	} else if ([request downloadDestinationPath]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] copyItemAtPath:[request downloadDestinationPath] toPath:dataPath error:&error];
	}
	[[self accessLock] unlock];
}

- (NSDictionary *)cachedHeadersForRequest:(CSASIHTTPRequest *)request
{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return nil;
	}
	// Look in the session store
	NSString *path = [[self storagePath] stringByAppendingPathComponent:sessionCacheFolder];
	NSString *dataPath = [path stringByAppendingPathComponent:[[[self class] keyForRequest:request] stringByAppendingPathExtension:@"cachedheaders"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		[[self accessLock] unlock];
		return [NSDictionary dictionaryWithContentsOfFile:dataPath];
	}
	// Look in the permanent store
	path = [[self storagePath] stringByAppendingPathComponent:permanentCacheFolder];
	dataPath = [path stringByAppendingPathComponent:[[[self class] keyForRequest:request] stringByAppendingPathExtension:@"cachedheaders"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		[[self accessLock] unlock];
		return [NSDictionary dictionaryWithContentsOfFile:dataPath];
	}
	[[self accessLock] unlock];
	return nil;
}
							  
- (NSData *)cachedResponseDataForRequest:(CSASIHTTPRequest *)request
{
	NSString *path = [self pathToCachedResponseDataForRequest:request];
	if (path) {
		return [NSData dataWithContentsOfFile:path];
	}
	return nil;
}

- (NSString *)pathToCachedResponseDataForRequest:(CSASIHTTPRequest *)request
{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return nil;
	}
	// Look in the session store
	NSString *path = [[self storagePath] stringByAppendingPathComponent:sessionCacheFolder];
	NSString *dataPath = [path stringByAppendingPathComponent:[[[self class] keyForRequest:request] stringByAppendingPathExtension:@"cacheddata"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		[[self accessLock] unlock];
		return dataPath;
	}
	// Look in the permanent store
	path = [[self storagePath] stringByAppendingPathComponent:permanentCacheFolder];
	dataPath = [path stringByAppendingPathComponent:[[[self class] keyForRequest:request] stringByAppendingPathExtension:@"cacheddata"]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		[[self accessLock] unlock];
		return dataPath;
	}
	[[self accessLock] unlock];
	return nil;
}

- (void)removeCachedDataForRequest:(CSASIHTTPRequest *)request
{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return;
	}
	NSString *cachedHeadersPath = [[self storagePath] stringByAppendingPathComponent:[[[self class] keyForRequest:request] stringByAppendingPathExtension:@"cachedheaders"]];
	if (!cachedHeadersPath) {
		[[self accessLock] unlock];
		return;
	}
	NSString *dataPath = [self pathToCachedResponseDataForRequest:request];
	if (!dataPath) {
		[[self accessLock] unlock];
		return;
	}
	[[NSFileManager defaultManager] removeItemAtPath:cachedHeadersPath error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
	[[self accessLock] unlock];
}

- (BOOL)isCachedDataCurrentForRequest:(CSASIHTTPRequest *)request
{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return NO;
	}
	NSDictionary *cachedHeaders = [self cachedHeadersForRequest:request];
	if (!cachedHeaders) {
		[[self accessLock] unlock];
		return NO;
	}
	NSString *dataPath = [self pathToCachedResponseDataForRequest:request];
	if (!dataPath) {
		[[self accessLock] unlock];
		return NO;
	}

	if ([self shouldRespectCacheControlHeaders]) {

		// Look for an Expires header to see if the content is out of data
		NSString *expires = [cachedHeaders objectForKey:@"Expires"];
		if (expires) {
			if ([[CSASIHTTPRequest dateFromRFC1123String:expires] timeIntervalSinceNow] < 0) {
				[[self accessLock] unlock];
				return NO;
			}
		}
		// Look for a max-age header
		NSString *cacheControl = [[cachedHeaders objectForKey:@"Cache-Control"] lowercaseString];
		if (cacheControl) {
			NSScanner *scanner = [NSScanner scannerWithString:cacheControl];
			if ([scanner scanString:@"max-age" intoString:NULL]) {
				[scanner scanString:@"=" intoString:NULL];
				NSTimeInterval maxAge = 0;
				[scanner scanDouble:&maxAge];
				NSDate *fetchDate = [CSASIHTTPRequest dateFromRFC1123String:[cachedHeaders objectForKey:@"X-CSASIHTTPRequest-Fetch-date"]];

				NSDate *expiryDate = [[[NSDate alloc] initWithTimeInterval:maxAge sinceDate:fetchDate] autorelease];

				if ([expiryDate timeIntervalSinceNow] < 0) {
					[[self accessLock] unlock];
					return NO;
				}
			}
		}
		
	}
	
	// If we already have response headers for this request, check to see if the new content is different
	if ([request responseHeaders] && [request responseStatusCode] != 304) {
		// If the Etag or Last-Modified date are different from the one we have, fetch the document again
		NSArray *headersToCompare = [NSArray arrayWithObjects:@"Etag",@"Last-Modified",nil];
		for (NSString *header in headersToCompare) {
			if (![[[request responseHeaders] objectForKey:header] isEqualToString:[cachedHeaders objectForKey:header]]) {
				[[self accessLock] unlock];
				return NO;
			}
		}
	}
	[[self accessLock] unlock];
	return YES;
}

- (CSASICachePolicy)defaultCachePolicy
{
	[[self accessLock] lock];
	CSASICachePolicy cp = defaultCachePolicy;
	[[self accessLock] unlock];
	return cp;
}


- (void)setDefaultCachePolicy:(CSASICachePolicy)cachePolicy
{
	[[self accessLock] lock];
	if (cachePolicy == CSASIDefaultCachePolicy) {
		defaultCachePolicy = CSASIReloadIfDifferentCachePolicy;
	}  else {
		defaultCachePolicy = cachePolicy;	
	}
	[[self accessLock] unlock];
}

- (void)clearCachedResponsesForStoragePolicy:(CSASICacheStoragePolicy)storagePolicy
{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return;
	}
	NSString *path;
	if (storagePolicy == CSASICachePermanentlyCacheStoragePolicy) {
		path = [[self storagePath] stringByAppendingPathComponent:permanentCacheFolder];
	} else {
		path = [[self storagePath] stringByAppendingPathComponent:sessionCacheFolder];
	}
	BOOL isDirectory = NO;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
	if (exists && !isDirectory || !exists) {
		[[self accessLock] unlock];
		return;
	}
	NSError *error = nil;
	NSArray *cacheFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
	if (error) {
		[[self accessLock] unlock];
		[NSException raise:@"FailedToTraverseCacheDirectory" format:@"Listing cache directory failed at path '%@'",path];	
	}
	for (NSString *file in cacheFiles) {
		NSString *extension = [file pathExtension];
		if ([extension isEqualToString:@"cacheddata"] || [extension isEqualToString:@"cachedheaders"]) {
			[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
			if (error) {
				[[self accessLock] unlock];
				[NSException raise:@"FailedToRemoveCacheFile" format:@"Failed to remove cached data at path '%@'",path];	
			}
		}
	}
	[[self accessLock] unlock];
}

+ (BOOL)serverAllowsResponseCachingForRequest:(CSASIHTTPRequest *)request
{
	NSString *cacheControl = [[[request responseHeaders] objectForKey:@"Cache-Control"] lowercaseString];
	if (cacheControl) {
		if ([cacheControl isEqualToString:@"no-cache"] || [cacheControl isEqualToString:@"no-store"]) {
			return NO;
		}
	}
	NSString *pragma = [[[request responseHeaders] objectForKey:@"Pragma"] lowercaseString];
	if (pragma) {
		if ([pragma isEqualToString:@"no-cache"]) {
			return NO;
		}
	}
	return YES;
}

// Borrowed from: http://stackoverflow.com/questions/652300/using-md5-hash-on-a-string-in-cocoa
+ (NSString *)keyForRequest:(CSASIHTTPRequest *)request
{
	const char *cStr = [[[request url] absoluteString] UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]]; 	
}

+ (NSDateFormatter *)rfc1123DateFormatter
{
	NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = [threadDict objectForKey:@"CSASIDownloadCacheDateFormatter"];
	if (dateFormatter == nil) {
		dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss 'GMT'"];
		[threadDict setObject:dateFormatter forKey:@"CSASIDownloadCacheDateFormatter"];
	}
	return dateFormatter;
}


@synthesize storagePath;
@synthesize defaultCachePolicy;
@synthesize accessLock;
@synthesize shouldRespectCacheControlHeaders;
@end
