#import "SettingsTableViewController.h"
#import "ThirdPartyServices.h"
#import "MBProgressHUD.h"
#import "BackgroundTask.h"

@interface SettingsTableViewController ()
@end

@implementation SettingsTableViewController
@synthesize category, testSuite;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTitle];
    self.navigationController.navigationBar.topItem.title = @"";

    keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self.view action:@selector(endEditing:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateTitle];
    [self reloadSettings];
}

/**
 * Update the title of the view controller.
 * If the view controller is for a category(enumerated in ``SettingsUtility/getSettingsCategories``), the title is the name of the category.
 * If the view controller is for a test suite, the title is the name of the test suite.
 */
- (void)updateTitle {
    self.title = @"";
    if (category != nil) {
        self.title = [LocalizationUtility getNameForSetting:category];
    } else if (testSuite != nil) {
        self.title = [LocalizationUtility getNameForTest:testSuite.name];
    }
}

-(void)reloadSettings {
    if (category != nil) {
        items = [SettingsUtility getSettingsForCategory:category];
    } else if (testSuite != nil) {
        items = [SettingsUtility getSettingsForTest:testSuite.name :YES];
    }
    //hide rows smooth
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // remove separator
        self.tableView.backgroundColor = [UIColor colorNamed:@"color_gray1"];
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (testSuite != nil){
        [testSuite.testList removeAllObjects];
        [testSuite getTestList];
    }
    if (testSuite != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (category != nil){
        if ([category isEqualToString:@"notifications"])
            return NSLocalizedString(@"Modal.EnableNotifications.Paragraph", nil);
        else if ([category isEqualToString:@"automated_testing"])
            return NSLocalizedString(@"Settings.AutomatedTesting.RunAutomatically.Footer", nil);
      else if ([category isEqualToString:@"test_options"])
            return NSLocalizedString(@"Settings.TestOptions.Footer", nil);
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"bool"]){
        if ([current isEqualToString:@"automated_testing_enabled"]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellSub" forIndexPath:indexPath];
            NSString *run_rimes = NSLocalizedFormatString(@"Settings.AutomatedTesting.RunAutomatically.Number", [NSString stringWithFormat:@"%ld", [SettingsUtility getAutorun]]);
            NSString *last_run_date = NSLocalizedFormatString(@"Settings.AutomatedTesting.RunAutomatically.DateLast", [NSString stringWithFormat:@"%@", [SettingsUtility getAutorunDate]]);
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@\n%@", run_rimes, last_run_date]];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        }
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchview addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventValueChanged];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:current] boolValue]) switchview.on = YES;
        else switchview.on = NO;
        cell.accessoryView = switchview;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"segue"]){
        if ([current isEqualToString:@"website_categories"]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellSub" forIndexPath:indexPath];
            NSString *subtitle = NSLocalizedFormatString(@"Settings.Websites.Categories.Description", [NSString stringWithFormat:@"%ld", [SettingsUtility getNumberCategoriesEnabled]]);
            [cell.detailTextLabel setText:subtitle];
        }
        else
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"int"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:current];
        NSDecimalNumber *someNumber = [NSDecimalNumber decimalNumberWithString:[value stringValue]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        UITextField *textField = [self createTextField:@"int" :[formatter stringFromNumber:someNumber]];
        cell.accessoryView = textField;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"string"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:current];
        UITextField *textField = [self createTextField:@"string" :value];
        cell.accessoryView = textField;
    }
    else if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"button"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellSub" forIndexPath:indexPath];
        cell.textLabel.text = [LocalizationUtility getNameForSetting:current];
        cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];

        if ([current isEqualToString:@"storage_usage"]){
            UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [cleanButton setTitle:NSLocalizedString(@"Settings.Storage.Clear", nil) forState:UIControlStateNormal];
            [cleanButton sizeToFit];
            [cleanButton addTarget:self
                            action:@selector(removeAllTests:) forControlEvents:UIControlEventTouchDown];
            cell.accessoryView = cleanButton;
            NSString *subtitle = [NSByteCountFormatter stringFromByteCount:[TestUtility storageUsed] countStyle:NSByteCountFormatterCountStyleFile];
            [cell.detailTextLabel setText:subtitle];
        }
        if ([current isEqualToString:@"AppleLanguages"]){
            [cell.detailTextLabel setText:(NSString *)[SettingsUtility currentLanguage][0]];

            UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [cleanButton setTitle:NSLocalizedString(@"Settings.Advanced.LanguageSettings.PopUp", nil) forState:UIControlStateNormal];
            [cleanButton sizeToFit];
            [cleanButton addTarget:self
                            action:@selector(selectLanguage:) forControlEvents:UIControlEventTouchDown];
            cell.accessoryView = cleanButton;
        }
    }
    cell.backgroundColor = [UIColor colorNamed:@"color_gray1"];
    return cell;
}


/**
 * This method is used to resize an image to a given size.
 * There is loss of original image color when resizing. Improvement required.
 * @see https://stackoverflow.com/a/4712537
 *
 * @param image
 * @param size
 * @return
 */
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

-(IBAction)removeAllTests:(id)sender{
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Modal.Delete", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                [self deleteAll];
                               }];
    [MessageUtility alertWithTitle:nil
                           message:NSLocalizedString(@"Modal.DoYouWantToDeleteAllTests", nil)
                          okButton:okButton
                            inView:self];
}

