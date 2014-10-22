//
//  NSInvocation+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import <Foundation/Foundation.h>


@interface NSInvocation (PNAdditions)


#pragma mark Class methods

/**
 * Returns reference on fully configured invocation instance
 */
+ (NSInvocation *)pn_invocationForObject:(id)targetObject selector:(SEL)selector
                     retainsArguments:(BOOL)shouldRetainArguments, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSInvocation *)pn_invocationForObject:(id)targetObject selector:(SEL)selector
                        retainsArguments:(BOOL)shouldRetainArguments parameters:(NSArray *)parameters;

#pragma mark -


@end
