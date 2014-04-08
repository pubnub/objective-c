//
//  PNAlertView.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNPopoverView.h"
#import "PNAlertViewDelegate.h"

#pragma mark Types

typedef NS_OPTIONS(NSInteger, PNAlertType) {
    
    PNAlertSuccess,
    PNAlertWarning,
    PNAlertProgress
};


#pragma mark Public interface declaration

@interface PNAlertView : PNPopoverView


#pragma mark - Properties

/**
 Stores reference on delegate which will be informed about events.
 */
@property (nonatomic, pn_desired_weak) id<PNAlertViewDelegate> delegate;

/**
 Stored and allow to redefine index of cancel button which will be shown as 'red' action button.
 */
@property (nonatomic, assign) NSUInteger cancelButtonIndex;


#pragma mark - Class methods

/**
 Construct alert view which will be shown while certain operation is in progress.
 
 @return Reference on constructed view which can be presented in future to the user.
 */
+ (PNAlertView *)viewForProcessProgress;

/**
 Construct alert view with predefined parameters and type. If \c delegate provided, it will be notified on user actions.
 
 @param title
 This is the message which till be shown at the top of the view (it will show maximum two lines header).
 
 @param type
 One of \c PNAlertType enum fields which tell how alert view should look like.
 
 @param shortMessage
 Message will be shown in colored block (color depends on \c type value) and maximum two lines of text fill be shown.
 
 @param detailedMessage
 Message which should be shown to the user in alert view. If message will took more then 10 lines, it will be placed into
 scrollable text view.
 
 @param cancelButtonTitle
 Name for 'cancel' button which will be shown on alert view in any case. Depending on value passed into the \c type it 
 can be assigned by default to \b "OK" (for \c PNAlertSuccess ) or \b "Cacnel" (for \c PNAlertWarning )
 
 @param otherButtonTitles
 List of other button titles which will be shown in alert view.
 
 @param handlingBlock
 Block which will be called when user tap on one of the buttons and it will pass index of the button and reference on
 alert view which is called this block.
 
 @return Reference on constructed view which can be presented in future to the user.
 */
+ (PNAlertView *)viewWithTitle:(NSString *)title type:(PNAlertType)type shortMessage:(NSString *)shortMessage
               detailedMessage:(NSString *)detailedMessage cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitles:(NSArray *)otherButtonTitles andEventHandlingBlock:(void(^)(PNAlertView *view, NSUInteger buttonIndex))handlingBlock;


#pragma mark - Instance methods

/**
 Present alert view in key window view above all other views.
 */
- (void)show;

/**
 Present laert view in concrete view (inside it hierarchy).
 */
- (void)showInView:(UIView *)view;

/**
 Hide alert view.
 
 @param animated
 Whether view shold be closed with animation or not.
 */
- (void)dismissWithAnimation:(BOOL)animated;

/**
 Allow to simulate user interaction with concrete view.
 
 @param buttonIndex
 Index of the button for which we simulate event.
 
 @param animated
 Whether view shold be closed with animation or not.
 */
- (void)dismissWithClickedButtonIndex:(NSUInteger)buttonIndex animated:(BOOL)animated;

#pragma mark -


@end
