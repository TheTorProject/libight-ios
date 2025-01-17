#import "SettingsCategoriesTableViewController.h"
#import "UIDevice-DeviceInfo.h"

@interface SettingsCategoriesTableViewController ()

@end

@implementation SettingsCategoriesTableViewController

- (void)awakeFromNib{
    [super awakeFromNib];
    self.title = NSLocalizedString(@"Settings.Title", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // remove separator
    self.tableView.backgroundColor = [UIColor colorNamed:@"color_gray1"];
    [NavigationBarUtility setNavigationBar:self.navigationController.navigationBar];
    categories = [SettingsUtility getSettingsCategories];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"";
    self.title = NSLocalizedString(@"Settings.Title", nil);
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *current = [categories objectAtIndex:indexPath.row];
    cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
    cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
    cell.imageView.image = [UIImage imageNamed:current];
    cell.backgroundColor = [UIColor colorNamed:@"color_gray1"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *current = [categories objectAtIndex:indexPath.row];
    if ([current isEqualToString:@"about_ooni"] ||
        [current isEqualToString:@"ooni_backend_proxy"]){
        [self performSegueWithIdentifier:current sender:self];
    }
    else if ([current isEqualToString:@"send_email"]){
        [self sendEmail];
    }
    else
        [self performSegueWithIdentifier:@"toSettings" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)sendEmail{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"[bug-report] OONI Probe iOS %@", [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]]];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"bugs@openobservatory.org", nil];
        [mailer setToRecipients:toRecipients];
        NSString *device = [NSString stringWithFormat:@"%@\n\n\napp_version %@\ndevice_model %@\nos_version %@",
                            NSLocalizedString(@"Settings.SendEmail.Message", nil),
                            [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"],
                            [UIDevice currentDevice].modelIdentifier,
                            [UIDevice currentDevice].systemVersion];
        [mailer setMessageBody:device isHTML:NO];
        [[mailer navigationBar] setTranslucent:NO];
        [[mailer navigationBar] setTintColor:[UIColor colorNamed:@"color_white"]];
        [[mailer navigationBar] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorNamed:@"color_white"], NSForegroundColorAttributeName, [UIFont fontWithName:@"FiraSans-SemiBold" size:16], NSFontAttributeName, nil]];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertAction* copyButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"TestResults.Details.CopyToClipboard", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                       pasteboard.string = @"bugs@openobservatory.org";
                                       [MessageUtility showToast:NSLocalizedString(@"Toast.CopiedToClipboard", nil) inView:self.view];
                                   }];
        [MessageUtility alertWithTitle:NSLocalizedString(@"Settings.SendEmail.Label", nil)
                               message:NSLocalizedString(@"Settings.SendEmail.Error", nil)
                              okButton:copyButton
                                inView:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toSettings"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SettingsTableViewController *vc = (SettingsTableViewController * )segue.destinationViewController;
        NSString *current = [categories objectAtIndex:indexPath.row];
        [vc setCategory:current];
    }
}


@end
