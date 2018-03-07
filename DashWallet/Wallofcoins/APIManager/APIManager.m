//
//  APIManager.m
//  Wallofcoins
//
//  Created by Sujal Bandhara on 01/12/18.
//  Copyright (c) 2018 Wallofcoins. All rights reserved.
//

#import "APIManager.h"
#import <Foundation/Foundation.h>

#define API_ERROR_TITLE @"Wallofcoins"
#define BASE_URL (IS_PRODUCTION)?BASE_URL_PRODUCTION:BASE_URL_DEVELOPMENT
#define TIMEOUT_INTERVAL 30.0
#define JSONParameter @"JSONPara"

@interface APIManager()

@end

@implementation APIManager

- (id)init
{
    self = [super init];
    if (self) {
        [self initAPIManager];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (void)initAPIManager
{
    APILog(@"Init APIManager");
}

#pragma mark - Wallofcoins API calls

- (void)testAPI
{
    APILog(@"Test API Called");
    [self getAvailablePaymentCenters:^(id responseDict, NSError *error) {
        
        APILog(@"getAvailablePaymentCenters Called");
        
        if ([responseDict isKindOfClass:[NSArray class]])
        {
            NSArray *responseArray = (NSArray*)responseDict;
            
            if (responseArray.count > 0)
            {
                NSDictionary *responseDictionary = responseArray[0];
                APILog(@"First responseDictionary %@",responseDictionary);
                
                APILog(@"1First logo %@",Str(responseDictionary[@"logo"]));
                if (responseDictionary[@"logo"] != [NSNull null])
                {
                    APILog(@"First logo %@",responseDictionary[@"logo"]);
                }
            }
        }
    }];
}

////////////////////////////////////////////////////////////////////
/*
 Name: GET AVAILABLE PAYMENT CENTERS (OPTIONAL)
 Detail : API for get payment center list using GET method...
 API Funcation Name: getAvailablePaymentCenters
 Url: https://woc.reference.genitrust.com/api/v1/banks/
 Method: GET
 
 Success Output:
 [
 {
 "id": 14,
 "name": "Genitrust",
 "url": "https://genitrust.com/",
 "logo": null,
 "logoHq": null,
 "icon": null,
 "iconHq": null,
 "country": "us",
 "payFields": false
 },
 ...
 ]
 */
////////////////////////////////////////////////////////////////////

- (void)getAvailablePaymentCenters:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *version = @"v1";
    NSString *constant = @"/banks/";
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/%@%@",BASE_URL,version,constant];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE: @"application/json"
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: nil  header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*
 #### SEARCH & DISCOVERY
 
 An API for discover available option, which will return Discovery ID along with list of information.
 
 ```http
 POST https://woc.reference.genitrust.com/api/v1/discoveryInputs/
 ```
 
 ##### Request :
 
 ```json
 {
 "publisherId": "",
 "cryptoAddress": "",
 "usdAmount": "500",
 "crypto": "DASH",
 "bank": "",
 "zipCode": "34236"
 }
 ```
 
 >   Publisher Id: an Unique ID generated for commit transections.
 >   cryptoAddress: Cryptographic Address for user, it's optional parameter.
 >   usdAmount: Amount in USD (Need to apply conversation from DASH to USD)
 >   crypto: crypto type either DASH or BTC for bitcoin.
 >   bank: Selected bank ID from bank list. pass empty if selected none.
 >   zipCode: zip code of user, need to take input from user.
 
 ##### Response :
 
 ```json
 {
 "id": "935c882fe79e39e1acd98a801d8ce420",
 "usdAmount": "500",
 "cryptoAmount": "0",
 "crypto": "DASH",
 "fiat": "USD",
 "zipCode": "34236",
 "bank": 5,
 "state": null,
 "cryptoAddress": "",
 "createdIp": "182.76.224.130",
 "location": {
 "latitude": 27.3331293,
 "longitude": -82.5456374
 },
 "browserLocation": null,
 "publisher": null
 }
 ```
 */
- (void)discoverInfo:(NSDictionary*)params response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/discoveryInputs/",BASE_URL];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE: @"application/json"
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### GET OFFERS
 
 An API for fetch all offers for received Discovery ID.
 
 ```http
 GET https://woc.reference.genitrust.com/api/v1/discoveryInputs/<Discovery ID>/offers/
 ```*/

- (void)discoveryInputs:(NSString*)dicoverId response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/discoveryInputs/%@/offers/",BASE_URL,dicoverId];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE: @"application/json"
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: nil header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CREATE HOLD
 
 From offer list on offer click we have to create an hold on offer for generate initial request.
 
 ```http
 HEADER X-Coins-Api-Token:
 
 POST https://woc.reference.genitrust.com/api/v1/holds/
 ```
 
 It need X-Coins-Api-Token as a header parameter which is five time mobile number without space and country code.
 
 ##### Request :
 
 ```json
 {
 "publisherId": "",
 "offer": "eyJ1c2QiOiAiNTA...",
 "phone": "+19411101467",
 "deviceName": "Ref Client",
 "password": "94111014679411101467941110146794111014679411101467"
 }
 ```*/

- (void)createHold:(NSDictionary*)params response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/holds/",BASE_URL];
    NSString *phNo = [NSString stringWithFormat:@"%@",[params valueForKey:USER_DEFAULTS_LOCAL_DEVICE_CODE]];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];

    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE:@"application/json"
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token,
                   API_HEADER_CONTENT_TYPE: @"application/json"
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CAPTURE HOLD
 
 We have to match user input code with `__PURCHASE_CODE`  and if verify, we have to proceed further.
 
 ```http
 HEADER X-Coins-Api-Token: ZGV2aWNlOjQ0NT...
 
 POST https://woc.reference.genitrust.com/api/v1/holds/<Hold ID>/capture/
 ```
 
 #####Request :
 
 ```
 {
 "verificationCode": "CK99K"
 }
 ```*/

- (void)captureHold:(NSDictionary*)params holdId:(NSString *)holdId response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/holds/%@/capture/",BASE_URL,holdId];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE:@"application/json"
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token,
                   API_HEADER_CONTENT_TYPE: @"application/json"
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CONFIRM DEPOSIT
 
 ```http
 HEADER X-Coins-Api-Token:
 
 POST https://woc.reference.genitrust.com/api/v1/orders/<Order ID>/confirmDeposit/
 ```*/

- (void)confirmDeposit:(NSString *)orderId response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/orders/%@/confirmDeposit/",BASE_URL,orderId];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: nil header: header andCompletionBlock:^(id responseDict, NSError *error){
        completionBlock(responseDict,error);
    }];
}

