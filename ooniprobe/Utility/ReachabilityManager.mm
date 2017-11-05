#import "ReachabilityManager.h"

@implementation ReachabilityManager

+ (ReachabilityManager *)sharedManager {
    static ReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        //self.reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        self.reachability = [Reachability reachabilityForInternetConnection];

        // Start Monitoring
        [self.reachability startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
        
    }
    
    return self;
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    NSString *network_type = [self getStatus];
    if (![network_type isEqualToString:@"no_internet"]){
        [[NotificationService sharedNotificationService] setNetwork_type:network_type];
        [[NotificationService sharedNotificationService] updateProbe];
    }
}

- (NSString*)getStatus{
    NetworkStatus status = [self.reachability currentReachabilityStatus];
    NSString *network_type;
    if (status == ReachableViaWiFi)
        network_type = @"wifi";
    else if (status == ReachableViaWWAN)
        network_type = @"mobile";
    else if(status == NotReachable)
        network_type = @"no_internet";
    return network_type;
}

@end
