//
//  PNError+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/08/13.
//
//

#import "PNError.h"


#pragma mark Protected interface methods

@interface PNError (Protected)

// Stores reference on associated object with which
// error is occurred
@property (nonatomic, strong) id associatedObject;


#pragma mark - Instance methods

/**
 @brief Force associated object change (setter overwritten to protect initial data).
 
 @param object Object with which stored data should be replaced.
 
 @since <#version number#>
 */
- (void)replaceAssociatedObject:(id)object;

#pragma mark -


@end
