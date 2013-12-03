//
//  PNMainViewController.m
//  pubnub
//
//  This view controller is responsible for
//  chat interface layout and handling user
//  interaction
//
//
//  Created by Sergey Mamontov on 1/20/13.
//
//

#import "PNMainViewController.h"
#import "PNAuthorizationKeyChangeDelegate.h"
#import "PNAccessRightsAuditionDelegate.h"
#import "PNAccessRightsChangeDelegate.h"
#import "PNAuthorizationKeyChangeView.h"
#import "PNChannelInformationDelegate.h"
#import "PNChannelCreationDelegate.h"
#import "PNChannelInformationView.h"
#import "PNChangeAccessRightsView.h"
#import "NSString+PNDemoAddition.h"
#import "PNAuditAccessRightsView.h"
#import "PNChannelCreationView.h"
#import "PNChannelHistoryView.h"
#import "PNDataManager.h"
#import "PNChannelCell.h"


#pragma mark Static

// Stores reference on in-channel table message
// label size
static CGSize const inChannelMessageSize = {.width=230.0f,.height=35.0f};

// Stores reference on in-chat text view message
// label size
static CGSize const inChatMessageSize = {.width=524.0f,.height=669.0f};

static NSUInteger const inChatMessageLabelTag = 878;

static double const kPNActionRetryDelayOnPAMError = 2.0f;


#pragma mark - Private interface methods

@interface PNMainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate,
                                    PNChannelCreationDelegate, PNChannelInformationDelegate, PNAuthorizationKeyChangeDelegate,
                                    PNAccessRightsAuditionDelegate, PNAccessRightsChangeDelegate>


#pragma mark - Properties

// Stores reference on table which will hold list of channels
// to which user subscribed
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsTableView;

// Stores reference on table which will hold list of participants
// at specified channel (which currently opened)
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelParticipantsTableView;

// Stores reference on text field inside of which messages and events
// will be shown
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *messageTextView;

// Stores reference on participants section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *participantsBackgroundImageView;

// Stores reference on PAM management section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *pamManagementBackgroundImageView;

// Stores reference on channels section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *channelsBackgroundImageView;

// Stores reference on connection information section background image
@property (nonatomic, pn_desired_weak) IBOutlet UIImageView *informationBackgroundImageView;

// Stores reference on collection of white buttons
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *whiteButtons;

// Stores reference on button which allow to subscribe on new channel
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *addChannelButton;

// Stores reference on button which allow to disconnect client
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *disconnectButton;

// Stores reference on button which allow to retrieve server time from PubNub service
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *serverTimeButton;

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *recentServerTimeLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *clientIdentifierLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *clientAuthorizationKeyLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *clientNetworkAddressLabel;

// Stores reference on channel information holding view
@property (nonatomic, pn_desired_weak) IBOutlet PNChannelInformationView *channelInformationView;

// Stores reference on message sending button
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *sendMessageButton;

// Stores reference on message input text field
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *messageTextField;

/**
 Stores reference on channel for which client should retry subscription.
 */
@property (nonatomic, strong) PNChannel *channelForRetry;

/**
 Stores reference no message which should be resent
 */
@property (nonatomic, strong) NSString *messageForRetry;


#pragma mark - Instance methods

#pragma mark - Interface customization

- (void)prepareInterface;


#pragma mark - Handler methods

- (IBAction)refreshButtonTapped:(id)sender;
- (IBAction)disconnectButtonTapped:(id)sender;
- (IBAction)addChannelButtonTapped:(id)sender;
- (IBAction)getServerTimeButtonTapped:(id)sender;
- (IBAction)sendMessageButtonTapped:(id)sender;

- (IBAction)changeAuthorizationButtonKeyTapped:(id)sender;
- (IBAction)grantAccessRightsButtonTapped:(id)sender;
- (IBAction)revokeAccessRightsButtonTapped:(id)sender;
- (IBAction)auditAccessRightsButtonTapped:(id)sender;

/**
 * Handle "Clear" button tap to clear message input
 * field as well as channel messages
 */
- (IBAction)clearButtonTapped:(id)sender;


#pragma mark - Misc methods

/**
 * Updating message sending interface according to current
 * application state:
 * - enable if client is connected at least to one channel
 *   and inputted message
 * - disable in other case
 */
- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message;

/**
 * Update subscribed channels list except current
 */
- (void)updateVisibleChannelsList;

/**
 * Update cells in specified table and exclude specified index path from it
 */
- (void)updateVisibleCellsInTable:(UITableView *)tableView excludingCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Will update interface to show current client connection
 * identifier and client network address
 */
- (void)updateClientInformation;

- (void)highlightCurrentChannel;

/**
 * Allow to show/hide message which will ask user
 * to add channel (if there is no channels on which
 * user is subscribed)
 */
- (void)showNoChannelAddedMessage;
- (void)hideNoChannelAddedMessage;

/**
 * Allow to show/hide message which will ask user
 * to select one of the channels from right hand
 * list (will be shown only if user subscribed on
 * at least one channel)
 */
- (void)showNoChannelSelectedMessage;
- (void)hideNoChannelSelectedMessage;

@end


#pragma mark - Public interface methods

@implementation PNMainViewController


#pragma mark - Instance methods

- (void)viewDidLoad {
    
    // Forward to the super class to complete all initializations
    [super viewDidLoad];


    [self prepareInterface];


    PNMainViewController *weakSelf = self;
    [[PNObservationCenter defaultCenter] addTimeTokenReceivingObserver:self
                                                     withCallbackBlock:^(NSNumber *timeToken, PNError *error) {

         NSString *alertMessage = nil;
         if (!error) {

             NSDateFormatter *dateFormatter = [NSDateFormatter new];
             dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";
             NSDate *timeTokenDate = [NSDate dateWithTimeIntervalSince1970:PNUnixTimeStampFromTimeToken(timeToken)];

             alertMessage = [NSString stringWithFormat:@"Server time token: %@\nDate: %@",
                                                       timeToken,
                                                       [dateFormatter stringFromDate:timeTokenDate]];
             weakSelf.recentServerTimeLabel.text = [dateFormatter stringFromDate:timeTokenDate];
         }
         else {

             alertMessage = [NSString stringWithFormat:@"Time token request failed with error:\n%@",
                                                       error];
         }


         UIAlertView *timeTokenAlertView = [UIAlertView new];
         timeTokenAlertView.title = @"Server time token";
         timeTokenAlertView.message = alertMessage;
         [timeTokenAlertView addButtonWithTitle:@"OK"];
         [timeTokenAlertView show];

     }];


    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {

                                                            [weakSelf updateClientInformation];
                                                        }];

    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self
                                                                                    withBlock:^(NSArray *participants,
                                                                                                PNChannel *channel,
                                                                                                PNError *fetchError) {

                                                        [weakSelf.channelParticipantsTableView reloadData];
                                                    }];

    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self
                                                        withBlock:^(PNPresenceEvent *event) {

                    [weakSelf updateVisibleChannelsList];
                    [weakSelf highlightCurrentChannel];
                }];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             [weakSelf updateVisibleChannelsList];
                                                             [weakSelf highlightCurrentChannel];
                                                         }];


    // Subscribe on data manager properties change
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"currentChannel"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"currentChannelChat"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
    [[PNDataManager sharedInstance] addObserver:self
                                     forKeyPath:@"subscribedChannelsList"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
}

#pragma mark - Interface customization

