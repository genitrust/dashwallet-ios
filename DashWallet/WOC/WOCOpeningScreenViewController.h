//
//  WOCOpeningScreenViewController.h
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WOCOpeningScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSafetyNotes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)requestCoinClicked:(id)sender;
- (IBAction)sendCoinClicked:(id)sender;
- (IBAction)safetyNotesClicked:(id)sender;

@end

