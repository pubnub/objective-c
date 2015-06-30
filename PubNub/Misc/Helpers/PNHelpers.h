/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#ifndef PNHelpers_h
#define PNHelpers_h

#import "PNURLRequest.h"
#import "PNDictionary.h"
#import "PNChannel.h"
#import "PNString.h"
#import "PNArray.h"
#import "PNClass.h"
#import "PNData.h"
#import "PNJSON.h"
#import "PNGZIP.h"


/**
 @brief      GCD async block call wrapper.
 @discussion Wrapper allow to verify whether all passed data not \c nil and can be used with 
             libdispatch.
 
 @param queue Queue on which \c block should be called.
 @param block Reference on user-provided block which should be executed on specified queue.
 
 @since 4.0
 */
extern void pn_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

#endif // PNHelpers_h
