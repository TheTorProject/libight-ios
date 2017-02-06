// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

#import "RunTestsViewController.h"

/*Include header from test*/
#include "measurement_kit/ooni.hpp"

#include "measurement_kit/common.hpp"

@interface RunTestsViewController ()
@property (readwrite) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation RunTestsViewController : UITableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealLeftView)];
    self.revealViewController.leftPresentViewHierarchically = YES;
    //self.revealViewController.leftToggleAnimationDuration = 0.8;
    self.revealViewController.toggleAnimationType = PBRevealToggleAnimationTypeSpring;

    //[self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"updateProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showToast) name:@"showToast" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    currentTests = [Tests currentTests];
    self.title = NSLocalizedString(@"run_tests", nil);
    [self reloadTable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.title = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"first_run"]){
        [self performSegueWithIdentifier:@"showInformedConsent" sender:self];
    }
}

-(void)reloadTable{
    if ([TestStorage new_tests]){
        self.navigationItem.leftBarButtonItem.badgeValue = @" ";
        self.navigationItem.leftBarButtonItem.badgeBGColor = color_ok_green;
    }
    [self.tableView reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)runTests:(id)sender event:(id)event {
    CGPoint currentTouchPosition = [[[event allTouches] anyObject] locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    NetworkMeasurement *current = [currentTests.availableNetworkMeasurements objectAtIndex:indexPath.row];
    [current run];
    [self.tableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentTests.availableNetworkMeasurements count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NetworkMeasurement *current;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_test" forIndexPath:indexPath];
    current = [currentTests.availableNetworkMeasurements objectAtIndex:indexPath.row];
    UILabel *title = (UILabel*)[cell viewWithTag:1];
    UILabel *subtitle = (UILabel*)[cell viewWithTag:2];
    UIImageView *image = (UIImageView*)[cell viewWithTag:3];
    RunButton *runTest = (RunButton*)[cell viewWithTag:4];
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView*)[cell viewWithTag:5];
    UIProgressView *bar = (UIProgressView*)[cell viewWithTag:6];
    [title setText:NSLocalizedString(current.name, nil)];
    NSString *test_desc = [NSString stringWithFormat:@"%@_desc", current.name];
    [subtitle setText:NSLocalizedString(test_desc, nil)];
    [runTest setTitle:NSLocalizedString(@"run", nil) forState:UIControlStateNormal];
    [image setImage:[UIImage imageNamed:current.name]];
    if (current.running){
        [bar setHidden:NO];
        [bar setProgress:current.progress animated:NO];
        [subtitle setText:current.progress_text];
        [indicator setHidden:FALSE];
        [runTest setHidden:TRUE];
        [indicator startAnimating];
    }
    else {
        [indicator setHidden:TRUE];
        [runTest setHidden:FALSE];
        [indicator stopAnimating];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showToast{
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageAlignment = NSTextAlignmentCenter;
    style.messageColor = color_off_white;
    style.backgroundColor = color_ok_green;
    style.titleFont = [UIFont fontWithName:@"FiraSansOT-Bold" size:15];
    [self.view makeToast:NSLocalizedString(@"ooniprobe_configured", nil) duration:3.0 position:CSToastPositionBottom style:style];
}

-(NSArray*)getItems:(NSString*)json_file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:json_file];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *content = @"";
    if([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        //Cut out the last \n
        if ([content length] > 0) {
            content = [content substringToIndex:[content length]-1];
        }
    }
    return [content componentsSeparatedByString:@"\n"];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"toInfo"]){
        TestInfoViewController *vc = (TestInfoViewController * )segue.destinationViewController;
        NetworkMeasurement *current = [currentTests.availableNetworkMeasurements objectAtIndex:indexPath.row];
        [vc setTestName:current.name];
    }
}

@end
