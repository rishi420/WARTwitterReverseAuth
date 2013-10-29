//
//    TWViewController.m
//    TWiOSReverseAuthExample
//
//    Copyright (c) 2013 Sean Cook
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to permit
//    persons to whom the Software is furnished to do so, subject to the
//    following conditions:
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
//    NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//    USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "TWViewController.h"

@interface TWViewController()
@property (nonatomic, strong) TwitterSignInManager *twitterSignInManager;
@property (nonatomic, strong) UIButton *reverseAuthBtn;

@end

@implementation TWViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
       
    }
    return self;
}

- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;

    CGRect buttonFrame = appFrame;
    buttonFrame.origin.y = floorf(0.75f * appFrame.size.height);
    buttonFrame.size.height = 44.0f;
    buttonFrame = CGRectInset(buttonFrame, 20, 0);

    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor colorWithWhite:0.502 alpha:1.000]];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter.png"]];
    [view addSubview:imageView];
    [imageView sizeToFit];
    imageView.center = view.center;

    CGRect imageFrame = imageView.frame;
    imageFrame.origin.y = floorf(0.25f * appFrame.size.height);
    imageView.frame = imageFrame;

    _reverseAuthBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_reverseAuthBtn setTitle:@"Perform Token Exchange" forState:UIControlStateNormal];
    [_reverseAuthBtn addTarget:self action:@selector(performReverseAuth:) forControlEvents:UIControlEventTouchUpInside];
    _reverseAuthBtn.frame = buttonFrame;
    _reverseAuthBtn.enabled = NO;
    [_reverseAuthBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view addSubview:_reverseAuthBtn];

    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTwitterAccounts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _twitterSignInManager = [[TwitterSignInManager alloc] init];
    _twitterSignInManager.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshTwitterAccounts
{
    [_twitterSignInManager refreshTwitterAccountsWithSuccessBlock:^{
        [self granted];
    } andFailureBlock:^(NSString *errorDescription) {
        NSLog(@"%@", errorDescription);
    }];
}

/**
*  Handles the button press that initiates the token exchange.
*
*  We check the current configuration inside -[UIViewController viewDidAppear].
*/
- (void)performReverseAuth:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:_twitterSignInManager cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *userName in _twitterSignInManager.userNames) {
        [sheet addButtonWithTitle:userName];
    }

    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}

- (void)granted
{
    _reverseAuthBtn.enabled = YES;
}


#pragma mark TwitterSignInManagerDelegate
- (void)twitterAuthTokenDidSuccess:(NSString *)result
{
    NSLog(@"%@", result);
}

- (void)twitterAuthTokenDidfail:(NSString *)errorDescription
{
    NSLog(@"%@", errorDescription);
}

@end
