//  TwitterTweetPoster.h

#import <Foundation/Foundation.h>

#import "TwitterRequest.h"

@class TwitterTweetPoster;
@class TwitterConsumer;
@class TwitterToken;

@protocol TwitterTweetPosterDelegate <NSObject>
- (void) twitterTweetPosterDidSucceed: (TwitterTweetPoster*) twitterTweetPoster;
- (void) twitterTweetPoster: (TwitterTweetPoster*) twitterTweetPoster didFailWithError: (NSError*) error;
@end

@interface TwitterTweetPoster : NSObject <TwitterRequestDelegate> {
  @private
	TwitterConsumer* _consumer;
	TwitterToken* _token;
	id<TwitterTweetPosterDelegate> _delegate;
	NSString* _message;
  @private
	TwitterRequest* _request;
}

@property (nonatomic,retain) TwitterConsumer* consumer;
@property (nonatomic,retain) TwitterToken* token;
@property (nonatomic,retain) id<TwitterTweetPosterDelegate> delegate;
@property (nonatomic,retain) NSString* message;

- (void) execute;
- (void) cancel;

@end
