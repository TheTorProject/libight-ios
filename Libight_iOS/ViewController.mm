//
//  ViewController.m
//  test8
//
//  Created by Simone Basso on 18/01/15.
//  Copyright (c) 2015 Simone Basso. All rights reserved.
//

#import "ViewController.h"

/*Include header from test*/
#include "measurement_kit/ooni.hpp"

#include "measurement_kit/common.hpp"

@implementation ViewController : UIViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    self.availableNetworkMeasurements = [[NSMutableArray alloc] init];
    [self loadAvailableMeasurements];
    self.manager = [[NetworkManager alloc] init];
    self.manager.running = false;
    self.manager.runningNetworkMeasurements = [[NSMutableArray alloc] init];
    self.manager.completedNetworkMeasurements = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"refreshTable" object:nil];
    [self setLabels];
}

- (void) loadAvailableMeasurements {
    DNSInjection *dns_injectionMeasurement = [[DNSInjection alloc] init];
    [self.availableNetworkMeasurements addObject:dns_injectionMeasurement];
    
    TCPConnect *tcp_connectMeasurement = [[TCPConnect alloc] init];
    [self.availableNetworkMeasurements addObject:tcp_connectMeasurement];
    
    HTTPInvalidRequestLine *http_invalid_request_lineMeasurement = [[HTTPInvalidRequestLine alloc] init];
    [self.availableNetworkMeasurements addObject:http_invalid_request_lineMeasurement];
}

-(void)refreshTable{
    NSLog(@"refreshTable notification");
    NSArray *copyArray = [[NSArray alloc] initWithArray:self.manager.runningNetworkMeasurements];
    for (NetworkMeasurement *current in copyArray){
        if (current.finished) {
            [self.manager.runningNetworkMeasurements removeObject:current];
            [self.manager.completedNetworkMeasurements addObject:current];
        }
    }
    [self.tableView reloadData];
}

- (void) setLabels {
    [self.testing_historyLabel setText:NSLocalizedString(@"testing_history", nil)];
    [self.pending_testsLabel setText:NSLocalizedString(@"pending_tests", nil)];
    [self.run_testLabel setText:NSLocalizedString(@"run_test", nil)];
    
    [self.dns_injectionLabel setText:NSLocalizedString(@"dns_injection", nil)];
    [self.tcp_connectLabel setText:NSLocalizedString(@"tcp_connect", nil)];
    [self.http_invalid_request_lineLabel setText:NSLocalizedString(@"http_invalid_request_line", nil)];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) runTests:(id)sender {
    if (self.selectedMeasurement != nil) {
        [self.selectedMeasurement run];
        [self.manager.runningNetworkMeasurements addObject:self.selectedMeasurement];
        [self unselectAll];
        self.selectedMeasurement = nil;
        [self.tableView reloadData];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [self.manager.runningNetworkMeasurements count];
            break;
        case 1:
            return [self.manager.completedNetworkMeasurements count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"running_tests", @"");
            break;
        case 1:
            sectionName = NSLocalizedString(@"finished_tests", @"");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *title = (UILabel*)[cell viewWithTag:1];
    UIProgressView *bar = (UIProgressView*)[cell viewWithTag:2];
    //UIButton *go_log = (UIButton *)[cell viewWithTag:3];
    NetworkMeasurement *current;
    if (indexPath.section == 0)
        current = [self.manager.runningNetworkMeasurements objectAtIndex:indexPath.row];
    else
        current = [self.manager.completedNetworkMeasurements objectAtIndex:indexPath.row];

    [title setText:NSLocalizedString(current.name, nil)];
    
    if (!current.finished) [bar setProgress:0.2 animated:NO];
    else [bar setProgress:1.0 animated:NO];
    return cell;
}

- (void) unselectAll {
    [self.dns_injectionButton setImage:[UIImage imageNamed:@"not-selected"] forState:UIControlStateNormal];
    [self.tcp_connectButton setImage:[UIImage imageNamed:@"not-selected"] forState:UIControlStateNormal];
    [self.http_invalid_request_lineButton setImage:[UIImage imageNamed:@"not-selected"] forState:UIControlStateNormal];
}

//TODO one function click - example
- (IBAction)buttonClick:(id)sender forEvent:(UIEvent *)event {
    UIButton *tappedButton = (UIButton*)sender;
    [self unselectAll];
    [tappedButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    if (tappedButton == self.dns_injectionButton){
        DNSInjection *dns_injectionMeasurement = [[DNSInjection alloc] init];
        self.selectedMeasurement = dns_injectionMeasurement;
    }
    else if (tappedButton == self.tcp_connectButton) {
        TCPConnect *tcp_connectMeasurement = [[TCPConnect alloc] init];
        self.selectedMeasurement = tcp_connectMeasurement;
    }
    else if (tappedButton == self.http_invalid_request_lineButton){
        HTTPInvalidRequestLine *http_invalid_request_lineMeasurement = [[HTTPInvalidRequestLine alloc] init];
        self.selectedMeasurement = http_invalid_request_lineMeasurement;
    }
    self.selectedMeasurement.manager = self.manager;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toLog"]){
        UINavigationController *navigationController = segue.destinationViewController;
        LogViewController *vc = (LogViewController * )navigationController.topViewController;
        UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:clickedCell];
        NetworkMeasurement *current;
        if (indexPath.section == 0)
            current = [self.manager.runningNetworkMeasurements objectAtIndex:indexPath.row];
        else
            current = [self.manager.completedNetworkMeasurements objectAtIndex:indexPath.row];
        [vc setTest:current];
    }
    else if ([[segue identifier] isEqualToString:@"toInfo"]){
        UINavigationController *navigationController = segue.destinationViewController;
        TestInfoViewController *vc = (TestInfoViewController * )navigationController.topViewController;
        UIButton *tappedButton = (UIButton*)sender;
        if (tappedButton.tag == 1){
            [vc setFileName:@"ts-012-dns-injection"];
        }
        else if (tappedButton.tag == 2){
            [vc setFileName:@"ts-008-tcpconnect"];
        }
        else if (tappedButton.tag == 3){
            [vc setFileName:@"ts-007-http-invalid-request-line"];
        }
    }
}

@end