- (void)prepareInterface {

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"side-menu-background"]];

    UIImage *leftSectionImage = [UIImage imageNamed:@"left-section-header-background"];
    UIImage *stretchedLeftSectionImage = [leftSectionImage stretchableImageWithLeftCapWidth:10.0f
                                                                               topCapHeight:10.0f];

    UIImage *rightSectionImage = [UIImage imageNamed:@"right-section-header-background"];
    UIImage *stretchedRightSectionImage = [rightSectionImage stretchableImageWithLeftCapWidth:10.0f
                                                                                 topCapHeight:10.0f];

    UIImage *rightSingleEntryImage = [UIImage imageNamed:@"right-single-entry-background.png"];
    UIImage *stretchedRightSingleEntryImage = [rightSingleEntryImage stretchableImageWithLeftCapWidth:10.0f
                                                                                         topCapHeight:10.0f];

    self.participantsBackgroundImageView.image = stretchedLeftSectionImage;
    self.pamManagementBackgroundImageView.image = stretchedLeftSectionImage;
    self.channelsBackgroundImageView.image = stretchedRightSectionImage;
    self.informationBackgroundImageView.image = stretchedRightSectionImage;



    UIImage *whiteButtonImage = [UIImage imageNamed:@"white-button"];
    UIImage *stretchedWhiteButtonImageImage = [whiteButtonImage stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:10.0f];

    [self.whiteButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger buttonIdx, BOOL *buttonsEnumerator) {

        [button setBackgroundImage:stretchedWhiteButtonImageImage forState:UIControlStateNormal];
    }];
    [self.disconnectButton setBackgroundImage:stretchedRightSingleEntryImage forState:UIControlStateNormal];

    [self updateClientInformation];


    self.channelInformationView.delegate = self;
    [self updateMessageSendingInterfaceWithMessage:nil];
    [self showNoChannelAddedMessage];
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    BOOL shouldUpdateChat = NO;

    // Check whether current category changed or not
    if ([keyPath isEqualToString:@"currentChannel"]) {

        [self updateVisibleChannelsList];
        [self highlightCurrentChannel];

        [self.channelParticipantsTableView reloadData];
        shouldUpdateChat = YES;

        self.messageTextField.text = nil;
        [self updateMessageSendingInterfaceWithMessage:nil];

        if ([[change valueForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]] &&
            [[PubNub subscribedChannels] count]) {

            [self showNoChannelSelectedMessage];
        }
        else {

            [self hideNoChannelSelectedMessage];
        }

    }
    // Looks like list of channels changed
    else if ([keyPath isEqualToString:@"subscribedChannelsList"]){

        [self.channelsTableView reloadData];

        if ([[PubNub subscribedChannels] count]) {

            [self hideNoChannelAddedMessage];
            PNChannel *currentChannel = [[PNDataManager sharedInstance] currentChannel];

            if (currentChannel == nil) {

                [self showNoChannelSelectedMessage];
            }
            else {

                [self highlightCurrentChannel];
            }
        }
        else {

            [self showNoChannelAddedMessage];
            [self hideNoChannelSelectedMessage];
        }
    }
    else if ([keyPath isEqualToString:@"currentChannelChat"]){

        shouldUpdateChat = YES;
    }

    if (shouldUpdateChat) {

        self.messageTextView.text = [PNDataManager sharedInstance].currentChannelChat;

        CGRect targetRect = self.messageTextView.bounds;
        targetRect.origin.y = self.messageTextView.contentSize.height - targetRect.size.height;
        if (targetRect.size.height < self.messageTextView.contentSize.height) {

            [self.messageTextView flashScrollIndicators];
        }

        [self.messageTextView scrollRectToVisible:targetRect animated:YES];
    }
}

- (IBAction)refreshButtonTapped:(id)sender {

    if ([[PNDataManager sharedInstance] currentChannel]) {

        [PubNub requestParticipantsListForChannel:[[PNDataManager sharedInstance] currentChannel]];
    }
}

- (IBAction)disconnectButtonTapped:(id)sender {

    [PubNub disconnect];

    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removeTimeTokenReceivingObserver:self];
    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver:self];
    [[PNObservationCenter defaultCenter] removeChannelParticipantsListProcessingObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    [[PNObservationCenter defaultCenter] removePresenceEventObserver:self];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannel"];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"currentChannelChat"];
    [[PNDataManager sharedInstance] removeObserver:self forKeyPath:@"subscribedChannelsList"];

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addChannelButtonTapped:(id)sender {

    PNChannelCreationView *view = [PNChannelCreationView viewFromNib];
    view.delegate = self;
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height);
    view.frame = targetFrame;

    [self.view addSubview:view];
}

- (IBAction)changeAuthorizationButtonKeyTapped:(id)sender {
    
    PNAuthorizationKeyChangeView *view = [PNAuthorizationKeyChangeView viewFromNib];
    view.delegate = self;
    
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height);
    view.frame = targetFrame;
    
    [self.view addSubview:view];
}

