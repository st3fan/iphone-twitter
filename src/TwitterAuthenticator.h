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

#import <Foundation/Foundation.h>

#import "TwitterRequest.h"

@class TwitterConsumer;
@class TwitterToken;
@class TwitterAuthenticator;
@class TwitterRequest;

@protocol TwitterAuthenticatorDelegate
- (void) twitterAuthenticator: (TwitterAuthenticator*) twitterAuthenticator didFailWithError: (NSError*) error;
- (void) twitterAuthenticator: (TwitterAuthenticator*) twitterAuthenticator didSucceedWithToken: (TwitterToken*) token;
@end

@interface TwitterAuthenticator : NSObject <TwitterRequestDelegate> {
  @private
	TwitterConsumer* _consumer;
	NSString* _username;
	NSString* _password;
	id<TwitterAuthenticatorDelegate> _delegate;
  @private
    TwitterRequest* _twitterRequest;
}

@property (nonatomic,retain) TwitterConsumer* consumer;

@property (nonatomic,retain) NSString* username;
@property (nonatomic,retain) NSString* password;

@property (nonatomic,assign) id<TwitterAuthenticatorDelegate> delegate;

- (void) authenticate;
- (void) cancel;

@end