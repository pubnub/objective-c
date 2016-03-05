/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNLogger.h"


#pragma mark Interface implementation

@implementation PNLogger


#pragma mark - Message processing

- (void)logMessage:(DDLogMessage *)logMessage {
    
    if ([logMessage->_fileName hasPrefix:@"PN"] || [logMessage->_fileName hasPrefix:@"PubNub"]) {
        
        [[DDTTYLogger sharedInstance] logMessage:logMessage];
    }
}

#pragma mark -


@end
