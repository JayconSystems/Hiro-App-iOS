//
//  ScanTableViewController.h
//  HiroApp
//
//  Created by Jaycon Systems on 07/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnScan;

@property (strong,nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) NSTimer *scanTimer;
@property (strong,nonatomic)CBPeripheral *selectedPeripheral;

- (IBAction)actionScan:(id)sender;
- (IBAction)actionCancel:(id)sender;


@end
