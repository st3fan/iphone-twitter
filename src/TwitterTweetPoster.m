//  TwitterTweetPoster.m

#import "TwitterToken.h"
#import "TwitterConsumer.h"
#import "TwitterRequest.h"

#import "TwitterTweetPoster.h"

@implementation TwitterTweetPoster

#pragma mark -

@synthesize
	consumer = _consumer,
	token = _token;

#pragma mark -

- (id) init
{
	if ((self = [super init]) != nil) {
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark -

- (void) execute
{
	if (_request == nil)
	{
		NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Hello", @"status",
			nil];

		_request = [TwitterRequest new];

		_request.url = [NSURL URLWithString: @"http://api.twitter.com/1/statuses/update.xml"];
		_request.twitterConsumer = _consumer;
		_request.token = _token;
		_request.method = @"POST";
		_request.parameters = parameters;
		_request.delegate = self;
		
		[_request execute];
	}
}

- (void) cancel
{
	if (_request != nil) {
		[_request cancel];
	}
}

#pragma mark -

- (void) twitterRequest: (TwitterRequest*) request didFailWithError: (NSError*) error
{
	NSLog(@"TwitterTweetPoster Fail");
}

- (void) twitterRequest:(TwitterRequest *)request didFinishLoadingData: (NSData*) data
{
	NSLog(@"TwitterTweetPoster Success");
	
	NSString* string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	NSLog(@"Respnse = %@", string);
}

@end