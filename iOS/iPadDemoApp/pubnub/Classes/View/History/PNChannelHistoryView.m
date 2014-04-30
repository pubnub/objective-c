//
//  PNChannelHistoryView.m
//  pubnub
//
//  Created by Sergey Mamontov on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelHistoryView.h"
#import "NSString+PNLocalization.h"
#import "NSObject+PNAddition.h"
#import "UIView+PNAddition.h"
#import "PNHistoryHelper.h"
#import "PNConsoleView.h"
#import "PNChannelCell.h"
#import "PNAlertView.h"
#import "PNButton.h"


#pragma mark Static

static NSTimeInterval const kPNViewAppearAnimationDuration = 0.4f;
static NSTimeInterval const kPNViewDisappearAnimationDuration = 0.2f;


#pragma mark - Structures

/**
 Enum fields represence mode in which view should work and handel user actions.
 */
typedef enum _PNHistoryMode {
    
    PNFullChannelHistoryMode,
    PNPeriodChannelHistoryMode
} PNHistoryMode;


#pragma mark - Private interface declaration

@interface PNChannelHistoryView () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
                                    UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate>


#pragma mark - Properties

/**
 Stores reference on button which can be used by user to initiate history request process.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *requestHistoryButton;

/**
 Stores reference on channel name input text field.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *channelNameTextField;

/**
 Stores reference on table view which will present list of channels on which \b PubNub client subscribed at this moment.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *channelsList;

/**
 Stores reference on text field which allow user to provide maximum number of messages which should be returned from
 \b PubNub service.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *messagesCountLimitTextField;

/**
 Stores reference on text field which allow to specify history request start date.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *startDateInputTextField;

/**
 Stores reference on text field which allow to specify history request start date.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *endDateInputTextField;

/**
 Stores reference on switch which allow to specify whether \b PubNub client should place older messages at the begining
 of response or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *traverseSwitch;

/**
 Stores reference on switch which allow to specify whether \b PubNub service should return messages send date or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *fetchTimeTokensSwitch;

/**
 Stores reference on switch which allow to specify whether UI should be used in paged history view mode or not.
 */
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *pagingModeSwitch;

/**
 Stores reference on history paging navigatino buttons.
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *previousPageButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *nextPageButton;

/**
 Stores reference on \b PNConsoleView which is used for messages layout (it will append styles on some of messages).
 */
@property (nonatomic, pn_desired_weak) IBOutlet PNConsoleView *consoleView;

/**
 Stores reference on history helper which will perform and handle all history requests.
 */
@property (nonatomic, strong) IBOutlet PNHistoryHelper *historyHelper;

/**
 Stores current history view operation mode.
 */
@property (nonatomic, assign) PNHistoryMode mode;

/**
 Stores reference on popover view which hold required content.
 */
@property (nonatomic, strong) UIPopoverController *pickerPopoverController;

@property (nonatomic, assign, getter = isSelectingStartDate) BOOL selectingStartDate;

/**
 Stores whether recent history request page was empty or not.
 */
@property (nonatomic, assign, getter = isEmptyHistoryPage) BOOL emptyHistoryPage;


#pragma mark - Class methods

/**
 Methods allow to retrieve name of the NIB file depending on required action.
 
 @return Name for target NIB file which should be loaded.
 */
+ (NSString *)viewNibNameForFullChannelHistory;
+ (NSString *)viewNibNameForChannelHistory;


#pragma mark - Instance methods

- (void)prepareHistoryView;
- (void)updateLayout;

/**
 Process provided messages and show them to the user.
 
 @param messages
 List of \b PNMessage instances which should be displayed to the user.
 */
- (void)showNewMessages:(NSArray *)messages;

/**
 Prepare and show popover view for specified view.
 
 @param textField
 Text field for which popover view should be presented with required content.
 */
- (void)showPopoverForField:(UITextField *)textField;


#pragma mark - Handler methods

