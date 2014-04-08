//
//  PNConfigurationView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNConfigurationView.h"
#import "UIScreen+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNAlertView.h"


#pragma mark Static

static NSUInteger const kPNConfigurationPagesCount = 5;
static NSTimeInterval const kPNConfigurationAppearAnimationDuration = 0.6f;
static NSTimeInterval const kPNConfigurationDisappearAnimationDuration = 0.4f;


#pragma mark - Private interface declaration

@interface PNConfigurationView () <UIScrollViewDelegate, UITextFieldDelegate>


#pragma mark - Properties

/**
 Stores reference on scroll view which hold set of options which configuration allow to change.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIScrollView *optionsScrollView;

/**
 Stores reference on text field which allow user to input name of the origin server which should be used by client.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *originInputField;

/**
 Stores reference on text field which allow user to input personal subscribe key from PubNub portal.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *subscribeKeyInputField;

/**
 Stores reference on text field which allow user to input personal publish key from PubNub portal.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *publishKeyInputField;

/**
 Stores reference on text field which allow user to input personal secret key from PubNub portal.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *secretKeyInputField;

/**
 Stores reference on text field which allow user to input client authorization name which is used by PubNub PAM system 
 to identify access rights for this concrete user.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *authorizationKeyInputField;

/**
 Stores reference on text field which allow user to input cipher key which is used by client to issue PAM commands.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *cipherInputKeyField;

/**
 Stores reference on switch which allow to set whether client should reconnect on connection restore or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *autoReconnectSwitch;

/**
 Stores reference on switch which allow to set whether client should restore subscription after connection restore or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *restoreSubscriptionOnConnectSwitch;

/**
 Stores reference on switch which allow to set whether client should keep previous time token during subscription proccesses.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *keepLastTimeTokenSwitch;

/**
 Stores reference on switch which allow to set whether client should catch-up on last messages during subscription 
 restore process or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *catchUpOnSubscriptionRestoreSwitch;

/**
 Stores reference on switch which allow to set whether client should user secure connection or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *secureConnectionSwitch;

/**
 Stores reference on switch which allow to set whether client can decrease SSL requirements in case of handshake errors
 or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *secureRequirementsDecreaseSwitch;

/**
 Stores reference on switch which allow to set whether client is allowed to use insecure connection in case if it was
 unable to establish secure connection or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *insecureConnectionSwitch;

/**
 Stores reference on text field which allow user to input subscribe requests timeout value which will be used by client
 to identify when it should stop waiting for subscribe request completino and report error.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *subscribeRequestTimeoutInputField;

/**
 Stores reference on text field which allow user to input non-subscribe requests timeout value which will be used by client
 to identify when it should stop waiting for non-subscribe request completino and report error.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *nonSubscriptionRequestTimeoutInputField;

/**
 Stores reference on text field which allow user to input interval after which server will trigger 'timed out' presence
 event on channels on which client has been subscribed before.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *presenceHeartbeatInputField;

/**
 Stores reference on text field which allow user to input interval at which client will send heartbeat requests to
 inform server that client is still alive.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *presenceHeartbeatIntervalInputField;

/**
 Stores reference on page view which allow to show which page of settings is viewed at this moment.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UIPageControl *pageControl;

/**
 Stores reference on delegate to which configuration controller events will be sent.
 */
@property (nonatomic, pn_desired_weak) id<PNConfigurationDelegate> delegate;

/**
 Stores reference on current client configuration instance.
 */
@property (nonatomic, strong) PNConfiguration *currentConfiguration;


#pragma mark - Instance methods
/**
 Allow to gather information about what exactly user didn't filled and present error message.
 */
- (void)presentIncompletedInputError;

/**
 Allow to update configuration option values with data from provided \b PNConfiguration instance.
 
 @param configuration
 \b PNConfiguration instance which should be used during field/switch values update.
 */
- (void)updateWithConfiguration:(PNConfiguration *)configuration;

/**
 Go through available options and compose resulting option instance.
 */
- (PNConfiguration *)configurationFromConfiguredOptions;

/**
 Few elements require to be adjusted because of differences of how they appear for different iOS versions.
 */
- (void)updateIOSVersionDependentElements;


#pragma mark - Handler methods

- (IBAction)handleSwitchValueChange:(id)sender;
- (IBAction)handleResetButtonTapped:(id)sender;
- (IBAction)handleApplyButtonTapped:(id)sender;
- (IBAction)handleCloseButtonTapped:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNConfigurationView


#pragma mark - Class methods

+ (PNConfigurationView *)configurationViewWithDelegate:(id<PNConfigurationDelegate>)delegate
                                      andConfiguration:(PNConfiguration *)configuration {
    
    PNConfigurationView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    view.delegate = delegate;
    view.currentConfiguration = configuration ? configuration : [PNConfiguration defaultConfiguration];
    
    
    return view;
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    self.optionsScrollView.contentSize = (CGSize){.width = kPNConfigurationPagesCount * self.optionsScrollView.frame.size.width,
                                                  .height = self.optionsScrollView.frame.size.height};
    [self updateIOSVersionDependentElements];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        
        [self updateWithConfiguration:self.currentConfiguration];
    }
}

