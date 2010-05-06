// TestViewController.h

#import <UIKit/UIKit.h>

#import "TwitterLoginViewController.h"
#import "TweetComposeViewController.h"

@class TwitterConsumer;
@class TwitterToken;

@interface TestViewController : UIViewController <TwitterLoginViewControllerDelegate,TweetComposeViewControllerDelegate> {
  @private
	TwitterConsumer* _consumer;
	TwitterToken* _token;
}

- (IBAction) share;
- (IBAction) reset;

@end