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

#import <QuartzCore/QuartzCore.h>

#import "TwitterConsumer.h"
#import "TwitterToken.h"
#import "TwitterTweetPoster.h"
#import "TwitterComposeViewController.h"

@implementation TwitterComposeViewController

@synthesize delegate = _delegate, token = _token, message = _message, consumer = _consumer;

#pragma mark -

- (void) _hideComposeForm
{
	_textView.hidden = YES;
	_charactersLeftLabel.hidden = YES;
	
	[_textView resignFirstResponder];
}

- (void) _showComposeForm
{
	_textView.hidden = NO;
	_charactersLeftLabel.hidden = NO;
}

- (void) _hideStatus
{
	_activityIndicatorView.hidden = YES;
	[_activityIndicatorView stopAnimating];
	_statusLabel.hidden = YES;
}

- (void) _showStatus
{
	_activityIndicatorView.hidden = NO;
	[_activityIndicatorView startAnimating];
	_statusLabel.hidden = NO;
}

#pragma mark -

- (IBAction) close
{
	@try {
		[_delegate twitterComposeViewControllerDidCancel: self];
	} @catch (NSException* exception) {
		NSLog(@"TwitterComposeViewController caught an unexpected exception while calling the delegate: %@", exception);
	}
}

- (IBAction) send
{
	if ([_textView.text length] > 140)
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"The tweet is too long" message: @"Twitter messages can only be up to 140 characters long." delegate: nil
			cancelButtonTitle: @"OK" otherButtonTitles: nil];
		if (alertView != nil) {
			[alertView show];
			[alertView release];
		}
	}
	else
	{
		[self _hideComposeForm];
		[self _showStatus];
	
		_tweetPoster = [TwitterTweetPoster new];
		if (_tweetPoster != nil) {
			_tweetPoster.consumer = _consumer;
			_tweetPoster.token = _token;
			_tweetPoster.delegate = self;
			_tweetPoster.message = _textView.text;
			[_tweetPoster execute];
		}
	}
}

#pragma mark -

- (void) updateCharactersLeftLabel
{
	NSInteger count = 140 - [_textView.text length];

	if (count < 0) {
		_charactersLeftLabel.textColor = [UIColor redColor];
	} else {
		_charactersLeftLabel.textColor = [UIColor grayColor];
	}

	_charactersLeftLabel.text = [NSString stringWithFormat: @"%d", count];
}

#pragma mark -

- (void) viewDidLoad
{
	_containerView.layer.cornerRadius = 10;

	[self _showComposeForm];
	[self _hideStatus];

	_textView.text = _message;
	_textView.delegate = self;
	
	[self updateCharactersLeftLabel];
	
	self.title = @"Compose";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Close" style: UIBarButtonItemStylePlain target: self action: @selector(close)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Send" style: UIBarButtonItemStyleDone target: self action: @selector(send)];
}

- (void) viewWillAppear: (BOOL) animated
{
	[_textView becomeFirstResponder];
}

#pragma mark -

- (void) textViewDidChange: (UITextView*) textView
{
	[self updateCharactersLeftLabel];
}

#pragma mark -

- (void) twitterTweetPosterDidSucceed: (TwitterTweetPoster*) twitterTweetPoster
{
	[_delegate twitterComposeViewControllerDidSucceed: self];
}

- (void) twitterTweetPoster: (TwitterTweetPoster*) twitterTweetPoster didFailWithError: (NSError*) error
{
	[_delegate twitterComposeViewController: self didFailWithError: error];
}

@end