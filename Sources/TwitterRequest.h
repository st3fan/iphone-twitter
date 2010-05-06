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

@class TwitterToken;
@class TwitterRequest;
@class TwitterConsumer;

@protocol TwitterRequestDelegate
- (void) twitterRequest: (TwitterRequest*) request didFailWithError: (NSError*) error;
- (void) twitterRequest:(TwitterRequest *)request didFinishLoadingData: (NSData*) data;
@end

@interface TwitterRequest : NSObject {
  @private
	TwitterConsumer* _twitterConsumer;
	NSDictionary* _parameters;
	TwitterToken* _token;
	NSURL* _url;
	NSURL* _realm;
	NSString* _method;
	id<TwitterRequestDelegate> _delegate;
  @private
	NSURLConnection* _connection;
	NSMutableData* _data;
	NSInteger _statusCode;
}

@property (nonatomic,retain) TwitterConsumer* twitterConsumer;
@property (nonatomic,retain) NSDictionary* parameters;
@property (nonatomic,retain) TwitterToken* token;
@property (nonatomic,retain) NSString* method;
@property (nonatomic,retain) NSURL* url;
@property (nonatomic,retain) NSURL* realm;
@property (nonatomic,assign) id<TwitterRequestDelegate> delegate;

- (void) execute;
- (void) cancel;

@end