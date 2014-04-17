//
//  PNAlertView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNAlertView.h"
#import "NSString+PNLocalization.h"
#import "UIScreen+PNAddition.h"
#import "PNRoundedView.h"
#import "PNButton.h"


#pragma mark Static

static CGFloat const kPNAlertViewWidth = 300.0f;
static CGFloat const kPNAlertViewHeaderMinimumHeight = 20.0f;
static CGFloat const kPNAlertViewShortDescriptionMinimumHeight = 10.0f;
static CGFloat const kPNAlertViewHeaderLabelHorizontalMargin = 10.0f;
static CGFloat const kPNAlertViewHeaderLabelVerticalMargin = 3.0f;
static CGFloat const kPNAlertViewMessageHorizontalMargin = 10.0f;
static CGFloat const kPNAlertViewMessageVerticalMargin = 3.0f;
static CGFloat const kPNAlertViewButtonHeight = 30.0f;
static CGFloat const kPNAlertViewButtonHorizontalInterval = 10.0f;
static CGFloat const kPNAlertViewButtonVerticalInterval = 8.0f;

static CGFloat const kPNAlertViewAppearAnimationDuration = 0.6f;
static CGFloat const kPNAlertViewDisappearAnimationDuration = 0.3f;


#pragma mark - Private interface declaration

@interface PNAlertView ()

#pragma mark - Properties

/**
 Stores reference on list of button titles which will be presented in the interface.
 */
@property (nonatomic, strong) NSMutableArray *buttonTitles;

/**
 Stores reference on title which will be placed at the top of the view.
 */
@property (nonatomic, copy) NSString *title;

/**
 Stores reference on message which will be shown in clolored block (color depends on alert view type).
 */
@property (nonatomic, copy) NSString *shortMessage;

/**
 Stores reference on message which should be shown to the user.
 */
@property (nonatomic, copy) NSString *detailedMessage;

/**
 Stores reference on view layout type.
 */
@property (nonatomic, assign) PNAlertType type;

/**
 Stores reference on block which will be called as soon as uset will tap on one of the buttons.
 */
@property (nonatomic, copy) void(^handlerBlock)(PNAlertView *view, NSUInteger buttonIndex);


#pragma mark - Instance methods

/**
 Initialize alert view with predefined parameters and type. If \c delegate provided, it will be notified on user actions.
 
 @param title
 This is the message which till be shown at the top of the view (it will show maximum two lines header).
 
 @param type
 One of \c PNAlertType enum fields which tell how alert view should look like.
 
 @param message
 Message which should be shown to the user in alert view. If message will took more then 10 lines, it will be placed into
 scrollable text view.
 
 @param cancelButtonTitle
 Name for 'cancel' button which will be shown on alert view in any case. Depending on value passed into the \c type it
 can be assigned by default to \b "OK" (for \c PNAlertSuccess ) or \b "Cacnel" (for \c PNAlertWarning )
 
 @param otherButtonTitles
 List of other button titles which will be shown in alert view.
 
 @param handlingBlock
 Block which will be called when user tap on one of the buttons and it will pass index of the button.
 
 @return Initialized alert view which is ready to use.
 */
- (id)initWithTitle:(NSString *)title type:(PNAlertType)type shortMessage:(NSString *)shortMessage
    detailedMessage:(NSString *)detailedMessage cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles andEventHandlingBlock:(void(^)(PNAlertView *view, NSUInteger buttonIndex))handlingBlock;

/**
 Construct label which will fit into specified width.
 
 @param font
 \b UIFont which should be applied to the label and used during further calculations.
 
 @param text
 String which should be placed into label.
 
 @param targetWidth
 Maximum label width for which all further parameters should be calculated.
 
 @param lineBreakMode
 Chars/word line breaking mode.
 
 @param numberOfLines
 Maximum number of lines which should show created label.
 
 @return Fully configured and ready to use \b UILabel instance.
 */
- (UILabel *)labelWithFont:(UIFont *)font text:(NSString *)text constrainedToWidth:(CGFloat)targetWidth
             lineBreakMode:(NSLineBreakMode)lineBreakMode numberOfLines:(NSUInteger)numberOfLines;

