//
//  WOCBuyDashStep8ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 24/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep8ViewController.h"
#import "WOCBuyingInstructionsViewController.h"
#import "APIManager.h"
#import "WOCConstants.h"

@interface WOCBuyDashStep8ViewController ()

@property (strong, nonatomic) NSString *holdId;

@end

@implementation WOCBuyDashStep8ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setShadow:self.btnPurchaseCode];
    [self createHold];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)confirmPurchaseCodeClicked:(id)sender {
    
    NSString *txtCode = [self.txtPurchaseCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([txtCode length] > 0) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyingInstructionsViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyingInstructionsViewController"];
        myViewController.purchaseCode = self.txtPurchaseCode.text;
        myViewController.holdId = self.holdId;
        myViewController.phoneNo = self.phoneNo;
        [self.navigationController pushViewController:myViewController animated:YES];
    }
    else{
        NSLog(@"Alert: %@", @"Enter Purchase Code");
    }
}

#pragma mark - Function
- (void)setShadow:(UIView *)view{
    
    //if widthOffset = 1 and heightOffset = 1 then shadow will set to two sides
    //if widthOffset = 0 and heightOffset = 0 then shadow will set to four sides
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);//CGSize(width: widthOffset, height: heightOffset)//0,1
    view.layer.shadowRadius = 1; //1
    view.layer.shadowOpacity = 1;//1
    view.layer.masksToBounds = false;
}

#pragma mark - API
- (void)createHold {
    
    NSDictionary *params =
    @{
      @"publisherId": @WALLOFCOINS_PUBLISHER_ID,
      @"offer": [NSString stringWithFormat:@"%@==",self.offerId],
      @"phone": self.phoneNo,
      @"deviceName": @"Ref Client",
      @"deviceCode": self.deviceCode,
      @"JSONPara":@"YES"
      };
    
    [[APIManager sharedInstance] createHold:params response:^(id responseDict, NSError *error) {
        
        if (error == nil) {
            
            NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:(NSDictionary*)responseDict];
            
            self.txtPurchaseCode.text = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"__PURCHASE_CODE"]];
            self.holdId = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"id"]];
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"token"]] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
@end
