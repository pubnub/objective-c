//
//  PNObjectInformationView.m
//  pubnub
//
//  Created by Sergey Mamontov on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectInformationView.h"
#import "PNChannelInformationHelperDelegate.h"
#import "PNChannelInformationHelper.h"
#import "NSString+PNLocalization.h"
#import "PNChannelPresenceView.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Private interface declaration

@interface PNObjectInformationView () <PNChannelInformationHelperDelegate>


#pragma mark - Properties

/**
 Stores reference on button which allow to save updated channel information or create new channel.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *saveButton;

/**
 Stores reference on field which will hold channel name and allow to change it (in case if channel not subscribed on it).
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectName;

/**
 @brief Reference on field which will hold channel namespace name and allow to change it (in case if not subscribed on it).
 
 @since 3.6.8
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *objectNamespace;

/**
 Stores reference on switch which allow to set whether client should observe presence or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *presenceObservationSwitch;

/**
 Stores reference on channel participants count label.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *channelParticipantsCount;

/**
 Stores reference on button which allow to fetch participants list with their information (will be shown in separate view).
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *fetchParticipantsListButton;

/**
 Stores reference on button which allow to pull channel state information.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *fetchClientStateButton;

/**
 Stores reference on text view which will show channel state in JSON string and allow to change it.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *channelStateView;

/**
 Stores reference on helper which will hold all required information about channel and will allow to manipulate
 with it's configuration.
 */
@property (nonatomic, strong) IBOutlet PNChannelInformationHelper *channelHelper;

/**
 @brief Stores whether view has been loaded for channel group information and change
 
 @since 3.6.8
 */
@property (nonatomic, assign, getter = isChannelGroupInformation) BOOL channelGroupInformation;


#pragma mark - Instance methods

/**
 Update channel inormation field across this view.
 */
- (void)updateLayout;


#pragma mark - Misc methods

- (void)enableDataObservation;
- (void)disableDataObservation;


#pragma mark - Handler methods

- (IBAction)handleSaveButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;
- (IBAction)handleFetchParticipantsButtonTap:(id)sender;
- (IBAction)handleFetchClientStateButtonTap:(id)sender;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNObjectInformationView


#pragma mark - Class methods

+ (instancetype)viewFromNibForChannelGroup {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelGroup)];
    
    PNObjectInformationView *view = [self viewFromNib];
    view.channelGroupInformation = YES;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelGroup)];
    
    
    return view;
}

+ (NSString *)viewNibNameForChannelGroup {
    
    return @"PNChannelGroupInformationView";
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
    
    self.allowEditing = YES;
    [self enableDataObservation];
    [self updateLayout];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    // Forward method call to the super class
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview) {
        
        [self disableDataObservation];
    }
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)configureForObject:(id <PNChannelProtocol>)object withState:(NSDictionary *)channelState
    andPresenceObservation:(BOOL)shouldObservePresence {
    
    self.channelHelper.object = object;
    self.channelHelper.objectName = object.name;
    if (self.isChannelGroupInformation) {
        
        self.channelHelper.objectNamespace = ((PNChannelGroup *)object).nspace;
    }
    self.channelHelper.state = channelState;
    self.channelHelper.observePresence = shouldObservePresence;
    
    [self updateLayout];
}

- (void)setAllowEditing:(BOOL)allowEditing {
    
    BOOL isStateChanged = _allowEditing != allowEditing;
    _allowEditing = allowEditing;
    
    if (isStateChanged) {
        
        [self updateLayout];
    }
}

- (void)updateLayout {
    
    self.objectName.enabled = self.shouldAllowEditing;
    self.objectNamespace.enabled = self.shouldAllowEditing;
    self.fetchParticipantsListButton.enabled = [self.channelHelper canCreateObject];
    self.fetchClientStateButton.enabled = [self.channelHelper canCreateObject];
    
    if (!self.isChannelGroupInformation) {
        
        NSUInteger participantsCount = 0;
        if (![self isUserInputActive]) {
            
            PNChannel *channel = ([self.channelHelper canCreateObject] ? [PNChannel channelWithName:self.channelHelper.objectName] : nil);
            participantsCount = (unsigned int)(channel ? channel.participantsCount : 0);
        }
        self.channelParticipantsCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)participantsCount];
    }
    
    [self.saveButton setTitle:(self.shouldAllowEditing ? @"channelInformationSaveButtonTitle" : @"channelInformationCreateButtonTitle")
                     forState:UIControlStateNormal];
    self.saveButton.enabled = ([self.channelHelper isObjectInformationChanged] || [self.channelHelper canCreateObject]);
    self.objectName.text = self.channelHelper.objectName;
    self.objectNamespace.text = self.channelHelper.objectNamespace;
    if (self.channelHelper.shouldObservePresence != self.presenceObservationSwitch.isOn) {
        
        [self.presenceObservationSwitch setOn:self.channelHelper.shouldObservePresence animated:YES];
    }
    
    NSString *channelState = nil;
    if (self.channelHelper.state) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.channelHelper.state options:NSJSONWritingPrettyPrinted error:NULL];
        if (jsonData) {
            
            channelState = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    self.channelStateView.text = channelState;
}

