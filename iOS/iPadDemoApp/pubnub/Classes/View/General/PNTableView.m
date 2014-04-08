//
//  PNTableView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/2/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNTableView.h"
#import "PNRoundedView.h"


#pragma mark Static

/**
 Stores minimum side offset which should be used to disaply "empty tabple message". If message itself requre smaller width,
 if will be used w/o taking into account this value.
 */
static CGFloat const kPNMessageViewHorizontalMargin = 25.0f;

static CGFloat const kPNMessageLabelHorizontalMargin = 10.0f;
static CGFloat const kPNMessageLabelVerticalMargin = 10.0f;


#pragma mark - Private interface declaration

@interface PNTableView ()


#pragma mark - Properties

/**
 This value is designed to be used in UITableView instances plcaed via Interface Builder and table will show this message
 in case if there is no data for data layout.
 */
@property (nonatomic, copy) NSString *emptyTableMessage;

/**
 Stores reference on view which is used for message layout.
 */
@property (nonatomic, strong) PNRoundedView *emptyTableMessageView;

/**
 Stores reference on previous table settings which will be used for restore.
 */
@property (nonatomic, strong) UIColor *oldSeparatorColor;
@property (nonatomic, assign) UITableViewCellSeparatorStyle oldSeparatorStyle;


#pragma mark - Instance methods

- (void)prepareLayout;
- (void)updateLayout;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNTableView


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepareLayout];
}

- (void)prepareLayout {
    
    if (self.emptyTableMessage) {
        
        UIFont *messageFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        CGSize allowedSize = (CGSize){.width = (self.frame.size.width - 2.0f * kPNMessageViewHorizontalMargin),
                                      .height = self.frame.size.height};
        CGSize messageSize = [self.emptyTableMessage sizeWithFont:messageFont constrainedToSize:allowedSize
                                                    lineBreakMode:UILineBreakModeWordWrap];
        messageSize = (CGSize){.width = ceilf(messageSize.width), .height = ceilf(messageSize.height)};
        CGRect messagePosition = (CGRect){.origin = (CGPoint){.x = kPNMessageLabelHorizontalMargin,
                                                              .y = kPNMessageLabelVerticalMargin},
                                          .size = messageSize};
        CGSize holderSize = (CGSize){.width = (messageSize.width + 2.0f * kPNMessageLabelHorizontalMargin),
                                     .height = (messageSize.height + 2.0f * kPNMessageLabelVerticalMargin)};
        CGRect holderPosition = (CGRect){.origin = (CGPoint){.x = ceilf((allowedSize.width - holderSize.width) * 0.5f + kPNMessageViewHorizontalMargin),
                                                             .y = ceilf((allowedSize.height - holderSize.height) * 0.5f)},
                                         .size = holderSize};

        PNRoundedView *holderView = [[PNRoundedView alloc] initWithFrame:holderPosition];
        holderView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
                                       UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
        holderView.fillColor = [UIColor colorWithRed:144.0f/255.0f green:144.0f/255.0f blue:144.0f/255.0f alpha:1.0f];
        holderView.cornerRadius = @(5);
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:messagePosition];
        messageLabel.font = messageFont;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = holderView.fillColor;
        messageLabel.lineBreakMode = UILineBreakModeWordWrap;
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.numberOfLines = 10;
        messageLabel.text = self.emptyTableMessage;
        [holderView addSubview:messageLabel];
        
        self.emptyTableMessageView = holderView;
        [self addSubview:self.emptyTableMessageView];
    }
    
    if ([self respondsToSelector:@selector(separatorInset)]) {
        
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.oldSeparatorColor = self.separatorColor;
    self.oldSeparatorStyle = self.separatorStyle;
    [self updateLayout];
}

- (void)updateLayout {
    
    NSInteger numberOfRows = [self numberOfRowsInSection:0];
    self.emptyTableMessageView.hidden = (numberOfRows != 0 && numberOfRows != NSNotFound);
    self.userInteractionEnabled = self.emptyTableMessageView.isHidden;
    
    if (!self.isUserInteractionEnabled) {
        
        self.separatorColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        
        self.separatorColor = self.oldSeparatorColor;
        self.separatorStyle = self.oldSeparatorStyle;
    }
}

- (void)reloadData {
    
    // Forward method call to the super class.
    [super reloadData];
    
    [self updateLayout];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    
    // Forward method call to the super class.
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self updateLayout];
    });
}

#pragma mark -


@end
