#import "AppDelegate.h"
#import "Tests.h"
#import "NotificationService.h"
#import "BrowserViewController.h"
#import "DictionaryUtility.h"
#import "RunTestViewController.h"

#define ALERT_TAG_NOTIFICATION 1
#define ALERT_TAG_OPEN_ITUNES 2

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultPreferences" ofType:@"plist"]]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: color_off_white, NSForegroundColorAttributeName, [UIFont fontWithName:@"FiraSansOT-Bold" size:18], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"FiraSansOT-Bold" size:15],NSFontAttributeName, nil] forState:UIControlStateNormal];
    CrashlyticsKit.delegate = self;
    [Fabric with:@[[Crashlytics class]]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self registerNotifications];
    
    //TODO Probably don't need it anymore when implementing backgound notifications
    //https://stackoverflow.com/questions/30297594/uiapplicationlaunchoptionsremotenotificationkey-not-getting-userinfo
    //https://stackoverflow.com/questions/38969229/what-is-uiapplicationlaunchoptionsremotenotificationkey-used-for
    NSMutableDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notification) {
        [self handleNotification:notification :application];
    }
    
    return YES;
}

- (void)registerNotifications{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"token: %@",token);
    [[NotificationService sharedNotificationService] setDevice_token:token];
    [[NotificationService sharedNotificationService] registerNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo) {
        if ([userInfo objectForKey:@"aps"]){
            if([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badge"] intValue];
                });
            }
        }
        [self handleNotification:userInfo :application];
    }
}

-(void)handleNotification:(NSDictionary*)userInfo :(UIApplication *)application{
    NSString *type = [userInfo objectForKey:@"type"];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        if ([type isEqualToString:@"open_href"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            //self.link = [userInfo objectForKey:@"link"];
            links = [[NSMutableArray alloc] init];
            [links addObject:[[userInfo objectForKey:@"payload"] objectForKey:@"href"]];
            if ([[userInfo objectForKey:@"payload"] objectForKey:@"alt_hrefs"]){
                NSArray *alt_href = [[userInfo objectForKey:@"payload"] objectForKey:@"alt_hrefs"];
                [links addObjectsFromArray:alt_href];
            }
            alertView.tag = ALERT_TAG_NOTIFICATION;
            [alertView show];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alertView show];
        }
    }
    else {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        if ([type isEqualToString:@"open_href"]){
            links = [[NSMutableArray alloc] init];
            [links addObject:[[userInfo objectForKey:@"payload"] objectForKey:@"href"]];
            if ([[userInfo objectForKey:@"payload"] objectForKey:@"alt_hrefs"]){
                NSArray *alt_href = [[userInfo objectForKey:@"payload"] objectForKey:@"alt_hrefs"];
                [links addObjectsFromArray:alt_href];
            }
            [self openBrowser];
        }
    }
}

-(void)openBrowser{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *nvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"browserNC"];
        BrowserViewController *bvc = (BrowserViewController*)[nvc.viewControllers objectAtIndex:0];
        [bvc setUrlList:links];
        [self.window.rootViewController presentViewController:nvc animated:YES completion:nil];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == ALERT_TAG_NOTIFICATION){
        [self openBrowser];
    }
    else if (buttonIndex == 1 && alertView.tag == ALERT_TAG_OPEN_ITUNES){
        //open ooniprobe on iTunes connect
        NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id1199566366?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //TODO start your long running bg task here
}

//Handles ooni:// links
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [self handleUrlScheme:url];
    return YES;
}

//Handles http(s) links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity  restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [self handleUrlScheme:userActivity.webpageURL];
    }
    return YES;
}

-(void)handleUrlScheme:(NSURL*)url{
    NSDictionary *dict = [DictionaryUtility parseQueryString:[url query]];
    NSDictionary *parameters = [DictionaryUtility getParametersFromDict:dict];
    /*
     //Logging
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    NSLog(@"dict: %@", dict);
    NSLog(@"parameters: %@", parameters);
     */
    //creating parameters dict

    NSString *minimum_version = [parameters objectForKey:@"mv"];
    if (minimum_version != nil){
        if ([minimum_version compare:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] options:NSNumericSearch] == NSOrderedDescending) {
            //actualVersion is lower than the requiredVersion
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ooniprobe_outdate", nil) message:NSLocalizedString(@"ooniprobe_outdate_msg", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            alertView.tag = ALERT_TAG_OPEN_ITUNES;
            [alertView show];
        }
        else {
            NSString *action;
            if ([[url host] isEqualToString:@"run.ooni.io"])
                action = [[url path] substringFromIndex:1];
            else
                action = [url host];
            if ([action isEqualToString:@"nettest"]){
                //For now checking only test name
                if ([parameters objectForKey:@"tn"] && [[Tests currentTests] getTestWithName:[parameters objectForKey:@"tn"]])
                    [self openURIschemeScreen:parameters];
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_parameter", nil) message:[NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"test_name", nil), [parameters objectForKey:@"tn"]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }
    }
}

-(void)openURIschemeScreen:(NSDictionary*)parameters{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *nvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"runtestNC"];
        RunTestViewController *rvc = (RunTestViewController*)[nvc.viewControllers objectAtIndex:0];
        [rvc setTestName:[parameters objectForKey:@"tn"]];
        if ([parameters objectForKey:@"ta"])
            [rvc setTestArguments:[parameters objectForKey:@"ta"]];
        if ([parameters objectForKey:@"td"])
            [rvc setTestDescription:[parameters objectForKey:@"td"]];
        if (self.window.rootViewController.view.window != nil)
            //only main view controller is visible
            [self.window.rootViewController presentViewController:nvc animated:YES completion:nil];
        else {
            //main view controller is not in the window hierarchy, so overlay window was presented already, reloading parameters
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTest" object:nil userInfo:parameters];
        }
    });
}

- (void)crashlyticsDidDetectReportForLastExecution:(CLSReport *)report completionHandler:(void (^)(BOOL))completionHandler {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler([[[NSUserDefaults standardUserDefaults] objectForKey:@"send_crash"] boolValue]);
    }];
}

#pragma mark - PBRevealViewController Delegate
    
- (BOOL)revealControllerPanGestureShouldBegin:(PBRevealViewController *)revealController direction:(PBRevealControllerPanDirection)direction
    {
        if ([[[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode] isEqualToString:@"ar"]){
            if (direction == PBRevealControllerPanDirectionLeft){
                if ([revealController isRightViewOpen])
                    return NO;
                else
                    return YES;
            }
            else {
                if ([revealController isRightViewOpen])
                    return YES;
                else
                    return NO;
            }
        }
        if (direction == PBRevealControllerPanDirectionLeft) {
            if (direction == PBRevealControllerPanDirectionLeft){
                if ([revealController isLeftViewOpen])
                    return YES;
                else
                    return NO;
            }
            else {
                if ([revealController isLeftViewOpen])
                    return NO;
                else
                    return YES;
            }

        }
        return YES;
    }
    
@end
