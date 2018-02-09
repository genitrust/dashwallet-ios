# Wallofcoins (iPhone)
##### Current Build version [0.8.11(0)]

----
## Activity Logs


All notable changes to WOC will be documented in this file.

----------
#WOC

###**Initial version. 0.8.11(0)**

## [WEEK-1] 7 JAN 2018
### [STATUS] 12 JAN 2018 (FRI)

#### Work on 12 JAN 2018 Sujal Bandhara

1. Checkout dashwallet code from genitrust from
[git](https://github.com/genitrust/dashwallet-ios) and Setup initial code in Xcode
```
git clone https://github.com/genitrust/dashwallet-ios
```
2. Resolved issues in the Xcode project and Run the Project in the Xcode Simulator.
3. Remove **dashwalletTodayExtension.entitlements** as it was not avaliable after checkout the code
4. Setup VPN to work with the API in Xcode Simulator in India
5. Create Activity Logs file for Daily Activity
6. Understanding Code project and API documentation
7. Setup Restlet Client

#### Work on 13 JAN 2018 (SAT) Sujal Bandhara

1. Create API Manager
2. Create Menu for iOS App as per projects.invisionapp.com
https://projects.invisionapp.com/d/main#/console/11024098/233342118/preview#project_console

### [STATUS] 14 JAN 2018 (SUN)

Holiday

## [WEEK-2] 15 JAN 2018
### [STATUS] 15 JAN 2018 (MON)

Festival Holiday

#### Work on 16 JAN 2018 (TUE) Sujal Bandhara

1. Worked on Request-Dash screen UI Design
2. Worked on Address-Book screen UI Design
3. Worked on Send-Dash screen UI Design
4. Completed Dash-Hash Menu Screen UI Design

#### Work on 17 JAN 2018 (WED) Sujal Bandhara

1. Completed  Request-Dash screen UI Design
2. Completed  Address-Book screen UI Design
3. Completed  Send-Dash screen UI Design
4. Completed  Opening Screen UI Design
5. Added  6 following API's in API Manager
5. 1 GET AVAILABLE PAYMENT CENTERS (OPTIONAL)
5. 2 SEARCH & DISCOVERY
5. 3 GET OFFERS API
5. 4 CREATE HOLD API
5. 5 CAPTURE HOLD API
5. 6 CONFIRM DEPOSIT API
        
#### Work on 18 JAN 2018 (THU) Sujal Bandhara
        
1. Worked on Exchange rates screen
2. Worked on Safety UI
3. Worked on Safety Notes POPUP UI
4. Worked on Back Up Wallet POPUP UI
5. Worked on Restore Wallet POPUP UI
6. Worked on Spending PIN POPUP UI
7. Worked on Settings UI

#### Work on 19 JAN 2018 (FRI) Sujal Bandhara

1. Worked on Settings screen
1. 1 Worked on Settings - Denomination and precision screen
1. 2 Worked on Settings - Own name screen
1. 3 Worked on Settings - Trusted peer screen
1. 4 Worked on Settings - Block explorer screen

2. Worked on Diagnostics UI
2. 1 Worked on Diagnostics - Report issue screen
2. 2 Worked on Diagnostics - Reset block chain screen
2. 3 Worked on Diagnostics - Show xPub screen

3. Worked on About UI

### [STATUS] 20 JAN 2018 (SAT)

Holiday

### [STATUS] 21 JAN 2018 (SUN)

Holiday

## [WEEK-3] 22 JAN 2018
#### Work on 22 JAN 2018 (MON) Sujal Bandhara

1. Created Buy Dash with Cash screen UI
1. 1 Step 1 - Backup wallet and Load Wallet UI
1. 2 Step 2 - Find my location UI
1. 3  Step 3 - Zip code UI
1. 4 Step 4 - Enter Dash or Dollar UI
1. 5 Step 5 - Get offers UI
1. 6 Step 6 - Send or Do not send me email UI
1. 7 Step 7 - Enter mobile number UI
1. 8 Step 8 - Confirm purchase code UI
1. 9 Step 9 - Buying Instructions UI - 50%


#### Work on 23 JAN 2018 (TUE) Sujal Bandhara

1. Recheck-out code from "origin/wallofcoins-buying-wizard"

2. Created new branch "buyDashWithCash"

3. Buy Dash with Cash screen UI
3. 1 Step 9 - Buying Instructions UI
3. 2 Step 10 - Buying Summary UI
3. 3 Select Payment Center UI
    
4. Added Location Manager Class

#### Work on 24 JAN 2018 (WED) Sujal Bandhara

1. BuyingWizard navigation flow completed.
2. Implementation of "GET AVAILABLE PAYMENT CENTERS" API

#### Work on 25 JAN 2018 (THU) Sujal Bandhara

1. Implementation of "STEP 0: SEARCH & DISCOVERY" API
2. Implementation of "STEP 1: GET OFFERS" API
3. Implementation of "STEP 2: CREATE HOLD" API
4. Implementation of "STEP 3: CAPTURE HOLD" API

#### Work on 26 JAN 2018 (FRI) Sujal Bandhara

1. Implementation of "STEP 4: CONFIRM DEPOSIT" API
2. Implementation of "CANCEL ORDER" API
3. Implementation of "GET ORDERS" API 

#### Work on 27 JAN 2018 (SAT) Sujal Bandhara

1. Created Enter Password UI
2. Implementation of "/auth/" API
3. Implementation of "/auth/#phoneNo/authorize/" API
4. Implementation of "/auth/#phoneNo/" API

## [WEEK-4] 29 JAN 2018
#### Work on 29 JAN 2018 (MON) Sujal Bandhara

1. Add order status in BuyingSummary
2. Navigation from Home screen
3. Pass unique deviceId in "deviceCode" to resolve "MultipleObjectsReturned" issue
4. Implemented all BuyingWizard APIs.

#### Work on 30 JAN 2018 (Tue) Sujal Bandhara

#### Work on 31 JAN 2018 (Wed) Sujal Bandhara

1. Added checkLocation button in Offers Screen
2. Added Timer in Buying Instuctions
3. Added Signout button in Buying Instuctions

#### Work on 01 FEB 2018 (THU) Sujal Bandhara

1. Added links in Buying Instruction
2. Added Call instruction in Buying Instruction
3. Added user info instead of account detail in Buying Summary
4. Added mail composer on "click here" in Buying Summary

#### Work on 02 FEB 2018 (FRI) Sujal Bandhara

1. Added country picker
2. Sorted payment centers alphabetically
3. Handled error messages
4. Testing and bug solving

#### Work on 03 FEB 2018 (SAT) Sujal Bandhara

Holiday

#### Work on 04 FEB 2018 (SUN) Sujal Bandhara

Holiday

#### Work on 05 FEB 2018 (MON) Sujal Bandhara


#### Work on 06 FEB 2018 (TUE) Sujal Bandhara


#### Work on 07 FEB 2018 (WED) Sujal Bandhara

1. POST /api/v1/holds/ status code 400 is not handled.
2. Changed publisherId to "publisher-id"
3. Updated "WallofCoins-README.md"
4. Testing and bug solving

#### Work on 08 FEB 2018 (THU) Sujal Bandhara

1. Displayed 'WDV' orders before SignOut section and other orders after SignOut section in Buying Summary
2. Testing and bug solving

#### Work on 09 FEB 2018 (FRI) Sujal Bandhara

1. Set Header "X-Coins-Publisher"  to Publisher ID “52” in every API call.
2. Added “cryptoAddress” in discoveryInputs API
3. Added constants for body parameters in Constants.h file
4. Testing and bug solving
