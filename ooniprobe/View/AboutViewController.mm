#import "AboutViewController.h"
#import "Engine.h"
#import "VersionUtility.h"

@interface AboutViewController ()
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings.About.Label", nil);
    [NavigationBarUtility setNavigationBar:self.navigationController.navigationBar];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.headerView setBackgroundColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    [self.learnMoreButton setTitle:NSLocalizedString(@"Settings.About.Content.LearnMore", nil) forState:UIControlStateNormal];
    self.learnMoreButton.layer.cornerRadius = 20;
    self.learnMoreButton.layer.masksToBounds = YES;
    [self.learnMoreButton setTitleColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]
                        forState:UIControlStateNormal];
    [self.learnMoreButton setBackgroundColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]];
    
    [self.textLabel setText:NSLocalizedString(@"Settings.About.Content.Paragraph", nil)];
    [self.textLabel setTextColor:[UIColor colorWithRGBHexString:color_gray9 alpha:1.0f]];
    
    [self.ppButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Settings.About.Content.DataPolicy", nil)] forState:UIControlStateNormal];
    [self.ppButton setTitleColor:[UIColor colorWithRGBHexString:color_blue5 alpha:1.0f]
                        forState:UIControlStateNormal];
    
    [self.versionLabel setText:[NSString stringWithFormat:@"OONI Probe: %@\nmeasurement-kit: %@", [VersionUtility get_software_version], [Engine getVersionMK]]];
    [self.versionLabel setTextColor:[UIColor colorWithRGBHexString:color_white alpha:1.0f]];
}


-(IBAction)learnMore:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ooni.io/"]];
}


-(IBAction)privacyPolicy:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ooni.io/about/data-policy/"]];
}


@end
