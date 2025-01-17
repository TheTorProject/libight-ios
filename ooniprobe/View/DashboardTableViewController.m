#import "DashboardTableViewController.h"
#import "DashboardTableViewCell.h"
#import "ThirdPartyServices.h"
#import "Suite.h"
#import "RunningTest.h"
#import "ooniprobe-Swift.h"

@interface DashboardTableViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewForShadowRunButton;
@property (weak, nonatomic) IBOutlet UILabel *lastrunLabel;

@end

@implementation DashboardTableViewController
@synthesize items;

- (void)awakeFromNib{
    [super awakeFromNib];
    self.title = NSLocalizedString(@"Dashboard.Tab.Label", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setShadowRunButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTests) name:@"settingsChanged" object:nil];
    [NavigationBarUtility setNavigationBar:self.navigationController.navigationBar];
    [self loadTests];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConstraints) name:@"networkTestEndedUI" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self reloadConstraints];
    self.title = @"";
    self.title = NSLocalizedString(@"Dashboard.Tab.Label", nil);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showHideVPNToast];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)reloadConstraints{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([RunningTest currentTest].isTestRunning){
            self.tableFooterConstraint.constant = 64;
            [self.tableView setNeedsUpdateConstraints];
        }
        else {
            //If this number is > 0 there are still test running
            if ([[RunningTest currentTest].testSuites count] == 0){
                self.tableFooterConstraint.constant = 0;
                [self.tableView setNeedsUpdateConstraints];
            }
        }
        [self.tableView reloadData];
        [self reloadLastMeasurement];
    });
}

-(void)showHideVPNToast{
    if ([[ReachabilityManager sharedManager] isVPNConnected] && [SettingsUtility isWarnVPNInUse]){
        dispatch_async(dispatch_get_main_queue(), ^{
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor colorNamed:@"color_red7"];
            [self.view makeToast:NSLocalizedString(@"Modal.DisableVPN.Title", nil)
                        duration:10
                        position:CSToastPositionBottom
                           style:style];
        });
    }
    else
        [self.view hideAllToasts];
}

-(void)setShadowRunButton{
    self.runButton.layer.cornerRadius = 20;
    self.runButton.layer.masksToBounds = YES;
    [self.runButton setImage:[self resizeImage:[UIImage imageNamed:@"timer"] newWidth:23 newHeight:25] forState:UIControlStateNormal];
    self.runButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.runButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.runButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [self.runButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Card.Run", nil)] forState:UIControlStateNormal];

    self.viewForShadowRunButton.backgroundColor = [UIColor clearColor];

    self.viewForShadowRunButton.layer.shadowColor   = [[UIColor colorNamed:@"color_black"] colorWithAlphaComponent:0.8f].CGColor;
}

-(void)loadTests{
    items = [[OONIDescriptor getOONIDescriptors] mutableCopy];
    [self.tableView reloadData];
}

-(void)reloadLastMeasurement{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *ago;
        SRKResultSet *results = [[[[Result query] limit:1] orderByDescending:@"start_time"] fetch];
        if ([results count] > 0){
            ago = [[[results objectAtIndex:0] start_time] timeAgoSinceNow];
        }
        else
            ago = NSLocalizedString(@"Dashboard.Overview.LastRun.Never", nil);
        [self.lastrunLabel setText:[NSString stringWithFormat:@"%@ %@",
                                          NSLocalizedString(@"Dashboard.Overview.LatestTest", nil),
                                          ago]];
    });
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DashboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    OONIDescriptor *test = [items objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[DashboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell setDescriptor:test];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"OONI TESTS";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


-(IBAction)run:(id)sender{
    if ([TestUtility checkConnectivity:self] &&
        [TestUtility checkTestRunning:self]){
        UITableViewCell* cell = (UITableViewCell*)[[[sender superview] superview] superview];
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        AbstractSuite *testSuite = [items objectAtIndex:indexPath.row];
        [[RunningTest currentTest] setAndRun:[NSMutableArray arrayWithObject:testSuite] inView: self];
        [self reloadConstraints];
    }
}

-(IBAction)runAll{
    if ([TestUtility checkConnectivity:self] &&
        [TestUtility checkTestRunning:self]){
        // convert items to DynamicTestSuite
        NSMutableArray *testSuites = [[NSMutableArray alloc] init];
        for (OONIDescriptor *decriptor in self.items){
            [testSuites addObject:[[DynamicTestSuite alloc] initWithDescriptor:decriptor]];
        }
        [[RunningTest currentTest] setAndRun:testSuites inView: self];
        [self reloadConstraints];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toTestOverview"]){
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        TestOverviewViewController *vc = (TestOverviewViewController * )segue.destinationViewController;
        OONIDescriptor *test = [items objectAtIndex:indexPath.row];
        [vc setDescriptor:test];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
