//
//  PNParticipantCell.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface PNParticipantCell : UITableViewCell


#pragma mark - Instance methods

/**
 Update cell layout for concrete participant.
 
 @param participant
 \b PNClient instance which will describe current participant.
 */
- (void)updateForParticipant:(PNClient *)participant;

#pragma mark -


@end
