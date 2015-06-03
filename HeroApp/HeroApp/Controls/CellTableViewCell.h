//
//  CellTableViewCell.h
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeroCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgHeroPic;
@property (nonatomic, retain) IBOutlet UITextField *txtFieldName;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewBattery;
@property (nonatomic, retain) IBOutlet UIButton *btnNotification;
@property (nonatomic, retain) IBOutlet UIButton *btnNearBy;
@property (nonatomic, retain) IBOutlet UIButton *btnLocation;
@property (nonatomic, retain) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIView *viewBase;
@property (weak,nonatomic)HeroActor *deviceActor;
@property (nonatomic,strong) NSTimer *refreshTimer;
@property (nonatomic,strong) NSTimer *soundTimer;

- (void)initializeCell:(HeroActor *)deviceActor;
- (IBAction)actionPlaySound:(id)sender;
@end

@interface CellTableViewCell : UITableViewCell

@end
