//
//  PNChannelCell.m
//  pubnub
//
//  Created by Sergey Mamontov on 02/06/13.
//
//

#import "PNObjectCell.h"
#import "PNNumberBadgeView.h"
#import "PNDataManager.h"
#import "PNChannel.h"


#pragma mark Private methods declaration

@interface PNObjectCell ()


#pragma mark - Instance methods

/**
 Initialize and prepare badge view (will be placed as accessory view).
 */
- (void)prepareBadgeView;

/**
 If badge view has been created before, it will be removed.
 */
- (void)destroyBadgeView;

#pragma mark -


@end


#pragma mark - Public interface methods

@implementation PNObjectCell


#pragma mark - Instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.textLabel.highlightedTextColor = [UIColor colorWithWhite:0.26f alpha:1.0f];
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:0.68f];
        
        self.showBadge = YES;
    }
    
    
    return self;
}

- (void)prepareForReuse {
    
    [((PNNumberBadgeView *)self.accessoryView) updateIntegerBadgeValueTo:0];
    self.textLabel.text = nil;
}

- (void)prepareBadgeView {
    
    self.accessoryView = [PNNumberBadgeView new];
    ((PNNumberBadgeView *)self.accessoryView).hideWithEmptyOrZeroValue = YES;
}

- (void)destroyBadgeView {
    
    self.accessoryView = nil;
}

- (void)setShowBadge:(BOOL)showBadge {
    
    BOOL isStateChanged = _showBadge != showBadge;
    _showBadge = showBadge;
    
    if (isStateChanged) {
        
        if (showBadge) {
            
            [self prepareBadgeView];
        }
        else {
            
            [self destroyBadgeView];
        }
    }
}

- (void)updateForObject:(id <PNChannelProtocol>)object {

    NSUInteger eventsCount = [[PNDataManager sharedInstance] numberOfEventsForChannel:object];
    if (eventsCount > 0 && self.shouldShowBadge) {
        
        [((PNNumberBadgeView *)self.accessoryView) updateIntegerBadgeValueTo:eventsCount];
    }
    else {
        
        [((PNNumberBadgeView *)self.accessoryView) updateIntegerBadgeValueTo:0];
    }
    
    if ([object isKindOfClass:[PNChannelGroup class]] || [object isKindOfClass:[PNChannelGroupNamespace class]]) {
        
        self.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                               object.name, ([object isKindOfClass:[PNChannelGroupNamespace class]] ? @"(NS)" : @"(CG)")];
    }
    else {
        
        self.textLabel.text = object.name;
    }
}

#pragma mark -


@end
