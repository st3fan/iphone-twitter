// TestViewController.m

#import "TwitterToken.h"
#import "TwitterConsumer.h"

#import "TwitterLoginViewController.h"
#import "TwitterComposeViewController.h"

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
	TwitterComposeViewController* twitterComposeViewController = [[TwitterComposeViewController new] autorelease];
	if (twitterComposeViewController != nil)
	{
		twitterComposeViewController.consumer = _consumer;
		twitterComposeViewController.token = _token;
		twitterComposeViewController.message = @"I like Cheese";
		twitterComposeViewController.delegate = self;

		UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController: twitterComposeViewController] autorelease];
		if (navigationController != nil) {
			[self presentModalViewController: navigationController animated: YES];
		}
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

			UINavigationController* navigationController = [[[UINavigationController alloc] initWithRootViewController: twitterLoginViewController] autorelease];
			if (navigationController != nil) {
				[self presentModalViewController: navigationController animated: YES];
			}
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

	TwitterComposeViewController* twitterComposeViewController = [[TwitterComposeViewController new] autorelease];
	if (twitterComposeViewController != nil)
	{
		twitterComposeViewController.consumer = _consumer;
		twitterComposeViewController.token = _token;
		twitterComposeViewController.message = @"I like Cheese";
		twitterComposeViewController.delegate = self;
		
		[twitterLoginViewController.navigationController pushViewController: twitterComposeViewController animated: YES];
	}
}

- (void) twitterLoginViewController: (TwitterLoginViewController*) twitterLoginViewController didFailWithError: (NSError*) error
{
	NSLog(@"twitterLoginViewController: %@ didFailWithError: %@", self, error);
}

#pragma mark -

- (void) twitterComposeViewControllerDidCancel: (TwitterComposeViewController*) twitterComposeViewController
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterComposeViewControllerDidSucceed: (TwitterComposeViewController*) twitterComposeViewController
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

- (void) twitterComposeViewController: (TwitterComposeViewController*) twitterComposeViewController didFailWithError: (NSError*) error
{
	[twitterComposeViewController dismissModalViewControllerAnimated: YES];
}

#pragma mark -

- (void) dealloc
{
	[_consumer release];
	[_token release];
	[super dealloc];
}

@end
