//
//  PNLeaveRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/08/13.
//
//

#import "PNLeaveRequest.h"


#pragma mark Protected interface methods

@interface PNLeaveRequest (Protected)


#pragma mark - Properties

// Stores whether leave request was sent to subscribe
// on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;

#pragma mark -


@end
