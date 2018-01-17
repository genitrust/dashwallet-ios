//
//  WOCAddressBookViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCOpeningScreenViewController.h"
#import "WOCCollapsedCell.h"
#import "WOCExpandedCell.h"
#import "WOCBuyDashViewController.h"
#import "WOCSendDashViewController.h"

@interface WOCOpeningScreenViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation WOCOpeningScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setHidden:YES];
    
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:self.btnSafetyNotes.titleLabel.text];
    // making text property to underline text-
    [titleString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(31, 12)];
    // using text on button
    [self.btnSafetyNotes setAttributedTitle: titleString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)backBtnClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)requestCoinClicked:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WOCBuyDashViewController *buyDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCBuyDashViewController"];
    [self.navigationController pushViewController:buyDash animated:YES];
}

- (IBAction)sendCoinClicked:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WOCSendDashViewController *buyDash = [storyBoard instantiateViewControllerWithIdentifier:@"WOCSendDashViewController"];
    [self.navigationController pushViewController:buyDash animated:YES];
}

- (IBAction)safetyNotesClicked:(id)sender {
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath != self.selectedIndexPath) {
        
        WOCCollapsedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collapsedCell"];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
        UIColor *color = [UIColor colorWithRed:92.0/255.0 green:184.0/255.0 blue:92.0/255.0 alpha:1.0];
        UIColor *color1 = [UIColor colorWithRed:152.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];
        
        NSDictionary *attrsDictionary = @{
                                          NSFontAttributeName : font,
                                          NSForegroundColorAttributeName : color
                                          };
        
        NSDictionary *attrsDictionary1 = @{
                                           NSFontAttributeName : font1,
                                           NSForegroundColorAttributeName : color
                                           };
        
        NSDictionary *attrsDictionary2 = @{
                                          NSFontAttributeName : font,
                                          NSForegroundColorAttributeName : color1
                                          };
        
        NSDictionary *attrsDictionary3 = @{
                                           NSFontAttributeName : font1,
                                           NSForegroundColorAttributeName : color1
                                           };
        
        if (indexPath.row % 2) {
            cell.imgCircle.image = [UIImage imageNamed:@"green_opening_icon"];
            
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"+ 0.22" attributes:attrsDictionary];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"99" attributes:attrsDictionary1];
            [mutableString appendAttributedString:attrString];
            
            cell.lblPoints.attributedText = mutableString;
        }
        else{
            cell.imgCircle.image = [UIImage imageNamed:@"red_opening_icon"];
            
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"- 0.22" attributes:attrsDictionary2];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"99" attributes:attrsDictionary3];
            [mutableString appendAttributedString:attrString];
            
            cell.lblPoints.attributedText = mutableString;
        }
        
        return cell;
    }
    else{
        
        WOCExpandedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expandedCell"];
        cell.imgCircle.image = [UIImage imageNamed:@"red_opening_icon"];
        
        
        
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedIndexPath = indexPath;
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath == self.selectedIndexPath) {
        return 105.0;
    }
    return 45.0;
}

@end

