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
#import "TwitterUtils.h"

@implementation TwitterRequest

#pragma mark -

@synthesize
	twitterConsumer = _twitterConsumer,
	parameters = _parameters,
	token = _token,
	method = _method,
	url = _url,
	realm = _realm,
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
	[super dealloc];
}

#pragma mark -

- (NSString*) _generateTimestamp
{
	return [NSString stringWithFormat: @"%d", time(NULL)];
}

- (NSString*) _generateNonce
{
	NSString* nonce = nil;

	CFUUIDRef uuid = CFUUIDCreate(nil);
	if (uuid != NULL) {
		nonce = (NSString*) CFUUIDCreateString(nil, uuid);
		CFRelease(uuid);
	}
    
    return [nonce autorelease];
}

- (NSString*) _formEncodeString: (NSString*) string
{
	NSString* encoded = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
		(CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [encoded autorelease];
}

#pragma mark -

- (void) execute
{
	if (_connection == nil)
	{
		_data = [NSMutableData new];
	
		NSString* timestamp = [self _generateTimestamp];
		NSString* nonce = [self _generateNonce];
	
		// Build a dictionary with all the parameters (oauth_* and call specific)

		NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary: _parameters];

		[parameters setValue: _twitterConsumer.key forKey: @"oauth_consumer_key"];
		[parameters setValue: @"HMAC-SHA1" forKey: @"oauth_signature_method"];
		[parameters setValue: timestamp forKey: @"oauth_timestamp"];
		[parameters setValue: nonce forKey: @"oauth_nonce"];
		[parameters setValue: @"1.0" forKey: @"oauth_version"];
				
		if (_token != nil) {
			[parameters setValue: _token.token forKey: @"oauth_token"];
		}
		
		// Build the request string
		
		NSMutableString* normalizedRequestParameters = [NSMutableString string];
		
		for (NSString* key in [[parameters allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)])
		{
			if ([normalizedRequestParameters length] != 0) {
				[normalizedRequestParameters appendString: @"&"];
			}
			
			[normalizedRequestParameters appendString: key];
			[normalizedRequestParameters appendString: @"="];
			[normalizedRequestParameters appendString: [self _formEncodeString: [parameters objectForKey: key]]];
		}
		
		NSLog(@"XXX normalizedRequestParameters = %@", normalizedRequestParameters);
		
		// Create the signature base string
		
		NSString* signatureBaseString = [NSString stringWithFormat: @"%@&%@&%@", _method,
			[self _formEncodeString: [NSString stringWithFormat: @"%@://%@%@", [_url scheme], [_url host], [_url path]]],
				[self _formEncodeString: normalizedRequestParameters]];

		NSLog(@"XXX signatureBaseString = %@", signatureBaseString);

		// Create the secret
		
		NSString* secret = nil;
		
		if (_token != nil) {
			secret = [NSString stringWithFormat:@"%@&%@", [self _formEncodeString: _twitterConsumer.secret], [self _formEncodeString: _token.secret]];
		} else {
			secret = [NSString stringWithFormat:@"%@&", [self _formEncodeString: _twitterConsumer.secret]];
		}
		
		NSLog(@"XXX Secret = %@", secret);
		
		// Set the signature parameter
		
		NSString* signatureString = [TwitterUtils encodeData:
			[TwitterUtils generateSignatureOverString: signatureBaseString withSecret: [secret dataUsingEncoding: NSASCIIStringEncoding]]];

		// Add the signature to the request parameters (just the call specific ones)
				
		normalizedRequestParameters = [NSMutableString string];
		
		for (NSString* key in [[_parameters allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)])
		{
			if ([normalizedRequestParameters length] != 0) {
				[normalizedRequestParameters appendString: @"&"];
			}
			
			[normalizedRequestParameters appendString: key];
			[normalizedRequestParameters appendString: @"="];
			[normalizedRequestParameters appendString: [self _formEncodeString: [_parameters objectForKey: key]]];
		}
		
		NSLog(@"XXX POST Data = %@", normalizedRequestParameters);
		
		NSData* requestData = [normalizedRequestParameters dataUsingEncoding: NSUTF8StringEncoding];
		
		// Setup the Authorization header

		NSMutableDictionary* authorizationParameters = [NSMutableDictionary dictionary];

		[authorizationParameters setValue: nonce forKey: @"oauth_nonce"];
		[authorizationParameters setValue: timestamp forKey: @"oauth_timestamp"];
		[authorizationParameters setValue: signatureString forKey: @"oauth_signature"];
		[authorizationParameters setValue: @"HMAC-SHA1" forKey: @"oauth_signature_method"];
		[authorizationParameters setValue: @"1.0" forKey: @"oauth_version"];
		[authorizationParameters setValue: _twitterConsumer.key forKey: @"oauth_consumer_key"];
		
		if (_token != nil) {
			[authorizationParameters setValue: _token.token forKey: @"oauth_token"];			
		}

		NSMutableString* authorization = [NSMutableString stringWithString: @"OAuth realm=\"\""];
		
		for (NSString* key in [authorizationParameters allKeys])
		{
//			if ([authorization length] > 10) {
				[authorization appendString: @", "];
//			}
			
			[authorization appendString: key];
			[authorization appendString: @"="];
			[authorization appendString: @"\""];
			[authorization appendString: [self _formEncodeString: [authorizationParameters objectForKey: key]]];
			[authorization appendString: @"\""];
		}
		
		NSLog(@"Authorization: %@", authorization);
		
		// Setup the request and connection

		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: _url
			cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: 15.0];

		[request setHTTPMethod: _method];
		[request setHTTPBody: requestData];
		[request setValue: authorization forHTTPHeaderField: @"Authorization"];
        [request setValue: [NSString stringWithFormat: @"%d", [requestData length]] forHTTPHeaderField: @"Content-Length"];
        [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		
		_connection = [[NSURLConnection connectionWithRequest: request delegate: self] retain];
	}
}

- (void) cancel
{
	if (_connection != nil) {
		[_connection cancel];
		[_connection release];
		_connection = nil;
	}
}

#pragma mark -

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
	[_data appendData: data];
}

- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response
{
	_statusCode = [response statusCode];
}

- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
	[_delegate twitterRequest: self didFailWithError: error];

	[_connection release];
	_connection = nil;
	
	[_data release];
	_data = nil;
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
	if (_statusCode != 200) {
		NSLog(@"Request failed with status code %d", _statusCode);
		NSString* response = [[[NSString alloc] initWithData: _data encoding: NSUTF8StringEncoding] autorelease];
		NSLog(@"Response = %@", response);
		// TODO: Real error handling
		[_delegate twitterRequest: self didFailWithError: nil];
	} else {
		[_delegate twitterRequest: self didFinishLoadingData: _data];
	}
	
	[_connection release];
	_connection = nil;
	
	[_data release];
	_data = nil;
}

@end
