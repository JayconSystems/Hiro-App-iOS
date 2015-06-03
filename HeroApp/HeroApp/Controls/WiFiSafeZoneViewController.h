//
//  WiFiSafeZoneViewController.h
//  Hiro
//
//  Created by Jaycon Systems on 16/03/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WiFiSafeZoneViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblConnectedWiFi;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIImageView *imgStrengh;
- (IBAction)actionAdd:(id)sender;



@end
