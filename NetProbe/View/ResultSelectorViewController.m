//
//  ResultSelectorViewController.m
//  NetProbe
//
//  Created by Lorenzo Primiterra on 28/09/16.
//  Copyright © 2016 Simone Basso. All rights reserved.
//

#import "ResultSelectorViewController.h"

@interface ResultSelectorViewController ()

@end

@implementation ResultSelectorViewController;
@synthesize items;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *content = [items objectAtIndex:indexPath.row];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"input %@", [json objectForKey:@"input"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        NSDictionary *noteInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:indexPath.row] forKey:@"input_id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"inputSelected" object:nil userInfo:noteInfo];
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