/**
 Construct ready to use header view which can be added to the alert view.
 
 @return Configured header view with title on it.
 */
- (UIView *)headerView;

/**
 Construct ready to use short description view.
 
 @return Configured short description view.
 */
- (UIView *)shortDescriptionView;

/**
 Construct ready to use detailed description view.
 
 @return Configured detailed description view.
 */
- (UIView *)detailedDescriptionView;

/**
 Add set of buttons starting from provided vertical offset value.
 
 @return Next item offset (can be used to add another content below buttons).
 */
- (CGFloat)addButtonsWithOffset:(CGFloat)verticalOffset;


#pragma mark - Handler methods

- (void)handleActionButtonTapped:(PNButton *)button;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNAlertView


#pragma mark - Class methods

+ (PNAlertView *)viewWithTitle:(NSString *)title type:(PNAlertType)type shortMessage:(NSString *)shortMessage
               detailedMessage:(NSString *)detailedMessage cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitles:(NSArray *)otherButtonTitles andEventHandlingBlock:(void(^)(PNAlertView *view, NSUInteger buttonIndex))handlingBlock {
    
    return [[self alloc] initWithTitle:title type:type shortMessage:shortMessage detailedMessage:detailedMessage
                     cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles andEventHandlingBlock:handlingBlock];
}

+ (PNAlertView *)viewForProcessProgress {
    
    return [[self alloc] initWithTitle:nil type:PNAlertProgress shortMessage:nil detailedMessage:nil
                     cancelButtonTitle:nil otherButtonTitles:nil andEventHandlingBlock:NULL];
}


#pragma mark - Instance methods

- (id)initWithTitle:(NSString *)title type:(PNAlertType)type shortMessage:(NSString *)shortMessage
    detailedMessage:(NSString *)detailedMessage cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSArray *)otherButtonTitles andEventHandlingBlock:(void(^)(PNAlertView *view, NSUInteger buttonIndex))handlingBlock {
    
    // Check whether intialization has been successful or not
    if ((self = [super init])) {
        
        self.disableBackgroundElementsOnAppear = YES;
        self.dimmBackgroundOnAppear = YES;
        
        self.title = [title localized];
        self.type = type;
        self.shortMessage = [shortMessage localized];
        self.detailedMessage = [detailedMessage localized];
        
        if (!cancelButtonTitle) {
            
            cancelButtonTitle = (type == PNAlertSuccess ? [@"confirmButtonTitle" localized] : [@"cancelButtonTitle" localized]);
            self.cancelButtonIndex = 0;
        }
        self.buttonTitles = [NSMutableArray arrayWithObject:[cancelButtonTitle localized]];
        [self.buttonTitles addObjectsFromArray:[otherButtonTitles valueForKey:@"localized"]];
        self.handlerBlock = handlingBlock;
    }
    
    
    return self;
}

- (UILabel *)labelWithFont:(UIFont *)font text:(NSString *)text constrainedToWidth:(CGFloat)targetWidth
             lineBreakMode:(NSLineBreakMode)lineBreakMode numberOfLines:(NSUInteger)numberOfLines {
    
    CGRect targetLabelFrame = (CGRect){.size = (CGSize){.width = targetWidth, .height = MAXFLOAT}};
    UILabel *label = [[UILabel alloc] initWithFrame:targetLabelFrame];
    label.font = font;
    label.numberOfLines = numberOfLines;
    label.lineBreakMode = lineBreakMode;
    label.text = text;
    
    targetLabelFrame.size = (CGSize){.width = ceilf(targetLabelFrame.size.width),
                                     .height = ceilf([text sizeWithFont:font constrainedToSize:targetLabelFrame.size
                                                          lineBreakMode:lineBreakMode].height)};
    label.frame = targetLabelFrame;
    
    
    return label;
}

