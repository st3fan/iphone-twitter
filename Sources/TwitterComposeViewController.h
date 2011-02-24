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

#import <UIKit/UIKit.h>

#import "TwitterTweetPoster.h"

#if defined(TWITTER_USE_URLSHORTENER)
#import "URLShortenerCredentials.h"
#import "URLShortener.h"
#endif

@class TwitterToken;
@class TwitterConsumer;
@class TwitterComposeViewController;

@protocol TwitterComposeViewControllerDelegate
- (void) twitterComposeViewControllerDidCancel: (TwitterComposeViewController*) twitterComposeViewController;
- (void) twitterComposeViewControllerDidSucceed: (TwitterComposeViewController*) twitterComposeViewController;
- (void) twitterComposeViewController: (TwitterComposeViewController*) twitterComposeViewController didFailWithError: (NSError*) error;
@end

@interface TwitterComposeViewController : UIViewController <UITextViewDelegate,TwitterTweetPosterDelegate> {
  @private
	IBOutlet UIView* _containerView;
	IBOutlet UITextView* _textView;
	IBOutlet UILabel* _charactersLeftLabel;
	IBOutlet UILabel* _statusLabel;
	IBOutlet UIActivityIndicatorView* _activityIndicatorView;
  @private
	id<TwitterComposeViewControllerDelegate> _delegate;
	TwitterConsumer* _consumer;
	TwitterToken* _token;
	NSString* _message;
  @private
#if defined(TWITTER_USE_URLSHORTENER)
	BOOL _linkShortenerEnabled;
	URLShortenerCredentials* _linkShortenerCredentials;
#endif
  @private
	TwitterTweetPoster* _tweetPoster;
}

@property (nonatomic,assign) id<TwitterComposeViewControllerDelegate> delegate;
@property (nonatomic,retain) TwitterToken* token;
@property (nonatomic,retain) TwitterConsumer* consumer;
@property (nonatomic,retain) NSString* message;

#if defined(TWITTER_USE_URLSHORTENER)
@property (nonatomic,assign) BOOL linkShortenerEnabled;
@property (nonatomic,retain) URLShortenerCredentials* linkShortenerCredentials;
#endif

- (IBAction) close;
- (IBAction) send;

@end