- (IBAction)handleRequestHistoryButtonTap:(id)sender;
- (IBAction)handleCloseButtonTap:(id)sender;
- (IBAction)handlePagingSwitchStateChange:(id)sender;
- (IBAction)handlePreviousHistoryPageButtonTap:(id)sender;
- (IBAction)handleNextHistoryPageButtonTap:(id)sender;
- (void)datePickerChangedValue:(UIDatePicker *)datePicker;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation PNChannelHistoryView


#pragma mark - Class methods

+ (instancetype)viewFromNibForFullChannelHistory {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForFullChannelHistory)];
    
    PNChannelHistoryView *view = [self viewFromNib];
    view.mode = PNFullChannelHistoryMode;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForFullChannelHistory)];
    
    
    return view;
}

+ (instancetype)viewFromNibForChannelHistory {
    
    // Swap method which should provide name for NIB file.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelHistory)];
    
    PNChannelHistoryView *view = [self viewFromNib];
    view.mode = PNPeriodChannelHistoryMode;
    
    // Swap method implementation back to restore original.
    [self swizzleMethod:@selector(viewNibName) with:@selector(viewNibNameForChannelHistory)];
    
    
    return view;
}

+ (NSString *)viewNibNameForFullChannelHistory {
    
    return @"PNChannelFullHistoryView";
}

+ (NSString *)viewNibNameForChannelHistory {
    
    return @"PNChannelHistoryView";
}


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepareHistoryView];
    [self updateLayout];
}

- (NSTimeInterval)appearAnimationDuration {
    
    return kPNViewAppearAnimationDuration;
}

- (NSTimeInterval)disappearAnimationDuration {
    
    return kPNViewDisappearAnimationDuration;
}

- (void)prepareHistoryView {
    
    self.emptyHistoryPage = NO;
    self.historyHelper.maximumNumberOfMessages = 100;
}

- (void)updateLayout {
    
    self.requestHistoryButton.enabled = (self.historyHelper.channelName && ![self.historyHelper.channelName isEmpty] &&
                                         !self.pagingModeSwitch.isOn);
    if (self.mode == PNPeriodChannelHistoryMode && self.requestHistoryButton.isEnabled) {
        
        self.requestHistoryButton.enabled = (self.historyHelper.startDate && self.historyHelper.endDate);
    }
    self.endDateInputTextField.enabled = !self.pagingModeSwitch.isOn;
    self.endDateInputTextField.backgroundColor = (self.endDateInputTextField.isEnabled ? [UIColor clearColor] : [UIColor lightGrayColor]);
    self.endDateInputTextField.textColor = (self.endDateInputTextField.isEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.3f alpha:0.6f]);
    
    self.traverseSwitch.enabled = !self.pagingModeSwitch.isOn;
    
    self.messagesCountLimitTextField.text = [NSString stringWithFormat:@"%d", (unsigned int)self.historyHelper.maximumNumberOfMessages];
    
    BOOL canUsePagedHistory = (self.historyHelper.channelName && ![self.historyHelper.channelName isEmpty]);
    self.previousPageButton.enabled = canUsePagedHistory;
    self.previousPageButton.hidden = !self.pagingModeSwitch.isOn;
    self.nextPageButton.enabled = canUsePagedHistory;
    self.nextPageButton.hidden = !self.pagingModeSwitch.isOn;
    
    if (self.historyHelper.shouldFetchHistoryByPages && self.isEmptyHistoryPage) {
        
        if (self.historyHelper.shouldFetchNextHistoryPage && canUsePagedHistory) {
            
            self.nextPageButton.enabled = NO;
        }
        else if (!self.historyHelper.shouldFetchNextHistoryPage && canUsePagedHistory) {
            
            self.previousPageButton.enabled = NO;
        }
    }
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm MM/dd/yy";
    
    self.startDateInputTextField.text = [dateFormatter stringFromDate:self.historyHelper.startDate.date];
    self.endDateInputTextField.text = [dateFormatter stringFromDate:self.historyHelper.endDate.date];
}

