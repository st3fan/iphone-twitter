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

#import "TwitterToken.h"

@implementation TwitterToken

#pragma mark -

@synthesize
	token = _token,
	secret = _secret;
	
#pragma mark -

- (id) initWithToken: (NSString*) token secret: (NSString*) secret
{
	if ((self = [super init]) != nil) {
		_token = [token retain];
		_secret = [secret retain];
	}
	return self;
}

- (void) dealloc
{
	[_token release];
	[_secret release];
	[super dealloc];
}

#pragma mark -

- (id) initWithCoder: (NSCoder*) coder
{
	if ((self = [super init]) != nil) {
		_token = [[coder decodeObjectForKey: @"token"] retain];
		_secret = [[coder decodeObjectForKey: @"secret"] retain];
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder*) coder
{
    [coder encodeObject: _token forKey: @"token"];
    [coder encodeObject: _secret forKey: @"secret"];
}

#pragma mark -

- (NSString*) description
{
	return [NSString stringWithFormat: @"<TwitterToken@0x%x token=%@ secret=%@>", self, _token, _secret];
}

@end