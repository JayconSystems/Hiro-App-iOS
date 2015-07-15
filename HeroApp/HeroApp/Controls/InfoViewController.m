//
//  InfoViewController.m
//  HiroApp
//
//  Created by -Jaycon Systems on 01/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings Info";
<<<<<<< HEAD
=======
    self.navigationController.navigationItem.title = @"";
>>>>>>> fix-narrow-wifi-screen
    
    self.innerView.layer.cornerRadius = 3.0f;
    self.scrollView.layer.cornerRadius = 3.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
