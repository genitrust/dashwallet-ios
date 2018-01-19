//
//  WOCSettingsDetailViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCSettingsDetailViewController : UIViewController

@property (nonatomic) int index;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backBtnClicked:(id)sender;

@end
