//
//  PNChannelHistoryView.h
// 
//
//  Created by moonlight on 1/21/13.
//
//


#import "PNChannelHistoryView.h"
#import "PNDataManager.h"
#import "PNMessage.h"
#import "PNMessage+Protected.h"


#pragma mark Structures

// This enum represents history view operation mode
typedef enum _PNHistoryViewMode {
    PNHistoryViewDefault,
    PNHistoryViewPaged
} PNHistoryViewMode;

// This enumerator represents direction in which user moves
// across history
typedef enum _PNHistoryViewPagingDirection {
    PNHistoryViewPagingPrevious,
    PNHistoryViewPagingNext
} PNHistoryViewPagingDirection;


#pragma mark Private interface methods

@interface PNChannelHistoryView () <UITextFieldDelegate, UIPopoverControllerDelegate>


#pragma mark - Properties

// Stores reference on traverse mode switch
@property (nonatomic, pn_desired_weak) IBOutlet UISwitch *traverseSwitch;

// Stores reference on text view which is used to layout list of messages
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *historyTextView;

// Stores reference on text field which is responsible for start
// date input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *startDateTextField;

// Stores reference on text field which is responsible for end
// date input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *endDateTextField;

// Stores reference on text field which is responsible for messages limit
// input
@property (nonatomic, pn_desired_weak) IBOutlet UITextField *limitTextField;

@property (nonatomic, pn_desired_weak) IBOutlet UIButton *closeButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *modeSwitchButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *previousButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *nextButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *downloadButton;
@property (nonatomic, pn_desired_weak) IBOutlet UIButton *clearButton;

// Stores on whether we are changing start date value or not
@property (nonatomic, assign, getter = isConfiguringStartDate) BOOL configuringStartDate;

// Stores direction in which user moves across history output
@property (nonatomic, assign) PNHistoryViewPagingDirection pagingDirection;

// Stores reference on popover controller which is used to show
// time frame selection date picker
@property (nonatomic, strong) UIPopoverController *datePickerPopoverController;

// Stores reference on current history view mode
@property (nonatomic, assign) PNHistoryViewMode viewMode;

// Stores reference on history time frame dates
@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;


#pragma mark - Interface customization

- (void)prepareInterface;
- (void)updateInterface;

#pragma mark - Handler methods

- (IBAction)modeSwitchButtonTapped:(id)sender;
- (IBAction)previousHistoryPageButtonTapped:(id)sender;
- (IBAction)nextHistoryPageButtonTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)downloadButtonTapped:(id)sender;
- (void)datePickerChangedValue:(id)sender;


#pragma mark - Misc methods

/**
 * Launch history download process
 */
- (void)downloadHistory;

/**
 * Show date picker for one of time frame selection fields
 */
- (void)showDatePicker;


@end


#pragma mark Public interface methods

@implementation PNChannelHistoryView


#pragma mark - Class methods