- (void)showWithOptions:(PNViewAnimationOptions)options animated:(BOOL)shouldAnimate {
    
    self.originalVerticalPosition = [self finalViewLocation].origin.y;
    [super showWithOptions:options animated:shouldAnimate];
}


#pragma mark - Handler methods

- (IBAction)handleSaveButtonTap:(id)sender {
    
    [self completeUserInput];
    
    // Checking whether valid client state has been provided or not.
    if ([self.channelHelper isObjectStateValid]) {
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        void(^completeEditingBlock)(void) = ^{
            
            if ([self.delegate respondsToSelector:@selector(objectInformation:didEndEditing:withState:andPresenceObservation:)]) {
                
                [self.delegate objectInformation:weakSelf didEndEditing:weakSelf.channelHelper.object
                                       withState:weakSelf.channelHelper.state
                          andPresenceObservation:weakSelf.channelHelper.shouldObservePresence];
            }
        };
        
        // Checking whether modofying existing channel or creating new one.
        if (self.shouldAllowEditing) {
            
            void(^changeStateBlock)(void) = ^{
                
                if ([self.channelHelper shouldChangeObjectState]) {
                    
                    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
                    [progressAlertView show];
                    
                    [PubNub updateClientState:[PubNub clientIdentifier] state:self.channelHelper.state
                                    forObject:weakSelf.channelHelper.object
                  withCompletionHandlingBlock:^(PNClient *client, PNError *stateUpdateError) {
                      
                                      [progressAlertView dismissWithAnimation:YES];
                      
                                      PNAlertType type = (stateUpdateError ? PNAlertWarning : PNAlertSuccess);
                                      NSString *title = @"stateUpdateAlertViewTitle";
                                      NSString *shortDescription = @"stateUpdateSuccessAlertViewShortDescription";
                                      NSString *detailedDescription = [NSString stringWithFormat:[@"stateUpdateSuccessAlertViewDetailedDescription" localized],
                                                                       client.identifier,
                                                                       (client.channel.name ? client.channel.name : client.group.name)];
                                      if (stateUpdateError) {
                                          
                                          shortDescription = @"stateUpdateFailureAlertViewShortDescription";
                                          detailedDescription = [NSString stringWithFormat:[@"stateUpdateSuccessAlertViewDetailedDescription" localized],
                                                                 [PubNub clientIdentifier], (client.channel.name ? client.channel.name : client.group.name),
                                                                 stateUpdateError.localizedFailureReason];
                                      }
                                      
                                      PNAlertView *alert = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                                                      detailedMessage:detailedDescription
                                                                    cancelButtonTitle:@"confirmButtonTitle"
                                                                    otherButtonTitles:nil andEventHandlingBlock:^(PNAlertView *view, NSUInteger buttonIndex) {
                                                                        
                                                                        completeEditingBlock();
                                                                    }];
                                      [alert show];
                                   }];
                }
                else {
                    
                    completeEditingBlock();
                }
            };
            
            void(^alertHandlerBlock)(PNAlertView *, NSUInteger) = ^(PNAlertView *view, NSUInteger buttonIndex) {
                
                changeStateBlock();
            };
            
            // Checking whether channel presence observation state should be changed or not.
            if ([self.channelHelper shouldChangePresenceObservationState]) {
                
                PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
                [progressAlertView show];
                
                void(^handlerBlock)(NSArray *, PNError *) = ^(NSArray *channels, PNError *presenceChangeError) {
                    
                    [progressAlertView dismissWithAnimation:YES];
                    
                    PNAlertType type = (presenceChangeError ? PNAlertWarning : PNAlertSuccess);
                    NSString *title = @"presenceObservationAlertViewTitle";
                    NSString *shortDescription = @"presenceObservationSuccessAlertViewShortDescription";
                    NSString *detailedDescriptionFormat = (self.channelHelper.shouldObservePresence ? @"presenceObservationEnableSuccessAlertViewDetailedDescription" :
                                                           @"presenceObservationDisableSuccessAlertViewDetailedDescription");
                    NSString *detailedDescription = [NSString stringWithFormat:[detailedDescriptionFormat localized],
                                                     [[channels lastObject] name]];
                    
                    if (presenceChangeError) {
                        
                        shortDescription = @"presenceObservationFailureAlertViewShortDescription";
                        detailedDescriptionFormat = (self.channelHelper.shouldObservePresence ? @"presenceObservationEnableFailureAlertViewDetailedDescription" :
                                                     @"presenceObservationDisableFailureAlertViewDetailedDescription");
                        detailedDescription = [NSString stringWithFormat:[detailedDescriptionFormat localized],
                                                                          [[channels lastObject] name],
                                                                          presenceChangeError.localizedFailureReason];
                    }
                    
                    PNAlertView *alert = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                                    detailedMessage:detailedDescription cancelButtonTitle:@"confirmButtonTitle"
                                                  otherButtonTitles:nil andEventHandlingBlock:alertHandlerBlock];
                    [alert show];
                };
                
                id object = weakSelf.channelHelper.object;
                if (self.channelHelper.shouldObservePresence) {
                    
                    [PubNub enablePresenceObservationFor:(object ? @[object] : nil)
                             withCompletionHandlingBlock:handlerBlock];
                }
                else {
                    
                    [PubNub disablePresenceObservationFor:(object ? @[object] : nil)
                              withCompletionHandlingBlock:handlerBlock];
                }
            }
            else {
                
                changeStateBlock();
            }
        }
        else {
            
            completeEditingBlock();
        }
    }
    else {
        
        [self.channelHelper resetWarnings];
        [self updateLayout];
        PNAlertView *alert = [PNAlertView viewWithTitle:@"malformedClientStateAlertViewTitle"
                                                   type:PNAlertWarning
                                           shortMessage:@"malformedClientStateAlertViewShortDescription"
                                        detailedMessage:@"malformedClientStateAlertViewDetailedDescription"
                                      cancelButtonTitle:[@"confirmButtonTitle" localized] otherButtonTitles:nil
                                  andEventHandlingBlock:NULL];
        [alert show];
    }
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}

