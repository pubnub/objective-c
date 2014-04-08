//
//  PNClientIdentifierAddView.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/7/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNInputFormView.h"
#import "PNClientIdentifierAddDelegate.h"


#pragma mark Public interface declaration

@interface PNClientIdentifierAddView : PNInputFormView


#pragma mark - Properties

/**
 Stores reference on delegate which will handle all user input in this form.
 */
@property (nonatomic, pn_desired_weak) id<PNClientIdentifierAddDelegate> delegate;

#pragma mark - 


@end
