// TestViewController.h

#import <UIKit/UIKit.h>

#import "TwitterLoginViewController.h"
#import "TwitterComposeViewController.h"

@class TwitterConsumer;
@class TwitterToken;

@interface TestViewController : UIViewController <TwitterLoginViewControllerDelegate,TwitterComposeViewControllerDelegate> {
  @private
	TwitterConsumer* _consumer;
	TwitterToken* _token;
}

- (IBAction) share;
- (IBAction) reset;

@end