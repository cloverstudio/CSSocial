/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CSSBJsonStreamParserState.h"
#import "CSSBJsonStreamParser.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state = nil; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}

@implementation CSSBJsonStreamParserState

+ (id)sharedInstance { return nil; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return NO;
}

- (CSSBJsonStreamParserStatus)parserShouldReturn:(CSSBJsonStreamParser*)parser {
	return CSSBJsonStreamParserWaitingForData;
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {}

- (BOOL)needKey {
	return NO;
}

- (NSString*)name {
	return @"<aaiie!>";
}

- (BOOL)isError {
    return NO;
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateStart

SINGLETON

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_start || token == sbjson_token_object_start;
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {

	CSSBJsonStreamParserState *state = nil;
	switch (tok) {
		case sbjson_token_array_start:
			state = [CSSBJsonStreamParserStateArrayStart sharedInstance];
			break;

		case sbjson_token_object_start:
			state = [CSSBJsonStreamParserStateObjectStart sharedInstance];
			break;

		case sbjson_token_array_end:
		case sbjson_token_object_end:
			if (parser.supportMultipleDocuments)
				state = parser.state;
			else
				state = [CSSBJsonStreamParserStateComplete sharedInstance];
			break;

		case sbjson_token_eof:
			return;

		default:
			state = [CSSBJsonStreamParserStateError sharedInstance];
			break;
	}


	parser.state = state;
}

- (NSString*)name { return @"before outer-most array or object"; }

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateComplete

SINGLETON

- (NSString*)name { return @"after outer-most array or object"; }

- (CSSBJsonStreamParserStatus)parserShouldReturn:(CSSBJsonStreamParser*)parser {
	return CSSBJsonStreamParserComplete;
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateError

SINGLETON

- (NSString*)name { return @"in error"; }

- (CSSBJsonStreamParserStatus)parserShouldReturn:(CSSBJsonStreamParser*)parser {
	return CSSBJsonStreamParserError;
}

- (BOOL)isError {
    return YES;
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateObjectStart

SINGLETON

- (NSString*)name { return @"at beginning of object"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_string:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateObjectGotKey

SINGLETON

- (NSString*)name { return @"after object key"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_keyval_separator;
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateObjectSeparator sharedInstance];
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateObjectSeparator

SINGLETON

- (NSString*)name { return @"as object value"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_start:
		case sbjson_token_array_start:
		case sbjson_token_true:
		case sbjson_token_false:
		case sbjson_token_null:
		case sbjson_token_number:
		case sbjson_token_string:
			return YES;
			break;

		default:
			return NO;
			break;
	}
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateObjectGotValue sharedInstance];
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateObjectGotValue

SINGLETON

- (NSString*)name { return @"after object value"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateObjectNeedKey sharedInstance];
}


@end

#pragma mark -

@implementation CSSBJsonStreamParserStateObjectNeedKey

SINGLETON

- (NSString*)name { return @"in place of object key"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
    return sbjson_token_string == token;
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateArrayStart

SINGLETON

- (NSString*)name { return @"at array start"; }

- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateArrayGotValue

SINGLETON

- (NSString*)name { return @"after array value"; }


- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_end || token == sbjson_token_separator;
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	if (tok == sbjson_token_separator)
		parser.state = [CSSBJsonStreamParserStateArrayNeedValue sharedInstance];
}

@end

#pragma mark -

@implementation CSSBJsonStreamParserStateArrayNeedValue

SINGLETON

- (NSString*)name { return @"as array value"; }


- (BOOL)parser:(CSSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(CSSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [CSSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

