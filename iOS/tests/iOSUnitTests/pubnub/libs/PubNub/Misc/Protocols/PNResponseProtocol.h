#import <Foundation/Foundation.h>


#pragma mark Protocol declaration

@protocol PNResponseProtocol <NSObject>

@required

/**
 * Allow to check whether response was sent from server with marking that connection will be closed or not
 */
- (BOOL)isLastResponseOnConnection;

#pragma mark -


@end