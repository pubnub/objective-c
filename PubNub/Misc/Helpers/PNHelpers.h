/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#ifndef PNHelpers_h
#define PNHelpers_h

#import "PNLockSupport.h"
#import "PNURLRequest.h"
#import "PNDictionary.h"
#import "PNDefines.h"
#import "PNChannel.h"
#import "PNString.h"
#import "PNNumber.h"
#import "PNArray.h"
#import "PNData.h"
#import "PNJSON.h"
#import "PNGZIP.h"


#pragma mark - GCD helpers

/**
 @brief      GCD async block call wrapper.
 @discussion Wrapper allow to verify whether all passed data not \c nil and can be used with 
             libdispatch.
 
 @param queue Queue on which \c block should be called.
 @param block Reference on user-provided block which should be executed on specified queue.
 
 @since 4.0
 */
extern void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

/**
 @brief      GCD helper for thread-safe access to instance properties/variables.
 @discussion Wrapper take care on passed queue and block validation before trying to access data.
 
 @param queue Queue on which \c block should be called.
 @param block Reference on user-provided block in which access will de done.
 
 @since 4.2.0
 */
extern void pn_safe_property_read(dispatch_queue_t queue, dispatch_block_t block);
extern void pn_safe_property_write(dispatch_queue_t queue, dispatch_block_t block);

#endif // PNHelpers_h
