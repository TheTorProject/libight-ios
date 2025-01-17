#import "SettingsUtility.h"
#import "TestUtility.h"
#import "Engine.h"
#import "ThirdPartyServices.h"

@implementation SettingsUtility

+ (NSArray*)getSettingsCategories{
    return @[@"notifications", @"test_options", @"privacy", @"advanced", @"ooni_backend_proxy", @"send_email", @"about_ooni"];
}

+ (NSArray*)getSettingsForCategory:(NSString*)categoryName{
    //TODO NEWS reenable @"notifications_news"
    if ([categoryName isEqualToString:@"notifications"]) {
        return @[@"notifications_enabled"];
    }
    if ([categoryName isEqualToString:@"automated_testing"]) {
        if ([SettingsUtility isAutomatedTestEnabled]) {
            return @[@"automated_testing_enabled", @"automated_testing_wifionly", @"automated_testing_charging"];
        } else {
            return @[@"automated_testing_enabled"];
        }
    }
    else if ([categoryName isEqualToString:@"privacy"]) {
        return @[@"upload_results", @"send_crash"];
    }
    else if ([categoryName isEqualToString:@"advanced"]) {
        //TODO DOMAIN FRONTING @"use_domain_fronting"
        return @[@"AppleLanguages", @"debug_logs", @"storage_usage" , @"warn_vpn_in_use"];
    }
    else if ([categoryName isEqualToString:@"test_options"]) {
        return @[@"automated_testing_enabled", @"automated_testing_wifionly", @"automated_testing_charging", @"website_categories", @"max_runtime_enabled", @"max_runtime"];
    } else {
        return nil;
    }
}

+ (NSString*)getTypeForSetting:(NSString*)setting{
    if ([setting isEqualToString:@"experimental"] || [setting isEqualToString:@"long_running_tests_in_foreground"]) {
        return @"bool";
    } else if ([setting isEqualToString:@"website_categories"]) {
        return @"segue";
    } else if ([setting isEqualToString:@"monthly_mobile_allowance"] ||
        [setting isEqualToString:@"monthly_wifi_allowance"] ||
        [setting isEqualToString:@"max_runtime"]) {
        return @"int";
    }
    if ([setting isEqualToString:@"storage_usage"] || [setting isEqualToString:@"AppleLanguages"]) {
        return @"button";
    }
    return @"bool";
}

+ (NSArray*)getAutomaticTestsEnabled{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"automatic_tests"];
}

+ (NSString*)getVerbosity {
    if ([self getSettingWithName:@"debug_logs"])
        return @"DEBUG2";
    return @"INFO";
}

+ (NSArray*)addRemoveAutomaticTest:(NSString*)testName{
    NSMutableArray *automaticTests = [[self getAutomaticTestsEnabled] mutableCopy];
    if ([automaticTests containsObject:testName])
        [automaticTests removeObject:testName];
    else
        [automaticTests addObject:testName];
    [[NSUserDefaults standardUserDefaults] setObject:automaticTests forKey:@"automatic_tests"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return automaticTests;
}

+ (NSArray*)getSitesCategories{
    return @[@"ANON",
             @"COMT",
             @"CTRL",
             @"CULTR",
             @"ALDR",
             @"COMM",
             @"ECON",
             @"ENV",
             @"FILE",
             @"GMB",
             @"GAME",
             @"GOVT",
             @"HACK",
             @"HATE",
             @"HOST",
             @"HUMR",
             @"IGO",
             @"LGBT",
             @"MMED",
             @"NEWS",
             @"DATE",
             @"POLR",
             @"PORN",
             @"PROV",
             @"PUBH",
             @"REL",
             @"SRCH",
             @"XED",
             @"GRP",
             @"MILX"];
}

+ (NSArray*)getSitesCategoriesDisabled {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"categories_disabled"];
}

+ (NSArray*)getSitesCategoriesEnabled {
    NSMutableArray *categories = [[self getSitesCategories] mutableCopy];
    [categories removeObjectsInArray:[self getSitesCategoriesDisabled]];
    return categories;
}

+ (long)getNumberCategoriesEnabled{
    return [[self getSitesCategories] count] - [[self getSitesCategoriesDisabled] count];
}