- (IBAction)grantAccessRightsButtonTapped:(id)sender {
    
    PNChangeAccessRightsView *view = [PNChangeAccessRightsView viewFromNib];
    [view setAccessRightsChangeMode:PNAccessRightsGrantMode];
    view.delegate = self;
    
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height*0.5) + 10.0f;
    view.frame = targetFrame;
    
    [self.view addSubview:view];
}

- (IBAction)revokeAccessRightsButtonTapped:(id)sender {
    
    PNChangeAccessRightsView *view = [PNChangeAccessRightsView viewFromNib];
    [view setAccessRightsChangeMode:PNAccessRightsRevokeMode];
    view.delegate = self;
    
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height*0.5) + 10.0f;
    view.frame = targetFrame;
    
    [self.view addSubview:view];
}

- (IBAction)auditAccessRightsButtonTapped:(id)sender {
    
    PNAuditAccessRightsView *view = [PNAuditAccessRightsView viewFromNib];
    view.delegate = self;
    
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height*0.5);
    view.frame = targetFrame;
    
    [self.view addSubview:view];
}

- (IBAction)getServerTimeButtonTapped:(id)sender {

    [PubNub requestServerTimeToken];
}

- (IBAction)sendMessageButtonTapped:(id)sender {

    __block __pn_desired_weak __typeof(self) weakSelf = self;
    NSString *message = self.messageTextField.text;
    [PubNub sendMessage:message toChannel:[PNDataManager sharedInstance].currentChannel
    withCompletionBlock:^(PNMessageState state, id object) {
        
        if (state == PNMessageSendingError) {
            
            NSString *cancelButtonTitle = nil;
            
            NSString *alertMessage = [NSString stringWithFormat:@"Message sending failed: %@\nChannel: %@\n\nReason: %@", message,
                                      [PNDataManager sharedInstance].currentChannel.name,  [((PNError *)object) localizedFailureReason]];
            
            if (((PNError *)object).code == kPNAPIAccessForbiddenError) {
                
                alertMessage = [NSString stringWithFormat:@"Message sending failed: %@\nChannel: %@\n\nReason: %@\n\nMessage sending will be repeated in 2 seconds.",
                                message, [PNDataManager sharedInstance].currentChannel.name, [((PNError *)object) localizedFailureReason]];
                
                cancelButtonTitle = @"Cancel";
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message sending" message:alertMessage delegate:self
                                                      cancelButtonTitle:cancelButtonTitle otherButtonTitles:@"OK", nil];
            [alertView show];
            
            if (((PNError *)object).code == kPNAPIAccessForbiddenError) {
                
                weakSelf.messageForRetry = message;
                double delayInSeconds = kPNActionRetryDelayOnPAMError;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    if (weakSelf.messageForRetry) {
                        
                        [alertView dismissWithClickedButtonIndex:([alertView cancelButtonIndex] + 1) animated:YES];
                        
                        weakSelf.messageTextField.text = weakSelf.messageForRetry;
                        [weakSelf sendMessageButtonTapped:nil];
                        weakSelf.messageForRetry = nil;
                    }
                });
            }
        }
    }];
    self.messageTextField.text = nil;
    [self updateMessageSendingInterfaceWithMessage:nil];
    [self.view endEditing:YES];
}

- (IBAction)clearButtonTapped:(id)sender {

    self.messageTextField.text = nil;
    [self updateMessageSendingInterfaceWithMessage:nil];
    [[PNDataManager sharedInstance] clearChatHistory];
}


#pragma mark - Misc methods

/**
 * Updating message sending interface according to current
 * application state:
 * - enable if client is connected at least to one channel
 *   and inputted message
 * - disable in other case
 */
- (void)updateMessageSendingInterfaceWithMessage:(NSString *)message {

    BOOL isSubscribed = [[PNDataManager sharedInstance].subscribedChannelsList count] > 0;
    BOOL isChannelSelected = [PNDataManager sharedInstance].currentChannel != nil;
    BOOL isEmptyMessage = message == nil || [message isEmptyString];

    self.sendMessageButton.enabled = isSubscribed && !isEmptyMessage && isChannelSelected;
    self.messageTextField.enabled = isSubscribed && isChannelSelected;
}

