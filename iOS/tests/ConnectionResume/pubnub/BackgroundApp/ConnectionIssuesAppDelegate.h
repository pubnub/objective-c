

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
    NSNumber *shouldResubscribeOnConnectionRestore;
	int connectionCount;
	int messageSendingDidFailNotificationCount;
	int didSendMessageDelegateCount;
	int didReceiveMessageCount;

	int clientDidDisconnectFromOriginNotificationCount;
	int clientConnectionDidFailWithErrorNotificationCount;
	int didDisconnectFromOriginCountWithError;
	int willDisconnectWithError;
}

@property (nonatomic, strong) UIWindow *window;
@property NSNumber *resetTimeTokenCount;
@property NSString *lastTimeToken;


-(void)addMessagetoLog:(NSString*)message;

@end
