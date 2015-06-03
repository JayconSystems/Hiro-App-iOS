//
//  SettingViewController.h
//  HiroApp
//
//  Created by -Jaycon Systems on 01/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (weak,nonatomic) IBOutlet  UIView *innerView;
@property (weak,nonatomic) IBOutlet  UIView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hirobeepVolume;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segHiroBeepAlert;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segLowbattery;
@property (weak, nonatomic) IBOutlet UIButton *btnPushNotification;
@property (weak, nonatomic) IBOutlet UIButton *btnHiroSoundAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnBeepAlert;

@property (weak, nonatomic) IBOutlet UIButton *btnSoundAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnFindPhoneAlert;
@property (strong,nonatomic) HeroActor *actor;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

- (IBAction)actionDelete:(id)sender;

- (IBAction)actionPhoneSoundAlert:(id)sender;
- (IBAction)actionPhoneThroughFeature:(id)sender;



@end