-(IBAction)selectLanguage:(id)sender{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Settings.Advanced.LanguageSettings.Title", nil)
                                                                   message:NSLocalizedString(@"Settings.Advanced.LanguageSettings.PopUp", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Modal.Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Languages" ofType:@"plist"];
    // TODO(aanorbel): add translation
    [alert addAction:[UIAlertAction actionWithTitle:@"Automatic" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.view makeToast:@"Please restart the app for apply changes."
                    duration:10
                    position:CSToastPositionBottom];
    }]];
    NSMutableDictionary *languages = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray * languageKeys = [languages keysSortedByValueUsingComparator:
                    ^NSComparisonResult(id obj1, id obj2) {
                        return [obj1 compare:obj2];
                    }];
    for (NSString *languageKey in languageKeys) {
        [alert addAction:[UIAlertAction actionWithTitle:languages[languageKey] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setObject:@[languageKey] forKey:@"AppleLanguages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.view makeToast:@"Please restart the app for apply changes."
                        duration:10
                        position:CSToastPositionBottom];
        }]];
    }

    // Check if the device is an iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height, 1.0, 1.0);
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deleteAll{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [TestUtility cleanUp];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHeader" object:nil];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (UITextField*)createTextField:(NSString*)type :(NSString*)text{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    textField.delegate = self;
    textField.backgroundColor = [UIColor colorNamed:@"color_white"];
    textField.font = [UIFont fontWithName:@"FiraSans-Regular" size:15.0f];
    textField.textColor = [UIColor colorNamed:@"color_gray9"];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.text = text;
    if ([type isEqualToString:@"int"])
        textField.keyboardType = UIKeyboardTypeNumberPad;
    else
        textField.keyboardType = UIKeyboardTypeDefault;
    textField.inputAccessoryView = keyboardToolbar;
    return textField;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = (UITableViewCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([current isEqualToString:@"max_runtime"]){
        if ([textField.text integerValue] < 10){
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            [[NSUserDefaults standardUserDefaults] setObject:[f numberFromString:@"10"] forKey:@"max_runtime"];
            [self.tableView reloadData];
            [self.view makeToast:NSLocalizedString(@"Settings.Error.TestDurationTooLow", nil)];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"int"]){
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        [[NSUserDefaults standardUserDefaults] setObject:[f numberFromString:str] forKey:current];
    }
    else
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:current];
    return YES;
}

-(IBAction)setSwitch:(UISwitch *)mySwitch{
    UITableViewCell *cell = (UITableViewCell *)mySwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([current isEqualToString:@"notifications_enabled"]){
        if (mySwitch.on){
            [ThirdPartyServices initCountlyAnyway];
            [Countly.sharedInstance giveConsentForFeature:CLYConsentPushNotifications];
            [self handleNotificationChanges];
        }
        else
            [ThirdPartyServices reloadConsents];
    }
    else if ([current isEqualToString:@"send_crash"]){
        [ThirdPartyServices reloadConsents];
    }
    else if ([current isEqualToString:@"automated_testing_enabled"]){
        //We schedule the task only on going to background
        if (!mySwitch.on)
            [BackgroundTask cancelCheckIn];
    }
    else if ([current isEqualToString:@"long_running_tests_in_foreground"]){

        [self.view makeToast:@"Please restart the app for apply changes."
                    duration:10
                    position:CSToastPositionBottom];
    }
    else if (!mySwitch.on && ![self canSetSwitch]){
        [mySwitch setOn:TRUE];
        [MessageUtility alertWithTitle:nil
                               message:NSLocalizedString(@"Modal.EnableAtLeastOneTest", nil)
                                inView:self];
        return;
    }

    if (mySwitch.on)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:current];
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:current];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSettings];
}

- (void)handleNotificationChanges{
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusNotDetermined:{
                //Notification permission asking for the first time
                [Countly.sharedInstance
                 askForNotificationPermissionWithOptions:0
                 completionHandler:^(BOOL granted, NSError * error) {
                    if (granted)
                        [self acceptedNotificationSettings];
                    [ThirdPartyServices reloadConsents];
                }];
                break;
            }
            case UNAuthorizationStatusDenied:{
                //Notification permission denied or disabled
                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Modal.Error.NotificationNotEnabled.GoToSettings", nil)
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                           }];
                [MessageUtility alertWithTitle:NSLocalizedString(@"Modal.Error", nil)
                                       message:NSLocalizedString(@"Modal.Error.NotificationNotEnabled", nil)
                                      okButton:okButton
                                        inView:self];
                break;
            }
            case UNAuthorizationStatusAuthorized:{
                //Notification permission already granted
                [self acceptedNotificationSettings];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)acceptedNotificationSettings {
    [SettingsUtility registeredForNotifications];
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self reloadSettings];
    });
}

-(BOOL)canSetSwitch{
    if (testSuite != nil){
        NSArray *items = [SettingsUtility getSettingsForTest:testSuite.name :NO];
        NSUInteger numberOfTests = [items count];
        if ([testSuite.name isEqualToString:@"performance"] || [testSuite.name isEqualToString:@"middle_boxes"] || [testSuite.name isEqualToString:@"instant_messaging"]){
            for (NSString *current in items){
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:current] boolValue])
                    numberOfTests--;
            }
            if (numberOfTests < 2)
                return NO;
            return YES;
        }
        return YES;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *current = [items objectAtIndex:indexPath.row];
    if ([[SettingsUtility getTypeForSetting:current] isEqualToString:@"segue"]){
        [self performSegueWithIdentifier:current sender:self];
    }
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[TestUtility getTestOptionTypes] containsObject:[segue identifier]]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SettingsTableViewController *vc = (SettingsTableViewController * )segue.destinationViewController;
        NSString *current = [items objectAtIndex:indexPath.row];
        [vc setCategory:current];
    }
}

@end