- (void)updateVisibleChannelsList {

    NSArray *channels = [[PNDataManager sharedInstance] subscribedChannelsList];
    NSArray *visibleCells = [self.channelsTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(PNChannelCell *cell,
                                               NSUInteger cellIdx,
                                               BOOL *cellsEnumeratorStop) {

        [cell updateForChannel:[channels objectAtIndex:cellIdx]];
    }];
}

- (void)updateVisibleCellsInTable:(UITableView *)tableView excludingCellAtIndexPath:(NSIndexPath *)indexPath {

    // Retrieving list of visible cells
    NSMutableArray *visibleCellsIndexPath = [[tableView indexPathsForVisibleRows] mutableCopy];
    [visibleCellsIndexPath removeObject:indexPath];

    [tableView reloadRowsAtIndexPaths:visibleCellsIndexPath withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateClientInformation {

    NSString *identifier = [PubNub clientIdentifier];
    NSString *address = [PNNetworkHelper networkAddress];
    NSString *authorizationKey = [PubNub configuration].authorizationKey;
    if (![[PubNub sharedInstance] isConnected]) {

        identifier = @"---";
        address = @"-.-.-.-";
    }
    self.clientNetworkAddressLabel.text = address;
    self.clientIdentifierLabel.text = identifier;
    self.clientAuthorizationKeyLabel.text = (authorizationKey ? authorizationKey : @"not set");
}

- (void)highlightCurrentChannel {

    PNChannel *currentChannel = [[PNDataManager sharedInstance] currentChannel];
    NSInteger channelIdx = [[[PNDataManager sharedInstance] subscribedChannelsList] indexOfObject:currentChannel];
    NSIndexPath *currentChannelPath = [NSIndexPath indexPathForRow:channelIdx inSection:0];
    [self.channelsTableView selectRowAtIndexPath:currentChannelPath
                                        animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)showNoChannelAddedMessage {

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:(CGRect){.size=inChannelMessageSize}];
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    messageLabel.textAlignment = UITextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.shadowColor = [UIColor blackColor];
    messageLabel.shadowOffset = (CGSize){.height=-1.0f};
    messageLabel.text = @"Please add channel";
    self.channelsTableView.tableHeaderView = messageLabel;
}

- (void)hideNoChannelAddedMessage {

    self.channelsTableView.tableHeaderView = nil;
}

- (void)showNoChannelSelectedMessage {

    UILabel *messageLabel = [[UILabel alloc] initWithFrame:(CGRect){.size=inChatMessageSize}];
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    messageLabel.tag = inChatMessageLabelTag;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    messageLabel.shadowOffset = (CGSize){.height=1.0f};
    messageLabel.text = @"Select a channel to publish to";
    if ([self.messageTextView viewWithTag:inChatMessageLabelTag] == nil) {

        [self.messageTextView addSubview:messageLabel];
    }
}
- (void)hideNoChannelSelectedMessage {

    [[self.messageTextView viewWithTag:inChatMessageLabelTag] removeFromSuperview];
}


#pragma mark - Channel subscription delegate methods

- (void)creationView:(PNChannelCreationView*)view subscribeOnChannel:(PNChannel *)channel {

    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PubNub subscribeOnChannel:channel
   withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {

       NSString *cancelButtonTitle = nil;
        NSString *alertMessage = [NSString stringWithFormat:@"Subscribed on channel: %@\nTo be able to send messages, select channel from righthand list",
                                                            channel.name];
        if (state == PNSubscriptionProcessNotSubscribedState) {

            if (subscriptionError.code == kPNAPIAccessForbiddenError) {
                
                cancelButtonTitle = @"Cancel";
                alertMessage = [NSString stringWithFormat:@"Failed to subscribe on: %@\n\nReason: %@\n\nSubscribe will be repeated in 2 seconds.", channel.name, [subscriptionError localizedFailureReason]];
            }
            else {
                
                alertMessage = [NSString stringWithFormat:@"Failed to subscribe on: %@\n\nReason: %@\n\nSubscribe will be repeated in 2 seconds.", channel.name, [subscriptionError localizedFailureReason]];
            }
        }


        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe"
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:cancelButtonTitle
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
       
       if (subscriptionError.code == kPNAPIAccessForbiddenError) {
           
           weakSelf.channelForRetry = channel;
           double delayInSeconds = kPNActionRetryDelayOnPAMError;
           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               
               if (weakSelf.channelForRetry) {
                   
                   [alertView dismissWithClickedButtonIndex:([alertView cancelButtonIndex] + 1) animated:YES];
                   [weakSelf creationView:nil subscribeOnChannel:weakSelf.channelForRetry];
                   weakSelf.channelForRetry = nil;
               }
           });
       }
   }];
}


