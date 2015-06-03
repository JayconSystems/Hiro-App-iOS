//
//  RootViewController.h
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CellTableViewCell.h"
@interface RootViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak,nonatomic) IBOutlet  UITableView *tableView;

- (IBAction)actionAddDevice:(id)sender;
@end
