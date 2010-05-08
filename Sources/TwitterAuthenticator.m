/*
 * (C) Copyright 2010, Stefan Arentz, Arentz Consulting Inc.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "TwitterConsumer.h"
#import "TwitterToken.h"
#import "TwitterRequest.h"
#import "TwitterAuthenticator.h"

@implementation TwitterAuthenticator

#pragma mark -

@synthesize
	consumer = _consumer,
	username = _username,
	password = _password,
	delegate = _delegate;

#pragma mark -

- (id) init
{
	if ((self = [super init]) != nil) {
	}
	return self;
}

- (void) dealloc
{
	[_twitterRequest release];
	[_consumer release];
	[_username release];
	[_password release];
	[super dealloc];
}

#pragma mark -

- (NSString*) _formEncodeString: (NSString*) string
{
   NSString* encoded = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
   return [encoded autorelease];
}

- (NSString*) _formDecodeString: (NSString*) string
{
	NSString* decoded = (NSString*) CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef) string, NULL);
	return [decoded autorelease];
}

#pragma mark -

- (void) authenticate
{
	if (_twitterRequest == nil)
	{
		NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
			_username, @"x_auth_username",
			_password, @"x_auth_password",
			@"client_auth", @"x_auth_mode",
			nil];

		_twitterRequest = [TwitterRequest new];

		_twitterRequest.url = [NSURL URLWithString: @"https://api.twitter.com/oauth/access_token"];
		_twitterRequest.twitterConsumer = _consumer;
		_twitterRequest.method = @"POST";
		_twitterRequest.parameters = parameters;
		_twitterRequest.delegate = self;
		
		[_twitterRequest execute];
	}
}

- (void) cancel
{
	if (_twitterRequest != nil) {
		[_twitterRequest release];
		_twitterRequest = nil;
	}
}

#pragma mark -

- (void) twitterRequest: (TwitterRequest*) request didFailWithError: (NSError*) error
{
	[_delegate twitterAuthenticator: self didFailWithError: error];
	
	[_twitterRequest release];
	_twitterRequest = nil;
}

- (void) twitterRequest:(TwitterRequest *)request didFinishLoadingData: (NSData*) data
{
	// Get the response data as a string
	
	NSString* response = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	if (response == nil) {
		response = [[[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] autorelease];
	}
	
	if (response == nil) {
		// TODO: Real error handling
		[_delegate twitterAuthenticator: self didFailWithError: nil];
		return;
	}
	
	// Parse the response into name/value pairs into a dictionary	
	
	NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
	
	NSArray* pairs = [response componentsSeparatedByString: @"&"];
	for (NSString* pair in pairs)
	{
		NSArray* nameValue = [pair componentsSeparatedByString: @"="];
		if ([nameValue count] == 2)
		{
			[parameters setValue: [self _formDecodeString: [nameValue objectAtIndex: 1]] forKey: [nameValue objectAtIndex: 0]];
		}
	}
	
	// Call the delegate with the token or with an error if we could not parse the token values
	
	NSString* tokenValue = [parameters valueForKey: @"oauth_token"];
	NSString* tokenSecret = [parameters valueForKey: @"oauth_token_secret"];
	
	if (tokenValue != nil && tokenSecret != nil) {
		TwitterToken* token = [[[TwitterToken alloc] initWithToken: tokenValue secret: tokenSecret] autorelease];
		[_delegate twitterAuthenticator: self didSucceedWithToken: token];
	} else {
		// TODO: Real error handling
		[_delegate twitterAuthenticator: self didFailWithError: nil];
	}

	// Release all our resources

	[_twitterRequest release];
	_twitterRequest = nil;
}

@end