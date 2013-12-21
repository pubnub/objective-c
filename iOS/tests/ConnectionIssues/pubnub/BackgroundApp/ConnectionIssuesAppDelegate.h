

#import <Foundation/Foundation.h>


@interface ConnectionIssuesAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate> {
	NSString *wiFiOnUrl;
	NSString *wiFiOffUrl;
	IBOutlet UITextView *log;
	NSDate *lastWiFiReconnect;
}



#pragma mark Properties

@property (nonatomic, strong) UIWindow *window;

#pragma mark -


@end
