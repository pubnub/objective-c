

#import <Foundation/Foundation.h>


@interface ConnectionIssuesAppDelegate : UIResponder <UIApplicationDelegate, PNDelegate> {
	NSString *wiFiOnUrl;
	NSString *wiFiOffUrl;
	IBOutlet UITextView *log;
	NSDate *lastWiFiReconnect;
	NSArray *pnChannels;

	NSDate *startSendMessage;
	NSDate *startHistory;
	NSDate *startTimeToken;
	float delta;

	BOOL isPNSubscriptionProcessWillRestoreStateObserver;
	BOOL isPNSubscriptionProcessRestoredStateObserver;
	BOOL isWillRestoreSubscriptionOnChannelsDelegate;
	BOOL isDidRestoreSubscriptionOnChannelsDelegate;
	BOOL isPNClientSubscriptionWillRestoreNotification;
	BOOL isPNClientSubscriptionDidRestoreNotification;
}

@property (nonatomic, strong) UIWindow *window;

-(void)startTest;


@end