#pragma mark - Channel information delegate

- (void)showHistoryRequestParameters {

    PNChannelHistoryView *view = [PNChannelHistoryView viewFromNib];
    CGRect targetFrame = view.frame;
    targetFrame.origin.x = ceilf(self.view.bounds.size.width*0.5f-targetFrame.size.width*0.5f);
    targetFrame.origin.y = ceilf(self.view.bounds.size.height*0.5f-targetFrame.size.height*0.5f);
    view.frame = targetFrame;

    [self.view addSubview:view];
}


#pragma mark - Authorization key change delegate

- (void)authorizationKeyChangeView:(PNAuthorizationKeyChangeView *)view didChangeKeyTo:(NSString *)authorizationKey {
    
    PNConfiguration *configuration = [PubNub configuration];
    configuration.authorizationKey = authorizationKey;
    [PubNub setConfiguration:configuration];
    
    [[PNDataManager sharedInstance] clearChatHistory];
    [[PNDataManager sharedInstance] clearChannels];
    
    [self updateClientInformation];
}


#pragma mark - Audition delegates

- (void)auditAccessRightsForApplication:(PNAuditAccessRightsView *)accessRightsView withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock {
    
    [PubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
        
        if (auditionError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights audit"
                                                                message:[NSString stringWithFormat:@"Failed to audit access rights for application.\n\nReason: %@",
                                                                         [auditionError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, auditionError);
    }];
}

- (void)auditAccessRightsForChannels:(NSArray *)channels fromAccessRightsView:(PNAuditAccessRightsView *)accessRightsView
                    withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock {
    
    [PubNub auditAccessRightsForChannels:channels
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
                 
                 if (auditionError) {
                     
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights audit"
                                                                         message:[NSString stringWithFormat:@"Failed to audit access rights for channels:%@\n\nReason: %@",
                                                                                  channels, [auditionError localizedFailureReason]]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                     [alertView show];
                 }
                 
                 handleBlock(collection, auditionError);
             }];
}

- (void)auditAccessRightsForChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys
               fromAccessRightsView:(PNAuditAccessRightsView *)accessRightsView withHandlerBlock:(PNClientChannelAccessRightsAuditBlock)handleBlock {
    
    [PubNub auditAccessRightsForChannel:channel clients:clientsAuthorizationKeys
            withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *auditionError) {
                
                if (auditionError) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights audit"
                                                                        message:[NSString stringWithFormat:@"Failed to audit access rights for channel:%@\n\nReason: %@",
                                                                                 [channel name], [auditionError localizedFailureReason]]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                handleBlock(collection, auditionError);
            }];
}


#pragma mark - Access rights change delegate methods

#pragma mark - Grant delegate methods

- (void)grantApplicationReadRight:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantReadAccessRightForApplicationAtPeriod:period andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
        
        if (accessRightsChangeError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                message:[NSString stringWithFormat:@"Failed to change access rights for application.\n\nReason: %@",
                                                                         [accessRightsChangeError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, accessRightsChangeError);
    }];
}

- (void)grantApplicationWriteRight:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                  withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantWriteAccessRightForApplicationAtPeriod:period andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
        
        if (accessRightsChangeError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                message:[NSString stringWithFormat:@"Failed to change access rights for application.\n\nReason: %@",
                                                                         [accessRightsChangeError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, accessRightsChangeError);
    }];
}

- (void)grantApplicationAllRights:(PNChangeAccessRightsView *)accessRightsChangeView forPeriod:(NSUInteger)period
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantAllAccessRightsForApplicationAtPeriod:period andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
        
        if (accessRightsChangeError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                message:[NSString stringWithFormat:@"Failed to change access rights for application.\n\nReason: %@",
                                                                         [accessRightsChangeError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, accessRightsChangeError);
    }];
}

