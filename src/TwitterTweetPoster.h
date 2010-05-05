//  TwitterTweetPoster.h

#import <Foundation/Foundation.h>

#import "TwitterRequest.h"

@class TwitterConsumer;
@class TwitterToken;

@interface TwitterTweetPoster : NSObject <TwitterRequestDelegate> {
  @private
	TwitterConsumer* _consumer;
	TwitterToken* _token;
  @private
	TwitterRequest* _request;
}

@property (nonatomic,retain) TwitterConsumer* consumer;
@property (nonatomic,retain) TwitterToken* token;

- (void) execute;
- (void) cancel;

@end