- (UIView *)headerView {
    
    UILabel *headerLabel = [self labelWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] text:self.title
                            constrainedToWidth:ceilf(kPNAlertViewWidth - kPNAlertViewHeaderLabelHorizontalMargin * 2.0f)
                                 lineBreakMode:NSLineBreakByTruncatingTail numberOfLines:2];
    headerLabel.textColor = [UIColor colorWithRed:(195.0f/255.0f) green:(33.0f/255.0f) blue:(47.0f/255.0f) alpha:1.0f];
    headerLabel.backgroundColor = [UIColor colorWithRed:(245.0f/255.0f) green:(244.0f/255.0f) blue:(244.0f/255.0f) alpha:1.0f];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    CGRect headerLabelFrame = (CGRect){
        .origin = (CGPoint){.x = kPNAlertViewHeaderLabelHorizontalMargin, .y = kPNAlertViewHeaderLabelVerticalMargin},
        .size = (CGSize){.width = headerLabel.frame.size.width,
                         .height = MAX(kPNAlertViewHeaderMinimumHeight, headerLabel.frame.size.height)}};
    
    CGFloat singleLineHeight = [@"W" sizeWithFont:headerLabel.font constrainedToSize:headerLabelFrame.size].height;
    CGFloat textHeight = [headerLabel.text sizeWithFont:headerLabel.font constrainedToSize:headerLabelFrame.size].height;
    if (singleLineHeight < textHeight) {
        
        headerLabelFrame.size.height = MAX(kPNAlertViewHeaderMinimumHeight, singleLineHeight * 2.0f);
    }
    headerLabel.frame = headerLabelFrame;
    
    PNRoundedView *headerView = [[PNRoundedView alloc] initWithFrame:(CGRect){
        .size = (CGSize){.width = kPNAlertViewWidth,
                         .height = ceilf(headerLabelFrame.size.height + kPNAlertViewHeaderLabelVerticalMargin * 2.0f)}}];
    headerView.topLeftCornerRadius = @(5);
    headerView.topRightCornerRadius = @(5);
    headerView.fillColor = [UIColor colorWithRed:(245.0f/255.0f) green:(244.0f/255.0f) blue:(244.0f/255.0f) alpha:1.0f];
    [headerView addSubview:headerLabel];
    
    
    return headerView;
}

- (UIView *)shortDescriptionView {
    
    UIColor *backgroundColor = [UIColor colorWithRed:(198.0f/255.0f) green:(34.0f/255.0f) blue:(41.0f/255.0f) alpha:1.0f];
    if (self.type == PNAlertSuccess) {
        
        backgroundColor = [UIColor colorWithRed:(87.0f/255.0f) green:(214.0f/255.0f) blue:(104.0f/255.0f) alpha:1.0f];
    }
    
    UILabel *descriptionLabel = [self labelWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f] text:self.shortMessage
                                 constrainedToWidth:ceilf(kPNAlertViewWidth - kPNAlertViewMessageHorizontalMargin * 2.0f)
                                      lineBreakMode:NSLineBreakByTruncatingTail numberOfLines:2];
    descriptionLabel.textColor = [UIColor colorWithRed:(249.0f/255.0f) green:(249.0f/255.0f) blue:(248.0f/255.0f) alpha:1.0f];
    descriptionLabel.backgroundColor = backgroundColor;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    CGRect descriptionLabelFrame = (CGRect){
        .origin = (CGPoint){.x = kPNAlertViewMessageHorizontalMargin, .y = kPNAlertViewMessageVerticalMargin},
        .size = (CGSize){.width = descriptionLabel.frame.size.width,
                         .height = MAX(kPNAlertViewShortDescriptionMinimumHeight, descriptionLabel.frame.size.height)}};
    descriptionLabel.frame = descriptionLabelFrame;
    
    PNRoundedView *holderView = [[PNRoundedView alloc] initWithFrame:(CGRect){
        .size = (CGSize){.width = kPNAlertViewWidth,
                         .height = ceilf(descriptionLabelFrame.size.height + kPNAlertViewMessageVerticalMargin * 2.0f)}}];
    if (![self.title length]) {
        
        holderView.topLeftCornerRadius = @(5);
        holderView.topRightCornerRadius = @(5);
    }
    holderView.fillColor = backgroundColor;
    [holderView addSubview:descriptionLabel];
    
    
    return holderView;
}

