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

#if defined(TWITTER_USE_URLSHORTENER)
#import "RegexKitLite.h"
#endif

@implementation TwitterComposeViewController

@synthesize delegate = _delegate, token = _token, message = _message, consumer = _consumer;

#if defined(TWITTER_USE_URLSHORTENER)
@synthesize linkShortenerEnabled = _linkShortenerEnabled, linkShortenerCredentials = _linkShortenerCredentials;
#endif

#pragma mark -

- (void) _hideComposeForm
{
	_textView.hidden = YES;
	[_textView resignFirstResponder];

	_charactersLeftLabel.hidden = YES;	
}

- (void) _showComposeForm
{
	_textView.hidden = NO;
	[_textView becomeFirstResponder];

	_charactersLeftLabel.hidden = NO;
}

- (void) _hideStatus
{
	_activityIndicatorView.hidden = YES;
	[_activityIndicatorView stopAnimating];
	_statusLabel.hidden = YES;
}

- (void) _showStatus: (NSString*) status
{
	_statusLabel.text = status;

	_activityIndicatorView.hidden = NO;
	[_activityIndicatorView startAnimating];
	_statusLabel.hidden = NO;
}

#if defined(TWITTER_USE_URLSHORTENER)

#pragma mark -

- (void) shortener: (URLShortener*) shortener didSucceedWithShortenedURL: (NSURL*) shortenedURL
{
	// Replace the first URL in the message. This is terrible code that needs to be replaced with a proper regular expression.

	NSMutableString* message = [NSMutableString string];
	
	for (NSString* word in [_message componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]) {
		if ([word hasPrefix: @"http://"] || [word hasPrefix: @"https://"]) {
			[message appendString: @" "];
			[message appendString: [shortenedURL absoluteString]];
		} else {
			[message appendString: @" "];
			[message appendString: word];
		}
	}
	
	_textView.text = message;
	[self updateCharactersLeftLabel];

	[self _showComposeForm];
	[self _hideStatus];
}

- (void) shortener: (URLShortener*) shortener didFailWithStatusCode: (int) statusCode
{
	[self _showComposeForm];
	[self _hideStatus];
}

- (void) shortener: (URLShortener*) shortener didFailWithError: (NSError*) error
{
	[self _showComposeForm];
	[self _hideStatus];
}

- (void) _shortenLinks
{
	NSURL* url = nil;

	for (NSString* word in [_message componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]) {
		if ([word hasPrefix: @"http://"] || [word hasPrefix: @"https://"]) {
			url = [NSURL URLWithString: word];
			break;
		}
	}
	
	if (url != nil)
	{
		NSLog(@"Shortening link %@", [url absoluteString]);
		
		URLShortener* shortener = [[URLShortener new] autorelease];
		if (shortener != nil)
		{
			shortener.delegate = self;
			shortener.url = url;
			shortener.credentials = _linkShortenerCredentials;
			[shortener execute];
		}
	}
}

- (BOOL) _messageContainsLinks
{
	BOOL messageContainsLinks = NO;
	
	if (_message && [_message length] != 0)
	{
		for (NSString* word in [_message componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]) {
			if ([word hasPrefix: @"http://"] || [word hasPrefix: @"https://"]) {
				messageContainsLinks = YES;
				break;
			}
		}
	}
	
	return messageContainsLinks;
}

#endif

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
			cancelButtonTitle: NSLocalizedStringFromTable(@"OK", @"Twitter", @"") otherButtonTitles: nil];
		if (alertView != nil) {
			[alertView show];
			[alertView release];
		}
	}
	else
	{
		[self _hideComposeForm];
		[self _showStatus: NSLocalizedStringFromTable(@"UpdatingStatus", @"Twitter", @"")];
	
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

	_textView.text = _message;
	_textView.delegate = self;
	
	[self updateCharactersLeftLabel];
	
	self.title = NSLocalizedStringFromTable(@"NewMessage", @"Twitter", @"");
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringFromTable(@"Cancel", @"Twitter", @"")
		style: UIBarButtonItemStylePlain target: self action: @selector(close)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringFromTable(@"Send", @"Twitter", @"")
		style: UIBarButtonItemStyleDone target: self action: @selector(send)];
}

- (void) viewWillAppear: (BOOL) animated
{
#if defined(TWITTER_USE_URLSHORTENER)
	if (_linkShortenerEnabled == YES && [self _messageContainsLinks]) {
		[self _hideComposeForm];
		[self _showStatus: NSLocalizedStringFromTable(@"ShorteningLinks", @"Twitter", @"")];
		[self _shortenLinks];
	} else {
		[self _showComposeForm];
		[self _hideStatus];
	}
#else
	[self _showComposeForm];
	[self _hideStatus];
#endif
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

#pragma mark -

- (void) dealloc
{
	[_tweetPoster release];
	[super dealloc];
}

@end