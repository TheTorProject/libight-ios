#import "Header1ViewController.h"
#import "SettingsUtility.h"
@interface Header1ViewController ()

@end

@implementation Header1ViewController
@synthesize result;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultUpdated:) name:@"resultUpdated" object:nil];

    [self.headerView setBackgroundColor:[TestUtility getBackgroundColorForTest:result.test_group_name]];
    [self addLabels];
    [self reloadMeasurement];
}

- (void)resultUpdated:(NSNotification *)notification
{
    if (result.Id != ((Result *) [notification object]).Id) {
        return;
    }
    result = [notification object];
    [self reloadMeasurement];
}

-(void)addLabels{
    if ([result.test_group_name isEqualToString:@"websites"] ||
        [result.test_group_name isEqualToString:@"instant_messaging"] ||
        [result.test_group_name isEqualToString:@"circumvention"]){
        [self.view4 setHidden:YES];
    }
    else if ([result.test_group_name isEqualToString:@"performance"]){
        if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
            [self addLine:self.view3];
        }
        else {
            [self addLine:self.view4];
        }
        [self.label1Top setText:NSLocalizedString(@"TestResults.Summary.Performance.Hero.Video", nil)];
        [self.label1Bottom setText:NSLocalizedString(@"TestResults.Summary.Performance.Hero.Video.Quality", nil)];
        [self.label2Top setText:NSLocalizedString(@"TestResults.Summary.Performance.Hero.Download", nil)];
        [self.label3Top setText:NSLocalizedString(@"TestResults.Summary.Performance.Hero.Upload", nil)];
        [self.label4Top setText:NSLocalizedString(@"TestResults.Summary.Performance.Hero.Ping", nil)];
        [self.label4Bottom setText:NSLocalizedString(@"TestResults.ms", nil)];
    }
    [self addLine:self.view2];
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [self addLine:self.view1];
    }
    else {
        [self addLine:self.view3];
    }
}

//TODO Refactor websites, instant_messaging, circumvention
-(void)reloadMeasurement{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([result.test_group_name isEqualToString:@"websites"]){
            [self.label1Top setHidden:YES];
            [self.label2Top setHidden:YES];
            [self.label3Top setHidden:YES];
            [self.label1Bottom setText:
             [LocalizationUtility getSingularPlural:result.totalMeasurements :@"TestResults.Summary.Websites.Hero.Tested"]];
            [self.label2Bottom setText:
             [LocalizationUtility getSingularPlural:result.anomalousMeasurements :@"TestResults.Summary.Websites.Hero.Blocked"]];
            [self.label3Bottom setText:
             [LocalizationUtility getSingularPlural:result.okMeasurements :@"TestResults.Summary.Websites.Hero.Reachable"]];
            [self.label1Central setText:[NSString stringWithFormat:@"%ld", result.totalMeasurements]];
            [self.label2Central setText:[NSString stringWithFormat:@"%ld", result.anomalousMeasurements]];
            [self.label3Central setText:[NSString stringWithFormat:@"%ld", result.okMeasurements]];
        }
        else if ([result.test_group_name isEqualToString:@"instant_messaging"]){
            [self.label1Top setHidden:YES];
            [self.label2Top setHidden:YES];
            [self.label3Top setHidden:YES];
            [self.label1Bottom setText:
             [LocalizationUtility getSingularPlural:result.totalMeasurements :@"TestResults.Summary.InstantMessaging.Hero.Tested"]];
            [self.label2Bottom setText:
             [LocalizationUtility getSingularPlural:result.anomalousMeasurements :@"TestResults.Summary.InstantMessaging.Hero.Blocked"]];
            [self.label3Bottom setText:
             [LocalizationUtility getSingularPlural:result.okMeasurements :@"TestResults.Summary.InstantMessaging.Hero.Reachable"]];
            [self.label1Central setText:[NSString stringWithFormat:@"%ld", result.totalMeasurements]];
            [self.label2Central setText:[NSString stringWithFormat:@"%ld", result.anomalousMeasurements]];
            [self.label3Central setText:[NSString stringWithFormat:@"%ld", result.okMeasurements]];
        }
        else if ([result.test_group_name isEqualToString:@"circumvention"]){
            [self.label1Top setHidden:YES];
            [self.label2Top setHidden:YES];
            [self.label3Top setHidden:YES];
            [self.label1Bottom setText:
             [LocalizationUtility getSingularPlural:result.totalMeasurements :@"TestResults.Summary.Circumvention.Hero.Tested"]];
            [self.label2Bottom setText:
             [LocalizationUtility getSingularPlural:result.anomalousMeasurements :@"TestResults.Summary.Circumvention.Hero.Blocked"]];
            [self.label3Bottom setText:
             [LocalizationUtility getSingularPlural:result.okMeasurements :@"TestResults.Summary.Circumvention.Hero.Reachable"]];
            [self.label1Central setText:[NSString stringWithFormat:@"%ld", result.totalMeasurements]];
            [self.label2Central setText:[NSString stringWithFormat:@"%ld", result.anomalousMeasurements]];
            [self.label3Central setText:[NSString stringWithFormat:@"%ld", result.okMeasurements]];
        }
        else if ([result.test_group_name isEqualToString:@"performance"]){
            TestKeys *testKeysNdt = [result getMeasurement:@"ndt"].testKeysObj;
            TestKeys *testKeysDash = [result getMeasurement:@"dash"].testKeysObj;
            [self setText:[testKeysNdt getDownload] forLabel:self.label2Central inStackView:self.view2];
            [self setText:[testKeysNdt getDownloadUnit] forLabel:self.label2Bottom inStackView:self.view2];
            [self setText:[testKeysNdt getUpload] forLabel:self.label3Central inStackView:self.view3];
            [self setText:[testKeysNdt getUploadUnit] forLabel:self.label3Bottom inStackView:self.view3];
            [self setText:[testKeysNdt getPing] forLabel:self.label4Central inStackView:self.view4];
            [self setText:[testKeysDash getVideoQuality:NO] forLabel:self.label1Central inStackView:self.view1];
        }
    });
}

-(void)setText:(NSString*)text forLabel:(UILabel*)label inStackView:(UIStackView*)stackView{
    if (text == nil)
        text = NSLocalizedString(@"TestResults.NotAvailable", nil);
    [label setText:text];
    if ([text isEqualToString:NSLocalizedString(@"TestResults.NotAvailable", nil)]){
        if (stackView == self.view1){
            [self.label1Top setAlpha:0.3f];
            [self.label1Central setAlpha:0.3f];
            [self.label1Bottom setAlpha:0.3f];
        }
        else if (stackView == self.view2){
            [self.label2Top setAlpha:0.3f];
            [self.label2Central setAlpha:0.3f];
            [self.label2Bottom setAlpha:0.3f];
        }
        else if (stackView == self.view3){
            [self.label3Top setAlpha:0.3f];
            [self.label3Central setAlpha:0.3f];
            [self.label3Bottom setAlpha:0.3f];
        }
        else if (stackView == self.view4){
            [self.label4Top setAlpha:0.3f];
            [self.label4Central setAlpha:0.3f];
            [self.label4Bottom setAlpha:0.3f];
        }
    }
}

-(void)addLine:(UIView*)view{
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, view.frame.size.height)];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:lineView];
}

@end