- (UIView *)detailedDescriptionView {
    
    UILabel *descriptionLabel = [self labelWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f] text:self.detailedMessage
                            constrainedToWidth:ceilf(kPNAlertViewWidth - kPNAlertViewMessageHorizontalMargin * 2.0f)
                                      lineBreakMode:NSLineBreakByTruncatingTail numberOfLines:200];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.backgroundColor = [UIColor colorWithRed:(249.0f/255.0f) green:(249.0f/255.0f) blue:(248.0f/255.0f) alpha:1.0f];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    CGRect frame = descriptionLabel.frame;
    
    
    CGFloat singleLineHeight = [@"W" sizeWithFont:descriptionLabel.font constrainedToSize:frame.size].height;
    CGFloat textHeight = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:frame.size].height;
    frame.size.height = (MAX(singleLineHeight, MIN(textHeight, singleLineHeight * 10.0f)) + kPNAlertViewMessageVerticalMargin * 2.0f);
    frame.size.width = kPNAlertViewWidth;
    
    UIScrollView *descriptionScrollView = [[UIScrollView alloc] initWithFrame:frame];
    descriptionScrollView.showsHorizontalScrollIndicator = NO;
    descriptionScrollView.backgroundColor = descriptionLabel.backgroundColor;
    descriptionScrollView.contentInset = UIEdgeInsetsMake(kPNAlertViewMessageVerticalMargin, kPNAlertViewMessageHorizontalMargin,
                                                          kPNAlertViewMessageVerticalMargin, 0.0f);
    descriptionScrollView.contentSize = (CGSize){.width = descriptionLabel.frame.size.width, .height = MAX(singleLineHeight, textHeight)};
    [descriptionScrollView addSubview:descriptionLabel];
    
    
    return descriptionScrollView;
}