- (void)cancelOrder:(NSString *)orderId response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/orders/%@/",BASE_URL,orderId];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"DELETE" parameter: nil header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

- (void)getOrders:(NSDictionary*)params response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/orders/",BASE_URL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];

    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
        [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
            completionBlock(responseDict,error);
        }];
    }
    else {
            NSError * returnError = [NSError errorWithDomain:API_ERROR_TITLE code:403 userInfo:nil];
            completionBlock(nil,returnError);
    }
   
}

- (void)authorizeDevice:(NSDictionary*)params phone:(NSString*)phoneNo response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/auth/%@/",BASE_URL,phoneNo];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

- (void)login:(NSDictionary*)params phone:(NSString*)phoneNo response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/auth/%@/authorize/",BASE_URL,phoneNo];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                             API_HEADER_CONTENT_TYPE: @"application/json"
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

- (void)signOut:(NSDictionary*)params phone:(NSString*)phoneNo response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/auth/%@/",BASE_URL,phoneNo];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    [self makeAPIRequestWithURL:apiURL methord:@"DELETE" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

- (void)getDevice:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/devices/",BASE_URL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];

    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter:nil header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

- (void)registerDevice:(NSDictionary*)params response:(void (^)(id responseDict, NSError *error))completionBlock
{
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/devices/",BASE_URL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                            API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                            API_HEADER_CONTENT_TYPE: @"application/json"
                            };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token,
                   API_HEADER_CONTENT_TYPE: @"application/json"
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

