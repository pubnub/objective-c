//
//  PNClientTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/20/16.
//
//

#import <BeKindRewind/BeKindRewind.h>
#import <PubNub/PubNub.h>

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

@interface PNClientTestCase : BKRTestCase

@property (nonatomic, strong, readonly) PNConfiguration *configuration;
@property (nonatomic, strong, readonly) PubNub *client;

- (PNConfiguration *)clientConfiguration;



@end
