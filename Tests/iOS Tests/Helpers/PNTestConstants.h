//
//  PNTestConstants.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <Foundation/Foundation.h>

#ifndef PNTestConstants_h
#define PNTestConstants_h

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

static NSTimeInterval const kPNDefaultTimeout = 5.0;
static NSTimeInterval const kPNPublishTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNSizeOfMessageTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNTimeTokenTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNChannelGroupChangeTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNSubscribeTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNUnsubscribeTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNSetClientStateTimeout = kPNDefaultTimeout;
static NSTimeInterval const kPNHistoryTimeout = kPNDefaultTimeout;

#endif /* PNTestConstants_h */
