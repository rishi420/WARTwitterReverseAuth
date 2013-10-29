//
//  TwitterSignInManager.m
//  TWiOSReverseAuthExample
//
//  Created by Warif Akhand Rishi on 10/29/13.
//  Copyright (c) 2013 Twitter, Inc. All rights reserved.
//


#import <Twitter/Twitter.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "TwitterSignInManager.h"

#define ERROR_TITLE_MSG @"Whoa, there cowboy"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this demo."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

@interface TwitterSignInManager ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@end

@implementation TwitterSignInManager

- (id)init
{
    if (self = [super init]) {
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWAPIManager alloc] init];
    }
    return self;
}

- (NSArray *)userNames
{
    NSMutableArray *userNames = [[NSMutableArray alloc] init];
    for (ACAccount *acct in _accounts) {
        [userNames addObject:acct.username];
    }
    return userNames;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self performReverseAuthForAccountAtIndex:buttonIndex];
    }
}

- (void)performReverseAuthForAccountAtIndex:(int)index
{
    [_apiManager performReverseAuthForAccount:_accounts[index] withHandler:^(NSData *responseData, NSError *error) {
        if (responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            TWDLog(@"Reverse Auth process returned: %@", responseStr);
            
            NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
            NSString *lined = [parts componentsJoinedByString:@"\n"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                if ([_delegate respondsToSelector:@selector(twitterAuthTokenDidSuccess:)]) {
                    [_delegate performSelector:@selector(twitterAuthTokenDidSuccess:) withObject:lined ];
                }
            });
        }
        else {
            TWALog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
            if ([_delegate respondsToSelector:@selector(twitterAuthTokenDidfail::)]) {
                [_delegate performSelector:@selector(twitterAuthTokenDidfail::) withObject:[error localizedDescription]];
            }
        }
    }];
}

#pragma mark - Private
/**
 *  Checks for the current Twitter configuration on the device / simulator.
 *
 *  First, we check to make sure that we've got keys to work with inside Info.plist (see README)
 *
 *  Then we check to see if the device has accounts available via +[TWAPIManager isLocalTwitterAccountAvailable].
 *
 *  Next, we ask the user for permission to access his/her accounts.
 *
 *  Upon completion, the button to continue will be displayed, or the user will be presented with a status message.
 */
- (void)refreshTwitterAccountsWithSuccessBlock:(void (^)())success andFailureBlock:(void (^)(NSString *errorDescription))error
{
    TWDLog(@"Refreshing Twitter Accounts \n");
    
    if (![TWAPIManager hasAppKeys]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
        error(ERROR_NO_KEYS);
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        [alert show];
        error(ERROR_NO_ACCOUNTS);
    }
    else {
        [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    success();
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    TWALog(@"You were not granted access to the Twitter accounts.");
                    error(ERROR_PERM_ACCESS);
                }
            });
        }];
    }
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    
    //  This method changed in iOS6. If the new version isn't available, fall back to the original (which means that we're running on iOS5+).
    if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
    }
    else {
        [_accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:handler];
    }
}

@end
