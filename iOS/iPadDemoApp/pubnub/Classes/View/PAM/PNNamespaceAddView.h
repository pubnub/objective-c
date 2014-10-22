//
//  PNNamespaceAddView.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNNamespaceAddDelegate.h"


#pragma mark Public interface declaration

@interface PNNamespaceAddView : PNInputFormView


#pragma mark - Properties

/**
 Stores reference on delegate which will handle all user input in this form.
 */
@property (nonatomic, pn_desired_weak) id<PNNamespaceAddDelegate> delegate;

#pragma mark -


@end
