//
//  PNAccessRightsInformationCell.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsInformationCell.h"
#import "PNTextBadgeView.h"


#pragma mark Static

/**
 Stores reference on size of the step between two badges.
 */
static CGFloat const kPNBadgeVerticalStep = 8.0f;


#pragma mark - Structures

struct PNAccessRightsDataKeysStruct {
    
    __unsafe_unretained NSString *entrieData;
    __unsafe_unretained NSString *entrieSubdata;
};

static struct PNAccessRightsDataKeysStruct PNAccessRightsDataKeys = {
    
    .entrieData = @"data",
    .entrieSubdata = @"subdata"
};


#pragma mark Private interface declaration

@interface PNAccessRightsInformationCell ()


#pragma mark - Properties

@property (nonatomic, strong) UIView *badgesHolder;
@property (nonatomic, strong) PNTextBadgeView *durationBadge;
@property (nonatomic, strong) PNTextBadgeView *rightsBadge;


#pragma mark - Instance methods

- (void)prepareBadgesHolder;
- (void)updateBadgeHolder;


#pragma mark - Misc methods

/**
 Allow to parse access rights from \b PNAccessRightsInformation instance and provide stringified version.
 
 @param accessRightsInformation
 \b PNAccessRightsInformation instance which stores access rights information for specific object.
 
 @return stringified access rights information.
 */
- (NSString *)stringifiedAccessRights:(PNAccessRightsInformation *)accessRightsInformation;

@end


#pragma mark - Public interface implementation

@implementation PNAccessRightsInformationCell


#pragma mark - Instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // Check whether intialization successful or not
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.94f alpha:1.0f];
        
        [self prepareBadgesHolder];
        self.accessoryView = self.badgesHolder;
    }
    
    
    return self;
}

- (void)prepareForReuse {
    
    [self.durationBadge updateBadgeValueTo:nil];
    [self.rightsBadge updateBadgeValueTo:nil];
}

- (void)prepareBadgesHolder {
    
    self.durationBadge = [PNTextBadgeView new];
    self.durationBadge.hideWithEmptyOrZeroValue = YES;
    CGRect durationBadgeFrame = self.durationBadge.frame;
    durationBadgeFrame.origin = CGPointZero;
    self.durationBadge.frame = durationBadgeFrame;
    durationBadgeFrame.origin = CGPointZero;
    self.rightsBadge = [PNTextBadgeView new];
    self.rightsBadge.hideWithEmptyOrZeroValue = YES;
    CGRect rightsBadgeFrame = self.rightsBadge.frame;
    rightsBadgeFrame.origin.x = (durationBadgeFrame.size.width + kPNBadgeVerticalStep);
    self.rightsBadge.frame = rightsBadgeFrame;
    
    CGRect targetHolderFrame = CGRectUnion(durationBadgeFrame, rightsBadgeFrame);
    
    self.badgesHolder = [[UIView alloc] initWithFrame:targetHolderFrame];
    self.badgesHolder.backgroundColor = [UIColor whiteColor];
    
    [self.badgesHolder addSubview:self.durationBadge];
    [self.badgesHolder addSubview:self.rightsBadge];
}

- (void)updateBadgeHolder {
    
    CGRect durationBadgeFrame = self.durationBadge.frame;
    durationBadgeFrame.origin = CGPointZero;
    self.durationBadge.frame = durationBadgeFrame;
    CGRect rightsBadgeFrame = self.rightsBadge.frame;
    rightsBadgeFrame.origin.x = (durationBadgeFrame.size.width + kPNBadgeVerticalStep);
    self.rightsBadge.frame = rightsBadgeFrame;
    
    CGRect targetHolderFrame = CGRectUnion(durationBadgeFrame, rightsBadgeFrame);
    targetHolderFrame.origin = CGPointZero;
    self.badgesHolder.frame = targetHolderFrame;
    self.accessoryView = self.badgesHolder;
}

- (void)updateWithAccessRightsInformation:(NSDictionary *)information {
    
    PNAccessRightsInformation *data = [information valueForKey:PNAccessRightsDataKeys.entrieData];
    NSMutableString *labelValue = [NSMutableString stringWithString:data.subscriptionKey];
    if (data.level == PNChannelAccessRightsLevel) {
        
        [labelValue setString:data.channel.name];
    }
    else if (data.level == PNUserAccessRightsLevel) {
        
        [labelValue setString:data.authorizationKey];
    }
    
    [labelValue setString:[labelValue truncatedString:30 lineBreakMode:self.textLabel.lineBreakMode]];
    
    if (data.accessPeriodDuration > 0) {
        
        NSMutableString *duration = [NSMutableString string];
        
        NSUInteger hours = (NSUInteger)(data.accessPeriodDuration / 60);
        NSUInteger minutes = (NSUInteger)(data.accessPeriodDuration - hours * 60);
        if (hours > 0) {
            
            [duration appendFormat:@"%d h%@", hours, (minutes > 0 ? @" " : @"")];
        }
        if (minutes > 0) {
            
            [duration appendFormat:@"%d m", minutes];
        }
        
        [self.durationBadge updateBadgeValueTo:duration];
    }
    self.textLabel.text = labelValue;
    
    [self.rightsBadge updateBadgeValueTo:[self stringifiedAccessRights:data]];
    [self updateBadgeHolder];
}


#pragma mark - Misc methods

- (NSString *)stringifiedAccessRights:(PNAccessRightsInformation *)accessRightsInformation {
    
    NSString *accessRights = [accessRightsInformation hasAllRights] ? @"r+w" : @"none";
    if (![accessRightsInformation hasAllRights] &&
        ([accessRightsInformation hasReadRight] || [accessRightsInformation hasWriteRight])) {
        
        accessRights = [accessRightsInformation hasReadRight] ? @"r" : @"w";
    }
    
    
    return accessRights;
}

#pragma mark -


@end
