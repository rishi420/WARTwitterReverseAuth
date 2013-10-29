//
//  TwitterSignInManager.h
//  TWiOSReverseAuthExample
//
//  Created by Warif Akhand Rishi on 10/29/13.
//  Copyright (c) 2013 Twitter, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@protocol TwitterSignManagerDelegate <NSObject>
- (void)twitterAuthTokenDidSuccess:(NSString *)result;
- (void)twitterAuthTokenDidfail:(NSString *)errorDescription;
@end

@interface TwitterSignInManager : NSObject <UIActionSheetDelegate>
@property (nonatomic, assign) id<TwitterSignManagerDelegate> delegate;
@property (readonly) NSArray *userNames;
- (void)refreshTwitterAccountsWithSuccessBlock:(void (^)())success andFailureBlock:(void (^)(NSString *errorDescription))error;
- (void)performReverseAuthForAccountAtIndex:(int)index;
@end
