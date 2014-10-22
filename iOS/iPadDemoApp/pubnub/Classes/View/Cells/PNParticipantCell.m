//
//  PNParticipantCell.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/26/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNParticipantCell.h"
#import "PNTextBadgeView.h"


#pragma mark - Public interface implementation

@implementation PNParticipantCell


#pragma mark - Instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.94f alpha:1.0f];
        
        self.accessoryView = [PNTextBadgeView new];
        ((PNTextBadgeView *)self.accessoryView).hideWithEmptyOrZeroValue = YES;
    }
    
    
    return self;
}

- (void)prepareForReuse {
    
    [((PNTextBadgeView *)self.accessoryView) updateBadgeValueTo:nil];
    self.textLabel.text = nil;
}

- (void)updateForParticipant:(PNClient *)participant {
    
    self.textLabel.text = participant.identifier;
    if ([[participant stateForChannel:participant.channel] count]) {
        
        [((PNTextBadgeView *)self.accessoryView) updateBadgeValueTo:@"S"];
    }
    else {
        
        [((PNTextBadgeView *)self.accessoryView) updateBadgeValueTo:nil];
    }
}

#pragma mark -


@end
