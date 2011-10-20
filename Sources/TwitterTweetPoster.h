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
	id<TwitterTweetPosterDelegate> __unsafe_unretained _delegate;
	NSString* _message;
  @private
	TwitterRequest* _request;
}

@property (nonatomic,strong) TwitterConsumer* consumer;
@property (nonatomic,strong) TwitterToken* token;
@property (nonatomic,unsafe_unretained) id<TwitterTweetPosterDelegate> delegate;
@property (nonatomic,strong) NSString* message;

- (void) execute;
- (void) cancel;

@end
