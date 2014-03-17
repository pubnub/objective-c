//
//  CTTestsViewController.m
//  ConfigurableTests
//
//  Created by Sergey Mamontov on 3/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "CTTestsViewController.h"
#import "CTTestEntryDelegate.h"
#import "CTTestEntryCell.h"
#import "CTDataManager.h"
#import "PNButton.h"


#pragma mark Static

static NSString * kCTTestEntryTableCellIdentifier = @"testEntryCell";
static CGFloat const kCTTestEntryTableCellHeight = 40.0f;


#pragma mark Private interface declaration

@interface CTTestsViewController () <UITableViewDelegate, UITableViewDataSource, CTTestEntryDelegate>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet UILabel *applicationInformationLabel;
@property (nonatomic, pn_desired_weak) IBOutlet UITableView *testsTableView;
@property (nonatomic, pn_desired_weak) IBOutlet UITextView *testProgressTextView;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *clearAllButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *clearButton;
@property (nonatomic, pn_desired_weak) IBOutlet PNButton *runSelectedButton;

@property (nonatomic, strong) NSMutableString *testProcessLog;


#pragma mark - Instance methods

/**
 Initial interface configuration for first appearance.
 */
- (void)prepareInterface;

/**
 Update interface layout to current data model state.
 */
- (void)updateInterface;

/**
 Upadting console output view.
 */
- (void)updateTestConsoleOutput;


#pragma mark - Handler methods

- (IBAction)handleClearAllButtonTap:(id)sender;
- (IBAction)handleClearSelectedButtonTap:(id)sender;
- (IBAction)handleRunSelectedButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation CTTestsViewController


#pragma mark - Instance methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    // Check whether initialization has been completed or not
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
            
            self.wantsFullScreenLayout = YES;
        }
    }
    
    
    return self;
}

- (void)viewDidLoad {
    
    // Forward to the super class to complete all intializations
    [super viewDidLoad];
    
    self.testProcessLog = [NSMutableString string];
    [self prepareInterface];
}

- (void)prepareInterface {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.applicationInformationLabel.text = [NSString stringWithFormat:@"%@ mode (PubNub cilent version %@)",
                                             (IS_ACTOR_ROLE ? @"Actor" : @"Listener"), CLIENT_VERSION];
    [self.testsTableView registerNib:[UINib nibWithNibName:@"CTTestEntryCell" bundle:nil]
              forCellReuseIdentifier:kCTTestEntryTableCellIdentifier];
    
    CGFloat targetContentHeight = kCTTestEntryTableCellHeight * [[CTDataManager sharedInstance] testsCount];
    self.testsTableView.scrollEnabled = (targetContentHeight > self.testsTableView.bounds.size.height);
    
    self.clearButton.enabled = NO;
    self.runSelectedButton.enabled = NO;
}

- (void)updateInterface {
    
    self.clearButton.enabled = [[CTDataManager sharedInstance] hasScheduledTests];
    self.runSelectedButton.enabled = [[CTDataManager sharedInstance] hasScheduledTests];
    [self updateTestConsoleOutput];
}

- (void)updateTestConsoleOutput {
    
    self.testProgressTextView.text = self.testProcessLog;
    NSRange range = NSMakeRange(self.testProgressTextView.text.length - 1, 1);
    [self.testProgressTextView scrollRangeToVisible:range];
}


#pragma mark - Handler methods

- (IBAction)handleClearAllButtonTap:(id)sender {
    
    [[CTDataManager sharedInstance] unscheduleAlltests];
    [[CTDataManager sharedInstance] resetTestStates];
    [self.testsTableView reloadData];
    [self.testProcessLog setString:@""];
    [self updateInterface];
}

- (IBAction)handleClearSelectedButtonTap:(id)sender {
    
    [[CTDataManager sharedInstance] unscheduleAlltests];
    [self.testsTableView reloadData];
    [self updateInterface];
}

- (IBAction)handleRunSelectedButtonTap:(id)sender {
    
    self.testsTableView.userInteractionEnabled = NO;
    self.clearAllButton.enabled = NO;
    self.clearButton.enabled = NO;
    self.runSelectedButton.enabled = NO;
    [self.testProcessLog setString:@""];
    __block NSUInteger processedTests = 0;
    [[CTDataManager sharedInstance] executeScheduledTestsWithStatusBlock:^(NSString *currentStatus, BOOL completed,
                                                                           BOOL successful, CTTest *activeTest) {
        if (currentStatus) {
            
            [self.testProcessLog appendFormat:@"%@\n", currentStatus];
        }
        
        if (completed || !successful) {
            
            processedTests++;
            if (processedTests == [[CTDataManager sharedInstance] scheduledTestsCount]) {
                
                self.testsTableView.userInteractionEnabled = YES;
                self.clearAllButton.enabled = YES;
                [self updateInterface];
            }
            [[CTDataManager sharedInstance] setState:(successful ? CTTestPassedState : CTTestFailedState) forTest:activeTest];
            [self.testsTableView reloadData];
        }
        [self updateTestConsoleOutput];
    }];
}


#pragma mark - CTTest entry delegate methods

- (void)didRunTest:(CTTest *)test {
    
    self.testsTableView.userInteractionEnabled = NO;
    self.clearAllButton.enabled = NO;
    self.clearButton.enabled = NO;
    self.runSelectedButton.enabled = NO;
    
    [self handleClearAllButtonTap:nil];
    [self.testProcessLog setString:@""];
    [[CTDataManager sharedInstance] scheduleTest:test];
    [[CTDataManager sharedInstance] executeScheduledTestsWithStatusBlock:^(NSString *currentStatus, BOOL completed,
                                                                           BOOL successful, CTTest *activeTest) {
        if (currentStatus) {
            
            [self.testProcessLog appendFormat:@"%@\n", currentStatus];
        }
        
        if (completed || !successful) {
            
            self.testsTableView.userInteractionEnabled = YES;
            self.clearAllButton.enabled = YES;
            [self updateInterface];
            
            [[CTDataManager sharedInstance] setState:(successful ? CTTestPassedState : CTTestFailedState) forTest:activeTest];
            [[CTDataManager sharedInstance] unscheduleTest:(activeTest ? activeTest : test)];
            [self.testsTableView reloadData];
        }
        [self updateTestConsoleOutput];
    }];
}


#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTTestEntryCell *selectedCell = (CTTestEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
    CTTest *test = [[[CTDataManager sharedInstance] tests] objectAtIndex:indexPath.row];
    
    if (!selectedCell.isMarked) {
        
        [[CTDataManager sharedInstance] scheduleTest:test];
    }
    else {
        
        [[CTDataManager sharedInstance] unscheduleTest:test];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self updateInterface];
}


#pragma mark - UITableView data source delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[CTDataManager sharedInstance] testsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTTest *test = [[[CTDataManager sharedInstance] tests] objectAtIndex:indexPath.row];
    CTTestEntryCell *testEntryCell = [tableView dequeueReusableCellWithIdentifier:kCTTestEntryTableCellIdentifier];
    [testEntryCell updateWithTest:test];
    testEntryCell.delegate = self;
    testEntryCell.marked = [[CTDataManager sharedInstance] isScheduledTest:test];
    testEntryCell.state = [[CTDataManager sharedInstance] stateForTest:test];
    
    
    return testEntryCell;
}


#pragma mark -


@end
