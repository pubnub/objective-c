//
//  PNBasicClientTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <JSZVCR/JSZVCR.h>

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

@class PubNub;

@interface PNBasicClientTestCase : JSZVCRTestCase <PNObjectEventListener>

@property (nonatomic) PubNub *client;

@end
