//
//  ViewController.m
//  TestConnection
//
//  Created by Alexey Gubarev on 3/25/15.
//  Copyright (c) 2015, Alexey Gubarev. All rights reserved.
//

#import "ViewController.h"
#import "ServerReachability.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)checkConnectionButtonTapped:(id)sender {
    ServerReachability *serverReachability = [ServerReachability reachabilityWithServer:self.urlTextField.text];
    
    self.statusLabel.text = serverReachability.isReachable ? @"Success" : @"Failed";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

@end
