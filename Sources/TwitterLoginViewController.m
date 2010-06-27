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

#import "TwitterAuthenticator.h"
#import "TwitterLoginViewController.h"

@implementation TwitterLoginViewController

@synthesize consumer = _consumer, delegate = _delegate;

- (void) _hideLoginForm
{
	_usernameLabel.hidden = YES;
	_usernameTextField.hidden = YES;
	_passwordLabel.hidden = YES;
	_passwordTextField.hidden = YES;
	_createAccountButton.hidden = YES;
	
	[_usernameTextField resignFirstResponder];
	[_passwordTextField resignFirstResponder];
}

- (void) _showLoginForm
{
	_usernameLabel.hidden = NO;
	_usernameTextField.hidden = NO;
	_passwordLabel.hidden = NO;
	_passwordTextField.hidden = NO;
	_createAccountButton.hidden = NO;
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

- (void) viewDidLoad
{
	[self _hideStatus];

	_loginButton.enabled = NO;

	_containerView.layer.cornerRadius = 15;
	
	self.title = NSLocalizedStringFromTable(@"Login", @"Twitter", @"");
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringFromTable(@"Cancel", @"Twitter", @"")
		style: UIBarButtonItemStylePlain target: self action: @selector(cancel)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedStringFromTable(@"Login", @"Twitter", @"")
		style: UIBarButtonItemStyleDone target: self action: @selector(login)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[_usernameTextField addTarget: self action: @selector(updateLoginButton) forControlEvents: UIControlEventEditingChanged];
	_usernameTextField.placeholder = NSLocalizedStringFromTable(@"Required", @"Twitter", @"");
	
	[_passwordTextField addTarget: self action: @selector(updateLoginButton) forControlEvents: UIControlEventEditingChanged];
	_passwordTextField.placeholder = NSLocalizedStringFromTable(@"Required", @"Twitter", @"");
	
	[_createAccountButton setTitle: NSLocalizedStringFromTable(@"CreateATwitterAccount", @"Twitter", @"") forState: UIControlStateNormal];
	_usernameLabel.text = NSLocalizedStringFromTable(@"Username", @"Twitter", @"");
	_passwordLabel.text = NSLocalizedStringFromTable(@"Password", @"Twitter", @"");
	_statusLabel.text = NSLocalizedStringFromTable(@"SigningIn", @"Twitter", @"");
}

#pragma mark -

- (IBAction) cancel
{
	[_delegate twitterLoginViewControllerDidCancel: self];
}

- (IBAction) login
{
	[self _hideLoginForm];
	[self _showStatus];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;

	if (_authenticator == nil) {
		_authenticator = [TwitterAuthenticator new];
	}

  _authenticator.consumer = _consumer;
  _authenticator.username = _usernameTextField.text;
  _authenticator.password = _passwordTextField.text;
  _authenticator.delegate = self;

  [_authenticator authenticate];
}

- (IBAction) createAccount
{
}

#pragma mark -

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	if (textField == _usernameTextField) {
		[_passwordTextField becomeFirstResponder];
	}
	
	if (textField == _passwordTextField) {
		NSLog(@"Logging in");
	}
	
	return YES;
}

- (void) updateLoginButton
{
	NSLog(@"Yay");
	self.navigationItem.rightBarButtonItem.enabled = ([_usernameTextField.text length] != 0 && [_passwordTextField.text length] != 0);
}

#pragma mark -

- (void) twitterAuthenticator: (TwitterAuthenticator*) twitterAuthenticator didFailWithError: (NSError*) error;
{
	NSLog(@"TwitterAuthenticatorViewController#twitterAuthenticator: %@ didFailWithError: %@", twitterAuthenticator, error);

	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self _showLoginForm];
	[self _hideStatus];

	[_delegate twitterLoginViewController: self didFailWithError: error];
}

- (void) twitterAuthenticator: (TwitterAuthenticator*) twitterAuthenticator didSucceedWithToken: (TwitterToken*) token
{
	NSLog(@"TwitterAuthenticatorViewController#twitterAuthenticator: %@ didSucceedWithToken: %@", twitterAuthenticator, token);

	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self _showLoginForm];
	[self _hideStatus];

	[_delegate twitterLoginViewController: self didSucceedWithToken: token];
}

#pragma mark -

- (void) dealloc
{
	[_authenticator release];
	[super dealloc];
}

@end