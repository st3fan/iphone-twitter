//  TwitterTweetPoster.m

#import "TwitterToken.h"
#import "TwitterConsumer.h"
#import "TwitterRequest.h"

#import "TwitterTweetPoster.h"

@implementation TwitterTweetPoster

#pragma mark -

@synthesize consumer = _consumer, token = _token, delegate = _delegate, message = _message;

#pragma mark -

- (id) init
{
	if ((self = [super init]) != nil) {
	}
	return self;
}

- (void) dealloc
{
	[_request release];
	[_delegate release];
	[super dealloc];
}

#pragma mark -

- (void) execute
{
	if (_request == nil)
	{
		_request = [TwitterRequest new];
		if (_request != nil) {
			_request.url = [NSURL URLWithString: @"http://api.twitter.com/1/statuses/update.xml"];
			_request.twitterConsumer = _consumer;
			_request.token = _token;
			_request.method = @"POST";
			_request.parameters = [NSDictionary dictionaryWithObjectsAndKeys: _message, @"status", nil];
			_request.delegate = self;		
			[_request execute];
		}
	}
}

- (void) cancel
{
	if (_request != nil) {
		[_request cancel];
		[_request release];
		_request = nil;
	}
}

#pragma mark -

- (void) twitterRequest: (TwitterRequest*) request didFailWithError: (NSError*) error
{
	[_delegate twitterTweetPoster: self didFailWithError: error];
}

- (void) twitterRequest:(TwitterRequest *)request didFinishLoadingData: (NSData*) data
{
	[_delegate twitterTweetPosterDidSucceed: self];
}

@end