- (void)showNewMessages:(NSArray *)messages {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    [messages enumerateObjectsUsingBlock:^(PNMessage *message, NSUInteger messageIdx, BOOL *messagesEnumerator) {
        
        NSString *sendDate = (message.receiveDate ? [dateFormatter stringFromDate:message.receiveDate.date] : nil);
        NSString *consoleOutput = [NSString stringWithFormat:@"%@ %@\n", (sendDate ? [NSString stringWithFormat:@"<%@>", sendDate] : @">"), message.message];
        [self.consoleView addOutput:consoleOutput];
    }];
}

- (void)showPopoverForField:(UITextField *)textField {
    
    id picker = nil;
    CGSize pickerSize;
    if ([textField isEqual:self.messagesCountLimitTextField]) {
        
        picker = [UIPickerView new];
        ((UIPickerView *)picker).delegate = self;
        ((UIPickerView *)picker).dataSource = self;
        pickerSize = ((UIPickerView *)picker).bounds.size;
    }
    else {
        
        picker = [UIDatePicker new];
        ((UIDatePicker *)picker).datePickerMode = UIDatePickerModeDateAndTime;
        
        self.selectingStartDate = [textField isEqual:self.startDateInputTextField];
        NSDate *date = (self.isSelectingStartDate ? self.historyHelper.startDate.date : self.historyHelper.endDate.date);
        NSDate *currentDate = [NSDate date];
        
        if (!date) {
            
            date = currentDate;
            if (self.isSelectingStartDate) {
                
                self.historyHelper.startDate = [PNDate dateWithDate:date];
            }
            else {
                
                self.historyHelper.endDate = [PNDate dateWithDate:date];
            }
            [self updateLayout];
        }
        ((UIDatePicker *)picker).date = date;
        pickerSize = ((UIDatePicker *)picker).bounds.size;
        
        [(UIDatePicker *)picker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    
    UIViewController *pickerViewController = [UIViewController new];
    [pickerViewController.view addSubview:picker];
    pickerViewController.contentSizeForViewInPopover = pickerSize;
    
    CGRect targetFrame = textField.frame;
    self.pickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:pickerViewController];
    self.pickerPopoverController.delegate = self;
    [self.pickerPopoverController presentPopoverFromRect:targetFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp
                                                animated:YES];
}

- (void)configureForChannel:(PNChannel *)channel {
    
    self.historyHelper.channelName = channel.name;
    self.channelNameTextField.text = channel.name;
    
    [self updateLayout];
}

- (void)setMode:(PNHistoryMode)mode {

    BOOL isModeChanged = _mode != mode;
    _mode = mode;

    if (isModeChanged) {

        [self prepareHistoryView];
        [self updateLayout];
    }
}

#pragma mark - Handler methods

- (IBAction)handleRequestHistoryButtonTap:(id)sender {

    [self completeUserInput];

    self.historyHelper.fetchTimeTokens = self.fetchTimeTokensSwitch.isOn;
    self.historyHelper.fetchHistoryByPages = self.pagingModeSwitch.isOn;
    self.historyHelper.traverseHistory = self.traverseSwitch.isOn;
    
    PNAlertView *progressAlertView = [PNAlertView viewForProcessProgress];
    [progressAlertView show];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self.historyHelper fetchHistoryWithBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *requestError) {
        
        [progressAlertView dismissWithAnimation:YES];
        
        PNAlertType type = (requestError ? PNAlertWarning : PNAlertSuccess);
        NSString *title = (requestError ? @"historyFailureAlertViewShortDescription" : @"historySuccessAlertViewShortDescription");
        NSString *shortDescription = (requestError ? @"historyFailureAlertViewShortDescription" : @"historySuccessAlertViewShortDescription");
        NSString *detailedDescription = [NSString stringWithFormat:[@"historySuccessAlertViewDetailedDescription" localized],
                                         channel.name];
        
        if (!requestError) {
            
            weakSelf.emptyHistoryPage = [messages count] == 0;
            BOOL isValidStartDate = ([startDate.date timeIntervalSince1970] > 0);
            BOOL isValidEndDate = ([endDate.date timeIntervalSince1970] > 0);
            if ((isValidStartDate || isValidEndDate) && [messages count]) {
                
                [weakSelf.consoleView setOutputTo:@""];
                [weakSelf showNewMessages:messages];
            }
            
            weakSelf.historyHelper.startDate = (isValidStartDate ? startDate : weakSelf.historyHelper.startDate);
            weakSelf.historyHelper.endDate = (isValidEndDate ? endDate : weakSelf.historyHelper.endDate);
        }
        else {
            
            [weakSelf.consoleView setOutputTo:@""];
            
            detailedDescription = [NSString stringWithFormat:[@"historyFailureAlertViewDetailedDescription" localized],
                                   channel.name, requestError.localizedFailureReason];
        }
        
        PNAlertView *alert = [PNAlertView viewWithTitle:title type:type shortMessage:shortDescription
                                        detailedMessage:detailedDescription cancelButtonTitle:@"confirmButtonTitle"
                                      otherButtonTitles:nil andEventHandlingBlock:NULL];
        [alert show];
        
        [weakSelf updateLayout];
    }];
}