-(void)deleteHold:(NSString*)holdId response:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/holds/%@/",BASE_URL,holdId];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
    }
    
    [self makeAPIRequestWithURL:apiURL methord:@"DELETE" parameter: nil header: header andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

-(void)getHold:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/api/v1/holds/",BASE_URL];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_AUTH_TOKEN];
    
    NSDictionary *header = @{
                             API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID
                             };
    
    if (token != nil && [token isEqualToString:@"(null)"] == FALSE)
    {
        header = @{
                   API_HEADER_PUBLISHER_ID: @WALLOFCOINS_PUBLISHER_ID,
                   API_HEADER_TOKEN: token
                   };
        
        [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: nil header: header andCompletionBlock:^(id responseDict, NSError *error) {
            completionBlock(responseDict,error);
        }];
    }
    else {
      
        NSError *returnError = [NSError errorWithDomain:API_ERROR_TITLE code:403 userInfo:@{@"response":@"error",@"detail":@"Error in featching active hold"}];
        completionBlock(nil,returnError);
    }
}

// MARK: - API calls
-(void)makeAPIRequestWithURL:(NSString*)apiURL methord:(NSString*)httpMethord parameter:(id)parameter header:(NSDictionary*)header andCompletionBlock:(void (^)(id responseDict, NSError *error))completionBlock
{
    APILog(@"**>API REQUEST URL: %@\n%@",httpMethord,apiURL);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    if ([httpMethord isEqualToString:@"GET"] == FALSE) {
        
        [request setHTTPMethod:httpMethord];
        
        if ([parameter isKindOfClass:[NSDictionary class]]) {
            
            APILog(@"**>API REQUEST Parameter: \n%@",parameter);
            NSDictionary *para = (NSDictionary*)parameter;
            
            if ([[para allKeys] containsObject:JSONParameter]) {
                
                NSData *postData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:nil];
                [request setHTTPBody:postData];
            }
            else {
                
                [request setHTTPBody:[self httpBodyForParamsDictionary:parameter]];
            }
        }
    }
    
    if (header!= nil) {
        
        APILog(@"**>API REQUEST Header: \n%@",header);
        [request setAllHTTPHeaderFields:header];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        
        NSError *error = nil;
        APILog(@"==>API Response statusCode [%ld]",((NSHTTPURLResponse*)response).statusCode);

        if (data != nil) {
            
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             APILog(@"==>API RESPONSE : \n%@",dictionary);

            if (connectionError != nil) {
                
                APILog(@"XX>API RESPONSE ERROR: [%ld]\n%@ ",((NSHTTPURLResponse*)response).statusCode,connectionError.localizedDescription);
            }
            
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                
                NSError * returnError = connectionError;
                if (!returnError) {
                    
                    if (dictionary[@"detail"] != nil) {
                        
                        returnError = [NSError errorWithDomain:API_ERROR_TITLE code:((NSHTTPURLResponse*)response).statusCode userInfo:dictionary];
                    }
                    else {
                        
                        returnError = [NSError errorWithDomain:API_ERROR_TITLE code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    completionBlock(nil,returnError);
                });
                return;
            }
            else if (((NSHTTPURLResponse*)response).statusCode == 204) {
                
                NSDictionary *responseDict = @{@"content":@"NO"} ;
                completionBlock(responseDict,nil);
                return;
            }
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    APILog(@"XX>API RESPONSE ERROR: \n%@",error.localizedDescription);
                    completionBlock(nil,error);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dictionary != nil) {
                   
                    completionBlock(dictionary,nil);
                }
                else {
                    
                    APILog(@"==>API RESPONSE : \n%@",@{@"response":@"error"});
                    completionBlock(@{@"response":@"error"},nil);
                }
            });
        }
        else {
            
            APILog(@"==>API RESPONSE : \n%@",@{@"response":@"error"});
            completionBlock(@{@"response":@"error"},nil);
        }
    }] resume];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            [parameterArray addObject:param];
        }
        else {
            
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
            [parameterArray addObject:param];
        }
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    APILog(@"##>API REQUEST PARAMETERS: \n%@",string);
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

