//
//  CTTestEntryCell.h
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTTestEntryDelegate.h"
#import "CTTest.h"

#pragma mark Public interface declaration

@interface CTTestEntryCell : UITableViewCell


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) id<CTTestEntryDelegate> delegate;
@property (nonatomic, assign, getter = isMarked) BOOL marked;
@property (nonatomic, assign) CTTestState state;


#pragma mark - Instance methods

/**
 Update cell layout with information for particular test data.
 */
- (void)updateWithTest:(CTTest *)test;

#pragma mark -


@end
