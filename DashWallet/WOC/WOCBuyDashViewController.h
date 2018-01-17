//
//  WOCBuyDashViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCBuyDashViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *txtField1;
@property (weak, nonatomic) IBOutlet UITextField *txtField2;
- (IBAction)backBtnClicked:(id)sender;

@end