- (void)grantReadRightToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantReadAccessRightForChannels:channels forPeriod:period withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                    
                    if (accessRightsChangeError) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                            message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\n\nReason: %@",
                                                                                     channels, [accessRightsChangeError localizedFailureReason]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    handleBlock(collection, accessRightsChangeError);
                }];
}

- (void)grantWriteRightToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                 withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantWriteAccessRightForChannels:channels forPeriod:period withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                    
                    if (accessRightsChangeError) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                            message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\n\nReason: %@",
                                                                                     channels, [accessRightsChangeError localizedFailureReason]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    handleBlock(collection, accessRightsChangeError);
                }];
}

- (void)grantAllRightsToChannels:(NSArray *)channels forPeriod:(NSUInteger)period fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantAllAccessRightsForChannels:channels forPeriod:period withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                    
                    if (accessRightsChangeError) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                            message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\n\nReason: %@",
                                                                                     channels, [accessRightsChangeError localizedFailureReason]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    handleBlock(collection, accessRightsChangeError);
                }];
}

- (void)grantReadRightToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                       fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantReadAccessRightForChannel:channel forPeriod:period clients:clientsAuthorizationKeys
               withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                   
                   if (accessRightsChangeError) {
                       
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                           message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\nClients: %@\n\nReason: %@",
                                                                                    channel, clientsAuthorizationKeys, [accessRightsChangeError localizedFailureReason]]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                       [alertView show];
                   }
                   
                   handleBlock(collection, accessRightsChangeError);
               }];
}

- (void)grantWriteRightToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                        fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantWriteAccessRightForChannel:channel forPeriod:period clients:clientsAuthorizationKeys
                withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                   
                   if (accessRightsChangeError) {
                       
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                           message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\nClients: %@\n\nReason: %@",
                                                                                    channel, clientsAuthorizationKeys, [accessRightsChangeError localizedFailureReason]]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                       [alertView show];
                   }
                   
                   handleBlock(collection, accessRightsChangeError);
               }];
}

- (void)grantAllRightsToChannel:(PNChannel *)channel clients:(NSArray *)clientsAuthorizationKeys forPeriod:(NSUInteger)period
                       fromView:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub grantAllAccessRightsForChannel:channel forPeriod:period clients:clientsAuthorizationKeys
               withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsChangeError) {
                   
                   if (accessRightsChangeError) {
                       
                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights change"
                                                                           message:[NSString stringWithFormat:@"Failed to change access rights for channels:%@.\nClients: %@\n\nReason: %@",
                                                                                    channel, clientsAuthorizationKeys, [accessRightsChangeError localizedFailureReason]]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                       [alertView show];
                   }
                   
                   handleBlock(collection, accessRightsChangeError);
               }];
}


#pragma mark - Revoke delegate methods

- (void)revokeApplicationAccessRights:(PNChangeAccessRightsView *)accessRightsChangeView withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsRevokeError) {
        
        if (accessRightsRevokeError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights revoke"
                                                                message:[NSString stringWithFormat:@"Failed to revoke access rights for application.\n\nReason: %@",
                                                                         [accessRightsRevokeError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, accessRightsRevokeError);
    }];
}

- (void)revokeAccessRightsFromChannels:(NSArray *)channels fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                      withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub revokeAccessRightsForChannels:channels withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsRevokeError) {
        
        if (accessRightsRevokeError) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights revoke"
                                                                message:[NSString stringWithFormat:@"Failed to revoke access rights for channels:%@.\n\nReason: %@",
                                                                         channels, [accessRightsRevokeError localizedFailureReason]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        handleBlock(collection, accessRightsRevokeError);
    }];
}

- (void)revokeAccessRightsFromChannel:(PNChannel *)channel forClients:(NSArray *)clientsAuthorizationKeys fromView:(PNChangeAccessRightsView *)accessRightsChangeView
                     withHandlerBlock:(PNClientChannelAccessRightsChangeBlock)handleBlock {
    
    [PubNub revokeAccessRightsForChannel:channel clients:clientsAuthorizationKeys
             withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *accessRightsRevokeError) {
                 
                 if (accessRightsRevokeError) {
                     
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access rights revoke"
                                                                         message:[NSString stringWithFormat:@"Failed to revoke access rights for channels:%@.\nClients: %@\n\nReason: %@",
                                                                                  channel, clientsAuthorizationKeys, [accessRightsRevokeError localizedFailureReason]]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                     [alertView show];
                 }
                 
                 handleBlock(collection, accessRightsRevokeError);
             }];
}