- (CGFloat)addButtonsWithOffset:(CGFloat)verticalOffset {
    
    CGFloat buttonWidth = kPNAlertViewWidth - kPNAlertViewButtonHorizontalInterval * 2.0f;
    if ([self.buttonTitles count] == 2) {
        
        buttonWidth = ceilf((kPNAlertViewWidth - kPNAlertViewButtonHorizontalInterval * 3.0f) * 0.5f);
    }
    __block CGFloat currentHorizontalPosition = kPNAlertViewButtonHorizontalInterval;
    __block CGFloat currentVerticalPosition = verticalOffset + kPNAlertViewButtonVerticalInterval;
    [self.buttonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger buttonTitleIdx, BOOL *buttonTitleEnumerator) {

        PNButton *button = [PNButton buttonWithType:UIButtonTypeCustom];
        button.frame = (CGRect){.size = (CGSize){.width = buttonWidth, .height = kPNAlertViewButtonHeight},
                               .origin = (CGPoint){.x = currentHorizontalPosition, .y = currentVerticalPosition}};
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        button.cornerRadius = @(5);
        [button addTarget:self action:@selector(handleActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        if (buttonTitleIdx != self.cancelButtonIndex) {
            
            button.mainBackgroundColor = [UIColor colorWithRed:(197.0f/255.0f) green:(33.0f/255.0f) blue:(40.0f/255.0f) alpha:1.0f];
            button.highlightedBackgroundColor = [UIColor colorWithRed:(153.0f/255.0f) green:(12.0f/255.0f) blue:(27.0f/255.0f) alpha:1.0f];
            button.mainTitleColor = [UIColor whiteColor];
        }
        else {
            
            button.mainBackgroundColor = [UIColor colorWithRed:(201.0f/255.0f) green:(201.0f/255.0f) blue:(201.0f/255.0f) alpha:1.0f];
            button.highlightedBackgroundColor = [UIColor colorWithRed:(193.0f/255.0f) green:(192.0f/255.0f) blue:(194.0f/255.0f) alpha:1.0f];
            button.mainTitleColor = [UIColor whiteColor];
        }
        
        if ([self.buttonTitles count] == 2) {
            
            currentHorizontalPosition = button.frame.origin.x + button.frame.size.width + kPNAlertViewButtonHorizontalInterval;
        }
        else {
            
            currentVerticalPosition = button.frame.origin.y + button.frame.size.height + kPNAlertViewButtonVerticalInterval;
        }
        
        [self addSubview:button];
    }];
    
    if ([self.buttonTitles count] == 2) {
        
        currentVerticalPosition += kPNAlertViewButtonHeight + kPNAlertViewButtonVerticalInterval;
    }
    
    
    return currentVerticalPosition;
}

- (void)show {
    
    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    UIView *targetView = rootController.view;
    if (rootController.presentedViewController) {
        
        targetView = rootController.presentedViewController.view;
    }
    
    [self showInView:targetView];
}

- (void)showInView:(UIView *)view {
    
    self.autoresizesSubviews = NO;
    self.cornerRadius = @(5);
    
    CGRect targetViewFrame;
    if (self.type != PNAlertProgress) {
        
        targetViewFrame = (CGRect){.size = CGSizeMake(kPNAlertViewWidth, 0.0f)};
        
        if ([self.title length]) {
            
            UIView *headerView = [self headerView];
            [self addSubview:headerView];
            
            targetViewFrame.size.height = targetViewFrame.size.height + headerView.frame.size.height;
        }
        
        UIView *shortMessage = [self shortDescriptionView];
        CGRect shortMessageFrame = shortMessage.frame;
        shortMessageFrame.origin.y = targetViewFrame.size.height;
        shortMessage.frame = shortMessageFrame;
        
        [self addSubview:shortMessage];
        targetViewFrame.size.height = shortMessageFrame.origin.y + shortMessageFrame.size.height;
        
        if ([self.detailedMessage length]) {
            
            UIView *detailedMessage = [self detailedDescriptionView];
            CGRect detailedMessageFrame = detailedMessage.frame;
            detailedMessageFrame.origin.y = targetViewFrame.size.height;
            detailedMessage.frame = detailedMessageFrame;
            
            [self addSubview:detailedMessage];
            targetViewFrame.size.height = detailedMessageFrame.origin.y + detailedMessageFrame.size.height;
        }
        
        targetViewFrame.size.height = [self addButtonsWithOffset:targetViewFrame.size.height];
    }
    else {
        
        self.shadowSize = @(3);
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [view startAnimating];
        CGFloat contentSize = ceilf(view.frame.size.width + kPNAlertViewMessageHorizontalMargin * 2.0f);
        CGRect viewFrame = view.frame;
        viewFrame.origin = (CGPoint){.x = ceilf((contentSize - viewFrame.size.width) * 0.5f),
                                     .y = ceilf((contentSize - viewFrame.size.height) * 0.5f)};
        view.frame = viewFrame;
        targetViewFrame.size = (CGSize){.width = contentSize, .height = contentSize};
        [self addSubview:view];
    }
    
    CGRect normalizedRect = [[UIScreen mainScreen] normalizedForCurrentOrientationFrame:view.frame];
    targetViewFrame.origin = (CGPoint){.x = ceilf((normalizedRect.size.width - targetViewFrame.size.width) * 0.5f),
                                       .y = ceilf((normalizedRect.size.height - targetViewFrame.size.height) * 0.5f)};
    self.frame = targetViewFrame;
    [self updateShadow];
    
    self.backgroundColor = [UIColor colorWithRed:(249.0f/255.0f) green:(249.0f/255.0f) blue:(248.0f/255.0f) alpha:1.0f];
    
    self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.alpha = 0.0f;
    [view addSubview:self];
    [UIView animateWithDuration:kPNAlertViewAppearAnimationDuration*0.7f animations:^{
        
        self.alpha = 1.0f;
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:kPNAlertViewAppearAnimationDuration*0.3f animations:^{
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }];
}

- (void)dismissWithAnimation:(BOOL)animated {
    
    [self dismissWithClickedButtonIndex:NSNotFound animated:animated];
}

- (void)dismissWithClickedButtonIndex:(NSUInteger)buttonIndex animated:(BOOL)animated {
    
    [UIView animateWithDuration:(animated ? kPNAlertViewDisappearAnimationDuration : 0.0f) animations:^{
        
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
            
            [self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
        }
        if (self.handlerBlock) {
            
            self.handlerBlock(self, buttonIndex);
        }
    }];
}


#pragma mark - Handler methods

- (void)handleActionButtonTapped:(PNButton *)button {
    
    [self dismissWithClickedButtonIndex:[self.buttonTitles indexOfObject:button.titleLabel.text] animated:YES];
}

#pragma mark -


@end