- (IBAction)handleCloseButtonTap:(id)sender {
    
    [self dismissWithOptions:PNViewAnimationOptionTransitionFadeOut animated:YES];
}

- (IBAction)handlePagingSwitchStateChange:(id)sender {
    
    self.emptyHistoryPage = NO;
    if (((UISwitch *)sender).isOn) {
        
        self.historyHelper.maximumNumberOfMessages = (self.historyHelper.maximumNumberOfMessages == 100 ? 10 : self.historyHelper.maximumNumberOfMessages);
    }
    else {
        
        self.historyHelper.maximumNumberOfMessages = (self.historyHelper.maximumNumberOfMessages == 10 ? 100 : self.historyHelper.maximumNumberOfMessages);
    }
    self.historyHelper.fetchNextHistoryPage = NO;
    
    [self updateLayout];
}

- (IBAction)handlePreviousHistoryPageButtonTap:(id)sender {
    
    self.historyHelper.fetchNextHistoryPage = NO;
    [self.traverseSwitch setOn:NO animated:YES];
    [self handleRequestHistoryButtonTap:nil];
}

- (IBAction)handleNextHistoryPageButtonTap:(id)sender {
    
    self.historyHelper.fetchNextHistoryPage = YES;
    [self.traverseSwitch setOn:YES animated:YES];
    [self handleRequestHistoryButtonTap:nil];
}

- (void)datePickerChangedValue:(UIDatePicker *)datePicker {
    
    PNDate *date = [PNDate dateWithDate:datePicker.date];
    if (self.isSelectingStartDate) {
        
        self.historyHelper.startDate = date;
    }
    else {
        
        self.historyHelper.endDate = date;
    }
    
    [self updateLayout];
}


#pragma mark - UIPopoverController delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.pickerPopoverController = nil;
}


#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%d", (int)(row + 1)];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 40.0f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.historyHelper.maximumNumberOfMessages = (row + 1);
    
    [self updateLayout];
}


#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.channelNameTextField]) {
        
        NSString *targetText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.historyHelper.channelName = targetText;
        
        [self updateLayout];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    BOOL shouldBeginEditing = [textField isEqual:self.channelNameTextField];
    if (!shouldBeginEditing) {
        
        [self completeUserInput];
        [self showPopoverForField:textField];
    }
    
    
    return shouldBeginEditing;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.historyHelper channels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *channelCellIdentifier = @"channelCellIdentifier";
    PNChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:channelCellIdentifier];
    if (!cell) {
        
        cell = [[PNChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:channelCellIdentifier];
        cell.showBadge = NO;
    }
    PNChannel *channel = [[self.historyHelper channels] objectAtIndex:indexPath.row];
    [cell updateForChannel:channel];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PNChannel *channel = [[self.historyHelper channels] objectAtIndex:indexPath.row];
    self.historyHelper.channelName = channel.name;
    self.channelNameTextField.text = channel.name;
    [self updateLayout];
}

#pragma mark -


@end
