//
//  PNAccessRightsInformationCell.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface PNAccessRightsInformationCell : UITableViewCell


#pragma mark - Instance methods

/**
 Update cell layout with updated access rights information.
 
 @param information
 \b NSDictionary instance which should be used to update cell layout.
 */
- (void)updateWithAccessRightsInformation:(NSDictionary *)information;

#pragma mark -


@end