- (void)didMoveToSuperview {
    
}

- (void)showWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate {
    
    self.originalVerticalPosition = [self finalViewLocation].origin.y;
    [super showWithOptions:options animated:shouldAnimate];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNConfigurationAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNConfigurationDisappearAnimationDuration;
}

- (void)presentIncompletedInputError {
    
    NSCharacterSet *extraChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *subscribeKey = [self.subscribeKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *publishKey = [self.publishKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    if ([subscribeKey length] == 0 && [publishKey length] == 0) {
        
        PNAlertView *view = [PNAlertView viewWithTitle:@"configurationAlertViewTitle"
                                                  type:PNAlertWarning shortMessage:@"configurationIncompleteConfigurationAlertViewShortDescription"
                                       detailedMessage:@"configurationIncompleteConfigurationAlertViewDetailedDescription"
                                     cancelButtonTitle:@"cancelButtonTitle" otherButtonTitles:nil
                                 andEventHandlingBlock:NULL];
        [view showInView:self];
    }
}

- (void)updateWithConfiguration:(PNConfiguration *)configuration {
    
    self.originInputField.text = configuration.origin;
    self.subscribeKeyInputField.text = configuration.subscriptionKey;
    self.publishKeyInputField.text = configuration.publishKey;
    self.secretKeyInputField.text = configuration.secretKey;
    self.authorizationKeyInputField.text = configuration.authorizationKey;
    self.cipherInputKeyField.text = configuration.cipherKey;
    
    self.autoReconnectSwitch.on = configuration.shouldAutoReconnectClient;
    self.restoreSubscriptionOnConnectSwitch.on = configuration.shouldResubscribeOnConnectionRestore;
    self.keepLastTimeTokenSwitch.on = configuration.shouldKeepTimeTokenOnChannelsListChange;
    self.catchUpOnSubscriptionRestoreSwitch.on = configuration.shouldRestoreSubscriptionFromLastTimeToken;
    self.secureConnectionSwitch.on = configuration.shouldUseSecureConnection;
    self.secureRequirementsDecreaseSwitch.on = configuration.shouldReduceSecurityLevelOnError;
    self.insecureConnectionSwitch.on = configuration.canIgnoreSecureConnectionRequirement;
    self.subscribeRequestTimeoutInputField.text = [NSString stringWithFormat:@"%i", (int)configuration.subscriptionRequestTimeout];
    self.nonSubscriptionRequestTimeoutInputField.text = [NSString stringWithFormat:@"%i", (int)configuration.nonSubscriptionRequestTimeout];
    self.presenceHeartbeatInputField.text = [NSString stringWithFormat:@"%i", configuration.presenceHeartbeatTimeout];
    self.presenceHeartbeatIntervalInputField.text = [NSString stringWithFormat:@"%i", configuration.presenceHeartbeatInterval];
}

- (PNConfiguration *)configurationFromConfiguredOptions {
    
    NSCharacterSet *extraChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *origin = [self.originInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *subscribeKey = [self.subscribeKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *publishKey = [self.publishKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *secretKey = [self.secretKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *authorizationKey = [self.authorizationKeyInputField.text stringByTrimmingCharactersInSet:extraChars];
    NSString *cipherKey = [self.cipherInputKeyField.text stringByTrimmingCharactersInSet:extraChars];
    
    BOOL shouldAutoReconnect = self.autoReconnectSwitch.isOn;
    BOOL shouldRestoreSubscription = self.restoreSubscriptionOnConnectSwitch.isOn;
    BOOL shouldKeepPreviousTimeToken = self.keepLastTimeTokenSwitch.isOn;
    BOOL shouldCatchUpOnSubscriptionRestore = self.catchUpOnSubscriptionRestoreSwitch.isOn;
    BOOL shouldUseSecureConnection = self.secureConnectionSwitch.isOn;
    BOOL shouldReduceSSLRequirementsOnError = self.secureRequirementsDecreaseSwitch.isOn;
    BOOL canUseInsecureConnection = self.insecureConnectionSwitch.isOn;
    NSTimeInterval subscribeRequestTimeout = [[self.subscribeRequestTimeoutInputField.text stringByTrimmingCharactersInSet:extraChars] doubleValue];
    NSTimeInterval nonSubscribeRequestTimeout = [[self.nonSubscriptionRequestTimeoutInputField.text stringByTrimmingCharactersInSet:extraChars] doubleValue];
    NSInteger heartbeat = [[self.presenceHeartbeatInputField.text stringByTrimmingCharactersInSet:extraChars] doubleValue];
    NSInteger heartbeatInterval = [[self.presenceHeartbeatIntervalInputField.text stringByTrimmingCharactersInSet:extraChars] doubleValue];
    
    PNConfiguration *configuration = nil;
    if ([subscribeKey length] || [publishKey length]) {
        
        configuration = [PNConfiguration configurationForOrigin:([origin length] ? origin : nil)
                                                     publishKey:([publishKey length] ? publishKey : nil)
                                                   subscribeKey:([subscribeKey length] ? subscribeKey : nil)
                                                      secretKey:([secretKey length] ? secretKey : nil)
                                                      cipherKey:([cipherKey length] ? cipherKey : nil)
                                               authorizationKey:([authorizationKey length] ? authorizationKey : nil)];
        configuration.autoReconnectClient = shouldAutoReconnect;
        configuration.resubscribeOnConnectionRestore = shouldRestoreSubscription;
        configuration.keepTimeTokenOnChannelsListChange = shouldKeepPreviousTimeToken;
        configuration.restoreSubscriptionFromLastTimeToken = shouldCatchUpOnSubscriptionRestore;
        configuration.useSecureConnection = shouldUseSecureConnection;
        configuration.reduceSecurityLevelOnError = shouldReduceSSLRequirementsOnError;
        configuration.ignoreSecureConnectionRequirement = canUseInsecureConnection;
        configuration.subscriptionRequestTimeout = subscribeRequestTimeout;
        configuration.nonSubscriptionRequestTimeout = nonSubscribeRequestTimeout;
        configuration.presenceHeartbeatTimeout = heartbeat;
        configuration.presenceHeartbeatInterval = heartbeatInterval;
    }
    
    
    return configuration;
}

- (void)updateIOSVersionDependentElements {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        
        NSArray *subviews = [self.optionsScrollView subviews];
        [subviews enumerateObjectsUsingBlock:^(UIView *element, NSUInteger elementIdx, BOOL *elementEnumeratorStop) {
            
            if ([element respondsToSelector:@selector(setFont:)]) {
                
                // Decreasing size for the label, because in iOS6 there is larger line-height for same size.
                NSUInteger numberOfLines = 1;
                if ([element respondsToSelector:@selector(numberOfLines)]) {
                    
                    numberOfLines = ((UILabel *)element).numberOfLines;
                    ((UILabel *)element).numberOfLines = (numberOfLines == 1 ? 2 : numberOfLines);
                }
                
                if (numberOfLines > 1) {
                    
                    UIFont *currentFont = [element performSelector:@selector(font)];
                    [element performSelector:@selector(setFont:) withObject:[UIFont fontWithName:currentFont.fontName
                                                                                            size:(currentFont.pointSize - 1)]];
                    [element setFrame:CGRectOffset(element.frame, 0.0f, 3.0f)];
                }
            }
        }];
    }
}


#pragma mark - Handler methods

- (IBAction)handleSwitchValueChange:(id)sender {
    
    if (!self.autoReconnectSwitch.isOn) {
        
        [self.restoreSubscriptionOnConnectSwitch setOn:NO animated:YES];
    }
    
    if (!self.restoreSubscriptionOnConnectSwitch.isOn) {
        
        [self.catchUpOnSubscriptionRestoreSwitch setOn:NO animated:YES];
    }
    
    if (!self.secureConnectionSwitch.isOn) {
        
        [self.secureRequirementsDecreaseSwitch setOn:NO animated:YES];
    }
    
    if (!self.secureRequirementsDecreaseSwitch.isOn) {
        
        [self.insecureConnectionSwitch setOn:NO animated:YES];
    }
}

- (IBAction)handleResetButtonTapped:(id)sender {
    
    [self completeUserInput];
    
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    [self updateWithConfiguration:configuration];
    
    [self.delegate configurationChangeDidComplete:configuration];
    [self dismissWithOptions:PNViewAnimationOptionTransitionToBottom animated:YES];
}

- (IBAction)handleApplyButtonTapped:(id)sender {
    
    [self completeUserInput];
    
    PNConfiguration *configuration = [self configurationFromConfiguredOptions];
    
    if (configuration) {
        
        [self updateWithConfiguration:configuration];
        
        [self.delegate configurationChangeDidComplete:configuration];
        [self dismissWithOptions:PNViewAnimationOptionTransitionToBottom animated:YES];
    }
    // Looks like user didn't specified at least one of subscribe or publish keys
    else {
        
        [self presentIncompletedInputError];
        [self.optionsScrollView setContentOffset:CGPointZero animated:YES];
    }
}

- (IBAction)handleCloseButtonTapped:(id)sender {
    
    [self completeUserInput];
    [self dismissWithOptions:PNViewAnimationOptionTransitionToBottom animated:YES];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL should = YES;
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.keyboardType == UIKeyboardTypeNumberPad) {
        
        should = [resultingString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]
                                                  options:NSCaseInsensitiveSearch].location == NSNotFound;
    }
    
    
    return should;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}


#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self completeUserInput];
    
    CGFloat offset = scrollView.contentOffset.x;
    NSUInteger currentPage = MIN(MAX(0, (int)(offset / scrollView.frame.size.width)), kPNConfigurationPagesCount - 1);
    self.pageControl.currentPage = currentPage;
}

#pragma mark -


@end
