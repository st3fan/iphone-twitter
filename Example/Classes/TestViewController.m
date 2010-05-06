// TestViewController.m

#import "TwitterToken.h"
#import "TwitterConsumer.h"

#import "TwitterLoginViewController.h"
#import "TweetComposeViewController.h"

#import "TestViewController.h"

@implementation TestViewController

- (void) viewDidLoad
{
	// Replace the key and secret with your own

	_consumer = [[TwitterConsumer alloc] initWithKey: @"KEY" secret: @"SECRET"];
   
	// Try to get the token from the keychain. If it does not exist then we will have to show the login dialog
	// first. In a real application you should store the token in the user's keychain!
	
	NSData* tokenData = [[NSUserDefaults standardUserDefaults] dataForKey: @"Token"];
	if (tokenData != nil)
	{
		_token = (TwitterToken*) [[NSKeyedUnarchiver unarchiveObjectWithData: tokenData] retain];
	}
}

- (void) openTweetComposer
{
	TweetComposeViewController* tweetComposeViewController = [[TweetComposeViewController new] autorelease];
	if (tweetComposeViewController != nil)
	{
		tweetComposeViewController.consumer = _consumer;
		tweetComposeViewController.token = _token;
		tweetComposeViewController.message = @"I like Cheese";
		tweetComposeViewController.delegate = self;
		[self presentModalViewController: tweetComposeViewController animated: YES];
	}
}

- (IBAction) share
{
	if (_token == nil)
	{
		TwitterLoginViewController* twitterLoginViewController = [[TwitterLoginViewController new] autorelease];
		if (twitterLoginViewController != nil)
		{
			twitterLoginViewController.consumer = _consumer;
			twitterLoginViewController.delegate = self;
			[self presentModalViewController: twitterLoginViewController animated: YES];
		}
	}
	else
	{
		[self openTweetComposer];
	}
}

- (IBAction) reset
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"Token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[_token release];
	_token = nil;
}

#pragma mark -

- (void) twitterLoginViewControllerDidCancel: (TwitterLoginViewController*) twitterLoginViewController
{
	[twitterLoginViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didSucceedWithToken: (TwitterToken*) token
{
	_token = [token retain];

	// Save the token to the user defaults

	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: _token] forKey: @"Token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Open the tweet composer and dismiss the login screen

	TweetComposeViewController* tweetComposeViewController = [[TweetComposeViewController new] autorelease];
	if (tweetComposeViewController != nil)
	{
		tweetComposeViewController.consumer = _consumer;
		tweetComposeViewController.token = _token;
		tweetComposeViewController.message = @"I like Cheese";
		tweetComposeViewController.delegate = self;
		[twitterLoginViewController presentModalViewController: tweetComposeViewController animated: YES];
	}

	
	[twitterLoginViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didFailWithError: (NSError*) error
{
	NSLog(@"twitterLoginViewController: %@ didFailWithError: %@", self, error);
}

#pragma mark -

- (void) tweetComposeViewControllerDidCancel: (TweetComposeViewController*) tweetComposeViewController
{
	[tweetComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) tweetComposeViewControllerDidSucceed: (TweetComposeViewController*) tweetComposeViewController
{
	[tweetComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) tweetComposeViewController: (TweetComposeViewController*) tweetComposeViewController didFailWithError: (NSError*) error
{
	[tweetComposeViewController dismissModalViewControllerAnimated: YES];
}

#pragma mark -

- (void) dealloc
{
	[_consumer release];
	[_token release];
	[super dealloc];
}

@end