+ (id)viewFromNib {

    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

#pragma mark - Interface customization

- (void)awakeFromNib {

    // Forward to the super class to complete initialization
    [super awakeFromNib];

    self.viewMode = PNHistoryViewDefault;
    [self prepareInterface];


    [[PNObservationCenter defaultCenter] addMessageHistoryProcessingObserver:self
                                                                   withBlock:^(NSArray *messages,
                                                                           PNChannel *channel,
                                                                           PNDate *startDate,
                                                                           PNDate *endDate,
                                                                           PNError *error) {

               NSString *message = nil;
               if (error == nil) {

                   NSDateFormatter *dateFormatter = [NSDateFormatter new];
                   dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";

                   message = [NSString stringWithFormat:@"Downloaded history for: %@\nDownloaded %u messages\nStart date: %@\nEnd date: %@",
                                                        channel.name, [messages count],
                                                        [dateFormatter stringFromDate:startDate.date],
                                                        [dateFormatter stringFromDate:endDate.date]];
               }
               else {

                   message = [NSString stringWithFormat:@"History download failed with error: %@\nReason: %@\nSolution: %@",
                                                        error.localizedDescription,
                                                        error.localizedFailureReason,
                                                        error.localizedRecoverySuggestion];
               }


               UIAlertView *alertView = [UIAlertView new];
               alertView.title = @"History";
               alertView.message = message;
               [alertView addButtonWithTitle:@"OK"];
               [alertView show];
           }];
}

- (void)prepareInterface {

    UIImage *redButtonBackground = [UIImage imageNamed:@"red-button.png"];
    UIImage *stretchableButtonBackground = [redButtonBackground stretchableImageWithLeftCapWidth:5.0f
                                                                                    topCapHeight:5.0f];
    UIImage *whiteButtonBackground = [UIImage imageNamed:@"white-button.png"];
    UIImage *stretchableWhiteButtonBackground = [whiteButtonBackground stretchableImageWithLeftCapWidth:5.0f
                                                                                           topCapHeight:5.0f];
    [self.modeSwitchButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.previousButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:stretchableButtonBackground forState:UIControlStateNormal];
    [self.clearButton setBackgroundImage:stretchableWhiteButtonBackground forState:UIControlStateNormal];

    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.previousButton.hidden = YES;
    self.nextButton.hidden = YES;
}

- (void)updateInterface {

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"HH:mm:ss MM/dd/yy";

    self.startDateTextField.text = [dateFormatter stringFromDate:self.startDate.date];
    self.endDateTextField.text = [dateFormatter stringFromDate:self.endDate.date];
    
    self.endDateTextField.enabled = self.viewMode == PNHistoryViewDefault;
    self.endDateTextField.backgroundColor = self.endDateTextField.isEnabled ? [UIColor clearColor] : [UIColor lightGrayColor];
    [self.modeSwitchButton setTitle:(self.viewMode == PNHistoryViewDefault ? @"Paging Mode" : @"Non-Paging Mode") forState:UIControlStateNormal];
    if ([self.historyTextView.text length] == 0 && self.viewMode == PNHistoryViewPaged) {
        
        NSString *limitCount = [self.limitTextField.text length] > 0 ? self.limitTextField.text : @"100";
        self.historyTextView.text = [NSString stringWithFormat: @"Tap on \"Previous\" or \"Next\" button to begin loading last %@ messages from history",
                                     limitCount];
    }
    self.previousButton.hidden = self.viewMode != PNHistoryViewPaged;
    self.nextButton.hidden = self.viewMode != PNHistoryViewPaged;
    self.downloadButton.hidden = self.viewMode != PNHistoryViewDefault;
}


#pragma mark - Handler methods

- (IBAction)modeSwitchButtonTapped:(id)sender {
    
    if (self.viewMode == PNHistoryViewDefault) {
        
        self.limitTextField.text = @"10";
        self.viewMode = PNHistoryViewPaged;
    }
    else {
        
        self.limitTextField.text = @"100";
        self.viewMode = PNHistoryViewDefault;
    }
    self.traverseSwitch.enabled = self.viewMode == PNHistoryViewDefault;
    
    
    [self clearButtonTapped:nil];
}

- (IBAction)previousHistoryPageButtonTapped:(id)sender {
    
    self.pagingDirection = PNHistoryViewPagingPrevious;
    [self.traverseSwitch setOn:NO animated:YES];
    [self downloadHistory];
}

- (IBAction)nextHistoryPageButtonTapped:(id)sender {
    
    self.pagingDirection = PNHistoryViewPagingNext;
    [self.traverseSwitch setOn:YES animated:YES];
    [self downloadHistory];
}

- (IBAction)closeButtonTapped:(id)sender {

    [[PNObservationCenter defaultCenter] removeMessageHistoryProcessingObserver:self];
    [self removeFromSuperview];
}

- (IBAction)clearButtonTapped:(id)sender {

    self.startDate = nil;
    self.endDate = nil;
    self.historyTextView.text = nil;
    
    [self updateInterface];
}

- (IBAction)downloadButtonTapped:(id)sender {
    
    [self downloadHistory];
}

- (void)datePickerChangedValue:(id)sender {

    if (self.isConfiguringStartDate) {

        self.startDate = [PNDate dateWithDate:((UIDatePicker *)sender).date];
    }
    else {

        self.endDate = [PNDate dateWithDate:((UIDatePicker *)sender).date];
    }


    [self updateInterface];
}


#pragma mark - Misc methods

- (void)downloadHistory {
    
    PNChannelHistoryView *weakSelf = self;
    
    // Prepare completion handler block
    id historyDownloadCompletionHandler = ^(NSArray *messages,
                                            PNChannel *channel,
                                            PNDate *startDate,
                                            PNDate *endDate,
                                            PNError *error) {
        
        NSMutableString *historyToShow = [NSMutableString string];
        if (self.viewMode == PNHistoryViewPaged && [messages count] == 0) {
            
            NSString *directionString = self.pagingDirection == PNHistoryViewPagingPrevious ? @"previous" : @"next";
            historyToShow.string = [NSString stringWithFormat:@"There is no more %@ pages of history", directionString];
        }
        else {
            
            [messages enumerateObjectsUsingBlock:^(PNMessage *message,
                                                   NSUInteger messageIdx,
                                                   BOOL *messagesEnumerator) {
                
                [historyToShow appendFormat:@"> %@\n", message.message];
            }];
        }
        
        weakSelf.startDate = startDate;
        weakSelf.endDate = endDate;
        weakSelf.historyTextView.text = historyToShow;
        [weakSelf updateInterface];
    };
    
    if (self.viewMode == PNHistoryViewPaged) {
        
        [PubNub requestHistoryForChannel:[PNDataManager sharedInstance].currentChannel
                                    from:(self.pagingDirection == PNHistoryViewPagingPrevious ? self.startDate : self.endDate)
                                   limit:[self.limitTextField.text integerValue]
                          reverseHistory:self.traverseSwitch.isOn
                     withCompletionBlock:historyDownloadCompletionHandler];
    }
    else {
        
        [PubNub requestHistoryForChannel:[PNDataManager sharedInstance].currentChannel
                                    from:self.startDate
                                      to:self.endDate
                                   limit:[self.limitTextField.text integerValue]
                          reverseHistory:self.traverseSwitch.isOn
                     withCompletionBlock:historyDownloadCompletionHandler];
    }
}

- (void)showDatePicker {

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    NSDate *date = self.isConfiguringStartDate ? self.startDate.date : self.endDate.date;
    if (!date) {
        date = [NSDate new];
    }
    
    datePicker.date = date;
    
    [datePicker addTarget:self action:@selector(datePickerChangedValue:) forControlEvents:UIControlEventValueChanged];

    UIViewController *datePickerViewController = [UIViewController new];
    CGSize sizeInPopover = datePicker.bounds.size;
    [datePickerViewController.view addSubview:datePicker];
    datePickerViewController.contentSizeForViewInPopover = sizeInPopover;

    CGRect targetFrame = self.isConfiguringStartDate ? self.startDateTextField.frame : self.endDateTextField.frame;
    self.datePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
    self.datePickerPopoverController.delegate = self;
    [self.datePickerPopoverController presentPopoverFromRect:targetFrame
                                       inView:self
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

#pragma mark - UIPopoverController delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {

    self.datePickerPopoverController = nil;
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    BOOL shouldShowDatePiker = ![textField isEqual:self.limitTextField];
    self.configuringStartDate = [textField isEqual:self.startDateTextField];

    if (shouldShowDatePiker) {

        [self showDatePicker];
    }


    return !shouldShowDatePiker;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self endEditing:YES];


    return YES;
}

#pragma mark -


@end
