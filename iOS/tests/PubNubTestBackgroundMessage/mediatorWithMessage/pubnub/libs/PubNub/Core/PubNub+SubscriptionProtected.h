#import "PubNub+Subscription.h"

/**
 Category used to populate some protected methods to other base class categories and class itself.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (SubscriptionProtected)


#pragma mark - Class methods

/**
 Designated methods with full set of parameters which allow to configure subscription process and client state 
 modification.
 
 @param channelsAndGroups List of \b PNChannel and \b PNChannelGroup instances on which client should subscribe.
 @param shouldCatchUp     If set to \c YES client will use last time token to catchup on previous messages on channels 
                          at which client subscribed at this moment.
 @param clientState       Reference on \a NSDictionary which hold information which should be bound to the client 
                          during his subscription session to target channels.
 @param handlerBlock      Handler block which is called by \b PubNub client when subscription process state changes. 
                          Block pass three arguments: \c state - one of \b PNSubscriptionProcessState fields; 
                          \c channels - list of \b PNChannel instances for which subscription process changes state; 
                          \c subscriptionError - \b PNError instance which hold information about why subscription 
                          process failed. Always check \a error.code to find out what caused error (check PNErrorCodes 
                          header file and use \a -localizedDescription / \a -localizedFailureReason and 
                          \a -localizedRecoverySuggestion to get human readable description for error).
 */
+ (void)         subscribeOn:(NSArray *)channelsAndGroups withCatchUp:(BOOL)shouldCatchUp
                 clientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Designated methods with full set of parameters which allow to configure subscription process and client state 
 modification.
 
 @param channelsAndGroups List of \b PNChannel and \b PNChannelGroup instances on which client should subscribe.
 @param shouldCatchUp     If set to \c YES client will use last time token to catchup on previous messages on channels 
                          at which client subscribed at this moment.
 @param clientState       Reference on \a NSDictionary which hold information which should be bound to the client 
                          during his subscription session to target channels.
 @param handlerBlock      Handler block which is called by \b PubNub client when subscription process state changes. 
                          Block pass three arguments: \c state - one of \b PNSubscriptionProcessState fields; 
                          \c channels - list of \b PNChannel instances for which subscription process changes state; 
                          \c subscriptionError - \b PNError instance which hold information about why subscription 
                          process failed. Always check \a error.code to find out what caused error (check PNErrorCodes 
                          header file and use \a -localizedDescription / \a -localizedFailureReason and 
                          \a -localizedRecoverySuggestion to get human readable description for error).
 */
- (void)         subscribeOn:(NSArray *)channelsAndGroups withCatchUp:(BOOL)shouldCatchUp
                 clientState:(NSDictionary *)clientState
  andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock;


#pragma mark - Misc methods

/**
 * This method will notify delegate about that subscription failed with error.
 
 @param error
 \b PNError instance which hold information about what exactly went wrong during subscription process.
 
 @param shouldCompleteLockingOperation
 Whether procedural lock should be released after delegate notification or not.
 */
- (void)notifyDelegateAboutSubscriptionFailWithError:(PNError *)error
                            completeLockingOperation:(BOOL)shouldCompleteLockingOperation;

#pragma mark -


@end
