#import "TestOverviewViewController.h"
#import "ThirdPartyServices.h"
#import "RunningTest.h"
#import "ooniprobe-Swift.h"

@interface TestOverviewViewController ()

@end

@implementation TestOverviewViewController
@synthesize descriptor;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLastMeasurement) name:@"networkTestEndedUI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:@"settingsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeConstraints) name:@"networkTestEndedUI" object:nil];

    [self.testNameLabel setText:[LocalizationUtility getNameForTest:[descriptor performSelector:@selector(name)]]];
    NSString *testLongDesc = [LocalizationUtility getLongDescriptionForTest:[descriptor performSelector:@selector(name)]];
    [self.testDescriptionLabel setFont:[UIFont fontWithName:@"FiraSans-Regular" size:14]];
    [self.testDescriptionLabel setTextColor:[UIColor colorNamed:@"color_gray9"]];
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    linkAttributes[(NSString *) kCTUnderlineStyleAttributeName] = @YES;
    linkAttributes[(NSString *) kCTForegroundColorAttributeName] = [UIColor colorNamed:@"color_base"];
    self.testDescriptionLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:linkAttributes];
    [self.testDescriptionLabel setMarkdown:testLongDesc];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.view.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft) {
            self.testDescriptionLabel.textAlignment = NSTextAlignmentRight;
        }
    } else {
        if ([NSLocale characterDirectionForLanguage:[NSLocale preferredLanguages][0]] == NSLocaleLanguageDirectionRightToLeft) {
            self.testDescriptionLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    [self.testDescriptionLabel setDidSelectLinkWithURLBlock:^(RHMarkdownLabel *label, NSURL *url) {
        [[UIApplication sharedApplication] openURL:url];
    }];
    [self.runButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Overview.Run", nil)] forState:UIControlStateNormal];
    if ([[descriptor performSelector:@selector(name)] isEqualToString:@"websites"])
        [self.websitesButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Dashboard.Overview.ChooseWebsites", nil)] forState:UIControlStateNormal];
    else
        [self.websitesButton setHidden:YES];

    [self reloadLastMeasurement];
    [self.testImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [descriptor performSelector:@selector(name)]]]];
    defaultColor = [TestUtility getBackgroundColorForTest:[descriptor performSelector:@selector(name)]];
    [self.runButton setTitleColor:defaultColor forState:UIControlStateNormal];
    [self.backgroundView setBackgroundColor:defaultColor];
    [NavigationBarUtility setNavigationBar:self.navigationController.navigationBar color:defaultColor];
    self.navigationController.navigationBar.topItem.title = @"";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [NavigationBarUtility setBarTintColor:self.navigationController.navigationBar
                                    color:defaultColor];
    [self changeConstraints];
}

-(void)changeConstraints{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([RunningTest currentTest].isTestRunning){
            self.tableFooterConstraint.constant = 64;
            [self.scrollView setNeedsUpdateConstraints];
        }
        else {
            //If this number is > 0 there are still test running
            if ([[RunningTest currentTest].testSuites count] == 0){
                self.tableFooterConstraint.constant = 0;
                [self.scrollView setNeedsUpdateConstraints];
            }
        }
    });
}

-(void)reloadLastMeasurement{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.estimatedLabel setText:NSLocalizedString(@"Dashboard.Overview.Estimated", nil)];
        [self.estimatedDetailLabel setText:
         [NSString stringWithFormat:@"%@ %@", [self->descriptor performSelector:@selector(dataUsage)],
          [LocalizationUtility getReadableRuntime:[[[DynamicTestSuite alloc] initWithDescriptor:self->descriptor] getRuntime]]]];
        [self.lastrunLabel setText:NSLocalizedString(@"Dashboard.Overview.LatestTest", nil)];
        
        NSString *ago;
        SRKResultSet *results = [[[[[Result query] limit:1] where:[NSString stringWithFormat:@"test_group_name = '%@'", [self->descriptor performSelector:@selector(name)]]] orderByDescending:@"start_time"] fetch];
        if ([results count] > 0){
            ago = [[[results objectAtIndex:0] start_time] timeAgoSinceNow];
        }
        else
            ago = NSLocalizedString(@"Dashboard.Overview.LastRun.Never", nil);
        [self.lastrunDetailLabel setText:ago];
    });
}

-(void)settingsChanged{
    // NOTE(aanorbel): Reload the descriptor when the settings change.
    [self reloadLastMeasurement];
}

-(NSInteger)daysBetweenTwoDates:(NSDate*)testDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:testDate
                                                          toDate:[NSDate date]
                                                         options:0];
    return components.day;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [NavigationBarUtility setBarTintColor:self.navigationController.navigationBar
                                        color:[UIColor colorNamed:@"color_blue5"]];
    }
}

-(IBAction)run:(id)sender{
    if ([TestUtility checkConnectivity:self] &&
        [TestUtility checkTestRunning:self]){
        [[RunningTest currentTest] setAndRun:[NSMutableArray arrayWithObject:[[DynamicTestSuite alloc] initWithDescriptor:descriptor]] inView: self];
        [self changeConstraints];
    }
}


/// NOTE(aanorbel): `performSegueWithIdentifier:@"toTestSettings"` is never called in the codebase thus, this method is not used.
/// I would like to remove it but needs to be sure of the impact.
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toTestSettings"]){
        SettingsTableViewController *vc = (SettingsTableViewController * )segue.destinationViewController;
        [vc setTestSuite:[[DynamicTestSuite alloc] initWithDescriptor:descriptor]];
    }
}


@end
