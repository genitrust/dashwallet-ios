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

@interface APIManager()

@end

@implementation APIManager

-(id)init {
    
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

-(void)initAPIManager
{
    APILog(@"Init APIManager");
}

#pragma mark - Wallofcoins API calls
-(void)testAPI
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
    
    [self discoverInfo:^(id responseDict, NSError *error) {
        APILog(@"discoverInfo Called");
    }];
    
    [self discoveryInputs:@"1" response:^(id responseDict, NSError *error) {
        APILog(@"discoveryInputs Called");
    }];
    
    [self createHold:^(id responseDict, NSError *error) {
        APILog(@"createHold Called");
    }];
    
    [self captureHold:@"1" response:^(id responseDict, NSError *error) {
        APILog(@"captureHold Called");
    }];
    
    [self confirmDeposit:@"1" response:^(id responseDict, NSError *error) {
        APILog(@"confirmDeposit Called");
    }];
}
     
////////////////////////////////////////////////////////////////////
/*
 Name: GET AVAILABLE PAYMENT CENTERS (OPTIONAL)
 Detail : API for get payment center list using GET method...
 API Funcation Name: getAvailablePaymentCenters
 Url: http://woc.reference.genitrust.com/api/v1/banks/
 Method: GET
 
 Success Output:
 [
 {
 "id": 14,
 "name": "Genitrust",
 "url": "http://genitrust.com/",
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

-(void)getAvailablePaymentCenters:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/banks/",BASE_URL];
    NSDictionary *params =
    @{
      @"id": @14,
      @"country": @"us",
      @"payFields": @false
      };
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: params  header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*
 #### SEARCH & DISCOVERY
 
 An API for discover available option, which will return Discovery ID along with list of information.
 
 ```http
 POST http://woc.reference.genitrust.com/api/v1/discoveryInputs/
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
-(void)discoverInfo:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/discoveryInputs/",BASE_URL];
    NSDictionary *params =
    @{
      @"publisherId": @"",
      @"cryptoAddress": @"",
      @"usdAmount": @"500",
      @"crypto": @"DASH",
      @"bank": @"",
      @"zipCode": @"34236"
      };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### GET OFFERS

An API for fetch all offers for received Discovery ID.

```http
GET http://woc.reference.genitrust.com/api/v1/discoveryInputs/<Discovery ID>/offers/
```*/

-(void)discoveryInputs:(NSString*)dicoverId response:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/discoveryInputs/%@/offers/",BASE_URL,dicoverId];
    NSDictionary *params =
    @{
      
      };
    
    [self makeAPIRequestWithURL:apiURL methord:@"GET" parameter: params header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CREATE HOLD

From offer list on offer click we have to create an hold on offer for generate initial request.

```http
HEADER X-Coins-Api-Token:

POST http://woc.reference.genitrust.com/api/v1/holds/
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

-(void)createHold:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/holds/",BASE_URL];
    NSDictionary *params =
    @{
        @"publisherId": @"",
        @"offer": @"eyJ1c2QiOiAiNTA...",
        @"phone": @"+19411101467",
        @"deviceName": @"Ref Client",
        @"password": @"94111014679411101467941110146794111014679411101467"
    };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CAPTURE HOLD

We have to match user input code with `__PURCHASE_CODE`  and if verify, we have to proceed further.

```http
HEADER X-Coins-Api-Token: ZGV2aWNlOjQ0NT...

POST http://woc.reference.genitrust.com/api/v1/holds/<Hold ID>/capture/
```

#####Request :

```
{
    "publisherId": "",
    "verificationCode": "CK99K"
}
```*/

-(void)captureHold:(NSString *)holdId response:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/holds/%@/capture",BASE_URL,holdId];
    NSDictionary *params =
    @{
        @"publisherId": @"",
        @"verificationCode": @"CK99K"
    };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}

/*#### CONFIRM DEPOSIT

```http
HEADER X-Coins-Api-Token:

POST http://woc.reference.genitrust.com/api/v1/orders/<Order ID>/confirmDeposit/
```*/

-(void)confirmDeposit:(NSString *)orderId response:(void (^)(id responseDict, NSError *error))completionBlock {
    
    NSString *apiURL = [NSString stringWithFormat:@"%@/confirmDeposit/%@/confirmDeposit",BASE_URL,orderId];
    NSDictionary *params =
    @{
      
      };
    
    [self makeAPIRequestWithURL:apiURL methord:@"POST" parameter: params header: nil andCompletionBlock:^(id responseDict, NSError *error) {
        completionBlock(responseDict,error);
    }];
}


#pragma mark - API calls
-(void)makeAPIRequestWithURL:(NSString*)apiURL methord:(NSString*)httpMethord parameter:(id)parameter header:(NSDictionary*)header andCompletionBlock:(void (^)(id responseDict, NSError *error))completionBlock {
    
    APILog(@"**>API REQUEST URL: \n%@",apiURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT_INTERVAL];
    
    if ([httpMethord isEqualToString:@"GET"] == FALSE)
    {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:httpMethord];
        [request setHTTPBody:[self httpBodyForParamsDictionary:parameter]];
    }
    
    if (header!= nil)
    {
        for (NSString *key in header.allKeys)
        {
            NSString *headerValue = [header[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [request setValue:headerValue forHTTPHeaderField:key];
        }
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
            NSError * returnError = connectionError;
            if (!returnError) {
                returnError = [NSError errorWithDomain:API_ERROR_TITLE code:((NSHTTPURLResponse*)response).statusCode userInfo:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                APILog(@"XX>API RESPONSE ERROR: \n%@",returnError.localizedDescription);
                completionBlock(nil,returnError);
            });
            return;
        }
        NSError *error = nil;
        id dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                APILog(@"XX>API RESPONSE ERROR: \n%@",error.localizedDescription);
                completionBlock(nil,error);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            APILog(@"==>API RESPONSE : \n%@",dictionary);
            completionBlock(dictionary,nil);
        });
    }] resume];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            [parameterArray addObject:param];
        } else {
            NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
            [parameterArray addObject:param];
        }
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    APILog(@"##>API REQUEST PARAMETERS: \n%@",string);
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
