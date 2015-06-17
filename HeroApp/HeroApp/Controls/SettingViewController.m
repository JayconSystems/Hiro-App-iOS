//
//  SettingViewController.m
//  HiroApp
//
//  Created by -Jaycon Systems on 01/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "SettingViewController.h"
#import "RingToneTableViewController.h"

@interface SettingViewController ()
{
    NSInteger index;
}
@end


@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Settings";
    self.navigationController.navigationBar.topItem.title = @"";

    
    self.innerView.layer.cornerRadius = 3.0f;
    self.scrollView.layer.cornerRadius = 3.0f;
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *modalButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [self.navigationItem setRightBarButtonItem:modalButton animated:YES];
    
    
    [self.hirobeepVolume setSelectedSegmentIndex:[self.actor.state[kHeroVolume] isEqualToString:kHeroBeepVolumeMild] ? 0 : 1];
    [self.segLowbattery setSelectedSegmentIndex:![self.actor.state[kLowBatteryNotificationIsEnable] boolValue]];
    [self.segHiroBeepAlert setSelectedSegmentIndex:[self.actor.state[kHeroAlertVolume] isEqualToString:kHeroBeepVolumeMild] ? 0 : 1];
    
    self.btnBeepAlert.selected = [self.actor.state[kHeroAlertIsEnable]boolValue];
     self.btnHiroSoundAlert.selected = [self.actor.state[kPhoneSoundAlertISEnable] boolValue];
     self.btnPushNotification.selected = [self.actor.state[kPushNotificaitonIsEnable]boolValue];
    self.btnDelete.layer.cornerRadius = 3.0f;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if([ReadValue(SOUND_FIND_PHONE_THUR_HIRO) isEqualToString:@"HiroTone1"]){
        [self.btnFindPhoneAlert setTitle:@"Default ringtone >" forState:UIControlStateNormal];
    }
    else{
        [self.btnFindPhoneAlert setTitle:[NSString stringWithFormat:@"%@ >",ReadValue(SOUND_FIND_PHONE_THUR_HIRO)] forState:UIControlStateNormal];
    }
    
    if([self.actor.state[SOUND_PHONE_SOUND_ALERT] isEqualToString:@"HiroTone2"]){
        [self.btnSoundAlert setTitle:@"Default ringtone >" forState:UIControlStateNormal];
    }
    else{
         [self.btnSoundAlert setTitle:[NSString stringWithFormat:@"%@ >",self.actor.state[SOUND_PHONE_SOUND_ALERT]] forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)infoButtonAction
{
    [self performSegueWithIdentifier:@"segueInfo" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueringtone"]) {
        RingToneTableViewController *rington = segue.destinationViewController;
        rington.actor = self.actor;
        rington.seletedValue = index;
    }
}



- (IBAction)HiroBeepVolumeChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.actor.state[kHeroVolume] = kHeroBeepVolumeMild;
    }else{
        self.actor.state[kHeroVolume]= kHeroBeepVolumeHigh;
    }
}

- (IBAction)LowBatteryVolumeChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.actor.state[kLowBatteryNotificationIsEnable] = [NSNumber numberWithBool:TRUE];
    }else{
        self.actor.state[kLowBatteryNotificationIsEnable] = [NSNumber numberWithBool:FALSE];
    }
}

- (IBAction)HiroBeepAlertChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.actor.state[kHeroAlertVolume] = kHeroBeepVolumeMild;
    }else{
        self.actor.state[kHeroAlertVolume] = kHeroBeepVolumeHigh;
    }
    [self checkAndUpdateLinkLoss];
}

- (IBAction)PushNotificationChange:(UIButton *)sender {
    if (sender.isSelected) {
        self.btnPushNotification.selected = false;
        self.actor.state[kPushNotificaitonIsEnable] = [NSNumber numberWithBool:FALSE];
    }else{
        self.btnPushNotification.selected = true;
        self.actor.state[kPushNotificaitonIsEnable] = [NSNumber numberWithBool:TRUE];
    }
}
- (IBAction)PhoneSoundAlert:(UIButton *)sender {
    if (sender.isSelected) {
        self.btnHiroSoundAlert.selected = false;
        self.actor.state[kPhoneSoundAlertISEnable] = [NSNumber numberWithBool:FALSE];
    }else{
        self.btnHiroSoundAlert.selected = true;
        self.actor.state[kPhoneSoundAlertISEnable] = [NSNumber numberWithBool:TRUE];
    }
}
- (IBAction)HiroBeepAlert:(UIButton *)sender {
    if (sender.isSelected) {
        self.btnBeepAlert.selected = false;
        self.actor.state[kHeroAlertIsEnable] = [NSNumber numberWithBool:FALSE];;
    }else{
        self.btnBeepAlert.selected = true;
        self.actor.state[kHeroAlertIsEnable] = [NSNumber numberWithBool:TRUE];
    }
    [self checkAndUpdateLinkLoss];
}

- (IBAction)actionDelete:(id)sender {
    ShowUIAlertWithYesNoButtonsAndTapBlock(@"Warning!", @"Removes all details of this Hiro. Cannot be undone. Are you Sure?", YES, ^(BOOL yes) {
        if(yes){
            
            if (self.actor) {
                [AppDelegate_.centralManagerActor.centralManager cancelPeripheralConnection:self.actor.peripheralActor.peripheral];
                
                self.actor.peripheralActor.peripheral.delegate = nil;
                
                [AppDelegate_.deviceActors removeObject:self.actor];
                [AppDelegate_.centralManagerActor.peripherals removeObject:self.actor.peripheralActor.peripheral];
                self.actor.peripheralActor.peripheral = nil;
                
                [AppDelegate_ storeDevicesState];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    });
}


- (void)checkAndUpdateLinkLoss{
    
    if(self.actor.isConnected){
        
        int linkLossLevel;
        if([self.actor.state[kHeroAlertIsEnable] boolValue]){
            if([self.actor.state[kHeroAlertVolume] isEqualToString:kHeroBeepVolumeMild]){
                linkLossLevel = 1;
            }
            else{
                linkLossLevel = 2;
            }
        }
        else{
            linkLossLevel = 0;
        }
        
         [self.actor performCommand:kCommandUpdateLinkLoss withParams:[@{kCharacteristicLinkLossLevel:[NSNumber numberWithInt:linkLossLevel]}mutableCopy]];
    }
    
}
- (IBAction)actionPhoneSoundAlert:(id)sender {
    index = 1;
    [self performSegueWithIdentifier:@"segueringtone" sender:self];
}

- (IBAction)actionPhoneThroughFeature:(id)sender {
    index = 2;
    [self performSegueWithIdentifier:@"segueringtone" sender:self];
}
@end
