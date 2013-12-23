//
//  PNAccessRightsInformationCell.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAccessRightsInformationCell.h"


#pragma mark Structures

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


#pragma mark - Instance methods

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
        
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    return self;
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
        
        [labelValue appendString:@" (for "];
        NSUInteger hours = (NSUInteger)(data.accessPeriodDuration / 60);
        NSUInteger minutes = (NSUInteger)(data.accessPeriodDuration - hours * 60);
        if (hours > 0) {
            
            [labelValue appendFormat:@"%d hour%@ ", hours, (hours > 1 ? @"s" : @"")];
        }
        if (minutes > 0) {
            
            [labelValue appendFormat:@"%d minute%@", minutes, (minutes > 1 ? @"s" : @"")];
        }
        [labelValue appendString:@")"];
    }
    self.textLabel.text = labelValue;
    self.detailTextLabel.text = [self stringifiedAccessRights:data];
}


#pragma mark - Misc methods

- (NSString *)stringifiedAccessRights:(PNAccessRightsInformation *)accessRightsInformation {
    
    NSString *accessRights = [accessRightsInformation hasAllRights] ? @"read / write" : @"none";
    if (![accessRightsInformation hasAllRights] &&
        ([accessRightsInformation hasReadRight] || [accessRightsInformation hasWriteRight])) {
        
        accessRights = [accessRightsInformation hasReadRight] ? @"read-only" : @"write-only";
    }
    
    
    return accessRights;
}

#pragma mark -


@end
