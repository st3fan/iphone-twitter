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

#import "TwitterAuthenticator.h"

@class TwitterConsumer;
@class TwitterToken;
@class TwitterLoginViewController;

@protocol TwitterLoginViewControllerDelegate
- (void) twitterLoginViewControllerDidCancel: (TwitterLoginViewController*) twitterLoginViewController;
- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didSucceedWithToken: (TwitterToken*) token;
- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didFailWithError: (NSError*) error;
@end

@interface TwitterLoginViewController : UIViewController <UITextFieldDelegate,TwitterAuthenticatorDelegate> {
  @private
	TwitterConsumer* _consumer;
    id<TwitterLoginViewControllerDelegate> _delegate;
  @private
	UIBarButtonItem* _loginButton;
	IBOutlet UIView* _containerView;
	IBOutlet UITextField* _usernameTextField;
	IBOutlet UILabel* _usernameLabel;
	IBOutlet UITextField* _passwordTextField;
	IBOutlet UILabel* _passwordLabel;
	IBOutlet UILabel* _statusLabel;
	IBOutlet UIActivityIndicatorView* _activityIndicatorView;
	IBOutlet UIButton* _createAccountButton;
  @private
	TwitterAuthenticator* _authenticator;
}

- (IBAction) cancel;
- (IBAction) login;
- (IBAction) createAccount;

@property (nonatomic,retain) TwitterConsumer* consumer;
@property (nonatomic,assign) id<TwitterLoginViewControllerDelegate> delegate;

@end