- (IBAction)handleFetchParticipantsButtonTap:(id)sender {
    
    [self completeUserInput];
    if ([self.channelHelper canCreateObject]) {
        
        PNChannelPresenceView *channelPresence = [PNChannelPresenceView viewFromNib];
        [channelPresence configureForObject:self.channelHelper.object];
        [channelPresence showWithOptions:PNViewAnimationOptionTransitionFadeIn animated:YES];
    }
}

- (IBAction)handleFetchClientStateButtonTap:(id)sender {
    
    [self completeUserInput];
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PubNub requestClientState:[PubNub clientIdentifier] forObject:self.channelHelper.object
   withCompletionHandlingBlock:^(PNClient *client, PNError *channelStateRequestError) {
       
       [progressAlertView dismissWithAnimation:YES];
       PNAlertType type = (channelStateRequestError ? PNAlertWarning : PNAlertSuccess);
       NSString *shortDescription = @"stateRetrieveSuccessAlertViewShortDescription";
       NSString *detailedDescription = nil;
       
       if (!channelStateRequestError) {
           
           weakSelf.channelHelper.state = ([[client stateForChannel:client.channel] count] ?
                                           [client stateForChannel:client.channel] : nil);
           [weakSelf updateLayout];
           
           detailedDescription = [NSString stringWithFormat:[@"stateRetrieveSuccessAlertViewDetailedDescription" localized],
                                  [PubNub clientIdentifier], weakSelf.channelHelper.object];
       }
       else {
           
           shortDescription = @"stateRetrieveFailureAlertViewShortDescription";
           detailedDescription = [NSString stringWithFormat:[@"stateRetrieveFailureAlertViewDetailedDescription" localized],
                                  [PubNub clientIdentifier], weakSelf.channelHelper.object,
                                  channelStateRequestError.localizedFailureReason];
       }
       
       PNAlertView *alert = [PNAlertView viewWithTitle:@"stateRetrieveAlertViewTitle" type:type shortMessage:shortDescription
                                       detailedMessage:detailedDescription cancelButtonTitle:@"confirmButtonTitle"
                                     otherButtonTitles:nil andEventHandlingBlock:NULL];
       [alert show];
   }];
}


#pragma mark - Misc methods

- (void)enableDataObservation {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self
                                withBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *requestError) {
                                    
                                    [weakSelf updateLayout];
                                }];
}

- (void)disableDataObservation {
    
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
}


#pragma mark - Channel helper delegate methods

- (void)channelNameDidChange {
    
    [self updateLayout];
}

- (void)channelInformationDidChange {
    
    [self updateLayout];
}

#pragma mark -


@end
