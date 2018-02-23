//
//  WOCBuyDashStep1ViewController.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 23/01/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "WOCBuyDashStep1ViewController.h"
#import "WOCLocationManager.h"
#import "WOCBuyDashStep2ViewController.h"
#import "WOCBuyDashStep3ViewController.h"
#import "WOCBuyDashStep4ViewController.h"
#import "WOCConstants.h"
#import "BRAppDelegate.h"
#import "BRRootViewController.h"
#import "MBProgressHUD.h"
#import "APIManager.h"
#import "WOCAlertController.h"

@interface WOCBuyDashStep1ViewController ()

@property (strong, nonatomic) NSString *zipCode;

@end

@implementation WOCBuyDashStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Buy Dash With Cash";
    
    if (self.isFromSend) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findZipCode) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_4 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openBuyDashStep2) name:NOTIFICATION_OBSERVER_NAME_BUY_DASH_STEP_2 object:nil];
    
    self.btnLocation.layer.cornerRadius = 3.0;
    self.btnLocation.layer.masksToBounds = YES;
    self.btnNoThanks.layer.cornerRadius = 3.0;
    self.btnNoThanks.layer.masksToBounds = YES;
    [self setShadow:self.btnLocation];
    [self setShadow:self.btnNoThanks];
    
    //store deviceCode in userDefault
    int launched = [[NSUserDefaults standardUserDefaults] integerForKey:USER_DEFAULTS_LAUNCH_STATUS];
    if (launched == 0) {
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:USER_DEFAULTS_LOCAL_DEVICE_CODE];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:USER_DEFAULTS_LAUNCH_STATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];

    if (token != nil && [token isEqualToString:@"(null)"] == FALSE) {
     
        [self.signoutView setHidden:NO];
        
        NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
        NSString *loginPhone = [NSString stringWithFormat:@"Your wallet is signed into Wall of Coins using your mobile number %@",phoneNo];
        self.lblDescription.text = loginPhone;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.btnLocation setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openBuyDashStep4 {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep4ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep4ViewController"];
    myViewController.zipCode = self.zipCode;
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (void)openBuyDashStep2 {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
    WOCBuyDashStep2ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep2ViewController"];
    [self.navigationController pushViewController:myViewController animated:YES];
}

- (void)back:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BRRootViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        
        UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
        UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
        
        BRAppDelegate *appDelegate = (BRAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = nav;
    });
}

- (void)setShadow:(UIView *)view {
    
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 1;
    view.layer.masksToBounds = false;
}

- (void)showAlert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dash" message:@"Are you in the USA?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openBuyDashStep2];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"buyDash" bundle:nil];
        WOCBuyDashStep3ViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:@"WOCBuyDashStep3ViewController"];
        [self.navigationController pushViewController:myViewController animated:YES];
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)findZipCode {
    
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    [self.btnLocation setUserInteractionEnabled:YES];
    
    // Your location from latitude and longitude
    NSString *latitude = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LATITUDE];
    NSString *longitude = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_LOCATION_LONGITUDE];
    
    if (latitude != nil && longitude != nil) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        // Call the method to find the address
        [self getAddressFromLocation:location completionHandler:^(NSMutableDictionary *d) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            NSLog(@"address informations : %@", d);
            NSLog(@"ZIP code : %@", [d valueForKey:@"ZIP"]);
            
            self.zipCode = [d valueForKey:@"ZIP"];
            [self openBuyDashStep4];
            
        } failureHandler:^(NSError *error) {
            NSLog(@"Error : %@", error);
        }];
    }
    else {
        [[WOCLocationManager sharedInstance] startLocationService];
    }
}

- (void)getAddressFromLocation:(CLLocation *)location completionHandler:(void (^)(NSMutableDictionary *placemark))completionHandler failureHandler:(void (^)(NSError *error))failureHandler {
    
    NSMutableDictionary *d = [NSMutableDictionary new];
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (failureHandler && (error || placemarks.count == 0)) {
            failureHandler(error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(completionHandler) {
                completionHandler(placemark.addressDictionary);
            }
        }
    }];
}

// MARK: - API

- (void)signOut:(NSString*)phone
{
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.topViewController.view animated:YES];
    
    NSDictionary *params = @{
                             //API_BODY_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [[APIManager sharedInstance] signOut:params phone:phone response:^(id responseDict, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        
        if (error == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signoutView setHidden:YES];
            });
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_AUTH_TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_LOCAL_DEVICE_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [[WOCAlertController sharedInstance] alertshowWithError:error viewController:self.navigationController.visibleViewController];
        }
    }];
}

// MARK: - IBAction

- (IBAction)backBtnClicked:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.navigationBar setHidden:NO];
    });
}

- (IBAction)findLocationClicked:(id)sender {
    
    if ([[WOCLocationManager sharedInstance] locationServiceEnabled])
    {
        [self findZipCode];
        [self.btnLocation setUserInteractionEnabled:NO];
    }
    else {
        // Enable Location services
        [[WOCLocationManager sharedInstance] startLocationService];
        [self.btnLocation setUserInteractionEnabled:NO];
    }
}

- (IBAction)noThanksClicked:(id)sender {
    
    [self showAlert];
}

- (IBAction)signOutClicked:(id)sender {
    
    NSString *phoneNo = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_LOCAL_PHONE_NUMBER];
    
    [self signOut:phoneNo];
}

@end