+ (NSArray*)addRemoveSitesCategory:(NSString*)categoryName {
    NSMutableArray *categories_disabled = [[self getSitesCategoriesDisabled] mutableCopy];
    if ([categories_disabled containsObject:categoryName])
        [categories_disabled removeObject:categoryName];
    else
        [categories_disabled addObject:categoryName];
    [[NSUserDefaults standardUserDefaults] setObject:categories_disabled forKey:@"categories_disabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return categories_disabled;
}

+ (void) updateAllWebsiteCategories:(BOOL) enableAll {
    if (enableAll)
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"categories_disabled"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:[self getSitesCategories] forKey:@"categories_disabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray*)getSettingsForTest:(NSString*)testName :(BOOL)includeAll{
    NSMutableArray *settings = [[NSMutableArray alloc] init];
    if ([testName isEqualToString:@"websites"]) {
        if (includeAll) [settings addObject:@"website_categories"];
        if (includeAll) [settings addObject:@"max_runtime_enabled"];
        if (includeAll && [self getSettingWithName:@"max_runtime_enabled"])
            [settings addObject:@"max_runtime"];
    }
    else if ([testName isEqualToString:@"instant_messaging"]) {
        [settings addObject:@"test_whatsapp"];
        [settings addObject:@"test_telegram"];
        [settings addObject:@"test_facebook_messenger"];
        [settings addObject:@"test_signal"];
    }
    else if ([testName isEqualToString:@"circumvention"]) {
        [settings addObject:@"test_psiphon"];
        [settings addObject:@"test_tor"];
        /*[settings addObject:@"test_riseupvpn"];*/
    }
    else if ([testName isEqualToString:@"performance"]) {
        [settings addObject:@"run_ndt"];
        [settings addObject:@"run_dash"];
        [settings addObject:@"run_http_invalid_request_line"];
        [settings addObject:@"run_http_header_field_manipulation"];
    }
    else if ([testName isEqualToString:@"experimental_x"]) {
        [settings addObject:@"experimental"];
    }
    return settings;
}

+ (BOOL)getSettingWithName:(NSString*)settingName{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:settingName] boolValue];
}

+ (BOOL)isSendCrashEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"send_crash"] boolValue];
}

+ (BOOL)isWarnVPNInUse {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"warn_vpn_in_use"] boolValue];
}

+ (void)disableWarnVPNInUse {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"warn_vpn_in_use"];
}

+ (BOOL)isNotificationEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications_enabled"] boolValue];
}

+ (BOOL)isExperimentalTestEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"experimental"] boolValue];
}
+ (BOOL)isLongRunningTestsInForegroundEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"long_running_tests_in_foreground"] boolValue];
}

+ (BOOL)isAutomatedTestEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"automated_testing_enabled"] boolValue];
}

+ (NSString*)getOrGenerateUUID4{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"uuid4"] ||
        ![[[NSUserDefaults standardUserDefaults] objectForKey:@"uuid4"] isKindOfClass:[NSString class]]){
        NSString *uuid = [Engine newUUID4];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid4"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return uuid;
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid4"];
}

+ (void)incrementAppOpenCount{
    [[NSUserDefaults standardUserDefaults] setInteger:[self getAppOpenCount]+1 forKey:APP_OPEN_COUNT];
}

+ (NSInteger)getAppOpenCount{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:APP_OPEN_COUNT];
    if(count < 0) count = 0;
    return count;
}

+ (void)registeredForNotifications {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications_enabled"];
    [ThirdPartyServices reloadConsents];
}

+ (void)enableAutorun {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"automated_testing_enabled"];
}

+ (BOOL)testWifiOnly {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"automated_testing_wifionly"] boolValue];
}

+ (BOOL)testChargingOnly {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"automated_testing_charging"] boolValue];
}

+ (NSArray *)currentLanguage {
    return (NSArray *)[NSUserDefaults.standardUserDefaults objectForKey:@"AppleLanguages"];
}

+ (NSInteger)getAutorun{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"autorun_count"];
    if(count < 0) count = 0;
    return count;
}

+ (void)incrementAutorun{
    [[NSUserDefaults standardUserDefaults] setInteger:[self getAutorun]+1 forKey:@"autorun_count"];
}

+ (NSString*)getAutorunDate{
    NSDate *lastDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"autorun_last_date"];
    if (lastDate == nil)
        return NSLocalizedString(@"TestResults.NotAvailable", nil);
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    return [dateformatter stringFromDate:lastDate];
}

+ (void)updateAutorunDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"autorun_last_date"];
}

@end
