//
//  WOCSettingsViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCSettingsViewController.h"
#import "WOCSettingsDetailViewController.h"

@interface WOCSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *settings;

@end

@implementation WOCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.settings = @[@"Settings",
                      @"Diognostics",
                      @"About"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.settings.count;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.settings[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WOCSettingsDetailViewController *settingsDetail = [storyboard instantiateViewControllerWithIdentifier:@"WOCSettingsDetailViewController"];
    settingsDetail.index = indexPath.row;
    [self.navigationController pushViewController:settingsDetail animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
