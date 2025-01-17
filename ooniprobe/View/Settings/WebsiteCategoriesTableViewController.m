#import "WebsiteCategoriesTableViewController.h"

@interface WebsiteCategoriesTableViewController ()

@end

@implementation WebsiteCategoriesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings.Websites.Categories.Label", nil);
    self.navigationController.navigationBar.topItem.title = @"";
    self.tableView.estimatedRowHeight = 60.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // remove separator
    self.tableView.backgroundColor = [UIColor colorNamed:@"color_gray1"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    categories = [SettingsUtility getSitesCategories];
    categories_disabled = [SettingsUtility getSitesCategoriesDisabled];
    [self.tableView reloadData];
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
    NSString *categoryTitle = [NSString stringWithFormat:@"CategoryCode.%@.Name", current];
    cell.textLabel.text = NSLocalizedString(categoryTitle, nil);
    cell.textLabel.textColor = [UIColor colorNamed:@"color_gray9"];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"category_%@", current]];
    cell.detailTextLabel.textColor = [UIColor colorNamed:@"color_gray5"];
    NSString *categoryDescription = [NSString stringWithFormat:@"CategoryCode.%@.Description", current];
    cell.detailTextLabel.text = NSLocalizedString(categoryDescription, nil);
    
    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
    [switchview addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventValueChanged];
    if ([categories_disabled containsObject:current]) switchview.on = NO;
    else switchview.on = YES;
    cell.accessoryView = switchview;

    cell.backgroundColor = [UIColor colorNamed:@"color_gray1"];

    return cell;
}

-(IBAction)setSwitch:(UISwitch *)mySwitch{
    UITableViewCell *cell = (UITableViewCell *)mySwitch.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *current = [categories objectAtIndex:indexPath.row];
    categories_disabled = [SettingsUtility addRemoveSitesCategory:current];
}
- (IBAction)showListActions:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Options"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Modal.Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings.Websites.Categories.Selection.All", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [SettingsUtility updateAllWebsiteCategories:true];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings.Websites.Categories.Selection.None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [SettingsUtility updateAllWebsiteCategories:false];
        [self.navigationController popViewControllerAnimated:YES];
    }]];

    // Check if the device is an iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }

    [self presentViewController:alert animated:YES completion:nil];
}

@end
