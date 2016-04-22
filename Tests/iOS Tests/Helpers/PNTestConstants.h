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

static NSTimeInterval const kPNPublishTimeout = 5.0;
static NSTimeInterval const kPNSizeOfMessageTimeout = 5.0;
static NSTimeInterval const kPNTimeTokenTimeout = 5.0;

#endif /* PNTestConstants_h */