#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // Check whether user would like to cancek retry attempt or not
    if ([alertView cancelButtonIndex] == buttonIndex) {
        
        self.channelForRetry = nil;
        self.messageForRetry = nil;
    }
}


#pragma mark - UITextField delegate methods

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {

    NSString *inputtedMessage = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateMessageSendingInterfaceWithMessage:inputtedMessage];


    return YES;
}


#pragma mark - UITableView delegate methods

/**
 * Retrieve from delegate title of delete confirmation button from delegate
 * for table at specified index path
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {

    return @"Unsubscribe";
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    return [self.channelsTableView isEqual:tableView]?indexPath:nil;
}

/**
 * UITableView by calling this method notify delegate about that user selected
 * one of table rows
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Check whether user selected item from table with channels list or not
    if ([self.channelsTableView isEqual:tableView]) {

        // Update current channel in data modelmanager
        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        [PNDataManager sharedInstance].currentChannel = channel;
    }
}


#pragma mark UITableView data source delegate methods

/**
 * Retrieve from data source delegate number of rows for table in
 * specified section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger numberOfRows = 0;

    if ([tableView isEqual:self.channelsTableView]) {

        numberOfRows = [[PNDataManager sharedInstance].subscribedChannelsList count];
    }
    else {

        numberOfRows = [[PNDataManager sharedInstance].currentChannel.participants count];
    }

    return numberOfRows;
}

/**
 * Retrieve cached instance or create new cell row instance for data
 * layout at specified index path
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Initialize possible cell identifiers
    static NSString *channelCellIdentifier = @"channelCell";
    static NSString *participantCellIdentifier = @"participantCell";

    NSString *targetCellIdentifier = channelCellIdentifier;
    if ([tableView isEqual:self.channelParticipantsTableView]) {

        targetCellIdentifier = participantCellIdentifier;
    }

    // Try retrieve reference on cached instance
    id cell = [tableView dequeueReusableCellWithIdentifier:targetCellIdentifier];

    // Check whether cached instance copy retrieved or not
    if(cell == nil) {

        Class cellClass = [UITableViewCell class];
        if ([targetCellIdentifier isEqualToString:channelCellIdentifier]) {

            cellClass = [PNChannelCell class];
        }

        // Create new cell instance copy
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:targetCellIdentifier];
        ((UITableViewCell *)cell).selectionStyle = UITableViewCellSelectionStyleGray;
        ((UITableViewCell *)cell).backgroundColor = [UIColor clearColor];
        ((UITableViewCell *)cell).textLabel.textColor = [UIColor whiteColor];
        ((UITableViewCell *)cell).textLabel.highlightedTextColor = [UIColor darkGrayColor];
        ((UITableViewCell *)cell).textLabel.shadowColor = [UIColor blackColor];
        ((UITableViewCell *)cell).textLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    }

    if ([tableView isEqual:self.channelsTableView]) {

        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        [((PNChannelCell *)cell) updateForChannel:channel];
    }
    else {

        NSString *clientIdentifier = [[PNDataManager sharedInstance].currentChannel.participants objectAtIndex:indexPath.row];
        ((UITableViewCell *)cell).textLabel.text = clientIdentifier;
    }


    return cell;
}

/**
 * UITableView by calling this method asks data source delegate
 * whether it allow to edit row at specified index path or not
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return [tableView isEqual:self.channelsTableView];
}

- (void)tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PNChannel *channel = [[PNDataManager sharedInstance].subscribedChannelsList objectAtIndex:indexPath.row];
        if ([channel isEqual:[PNDataManager sharedInstance].currentChannel]) {

            [PNDataManager sharedInstance].currentChannel = nil;
        }

        [PubNub unsubscribeFromChannel:channel];
    }
}


/**
 * Asking view controller whether interface will be rotated to portrait
 * orientation or not
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

    BOOL shouldAutorotate = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        shouldAutorotate = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }


    return shouldAutorotate;
}

#pragma mark -


@end
