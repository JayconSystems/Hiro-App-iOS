//
//  CellTableViewCell.m
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "CellTableViewCell.h"




@implementation CellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

@implementation HeroCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)initializeCell:(HeroActor *)deviceActor{
    self.deviceActor = deviceActor;
    if(self.refreshTimer){
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    [self refreshTimer];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshView) userInfo:nil repeats:YES];
}

- (IBAction)actionPlaySound:(id)sender {
    int soundLevel = 0;
    if(self.btnNotification.isSelected){
        soundLevel = 0;
        
//        if(self.soundTimer){
//            [self.soundTimer invalidate];
//            self.soundTimer = nil;
//        }
        [self.deviceActor performCommand:kCommandPlayAlert withParams:[@{kCharacteristicAlertLevel:[NSNumber numberWithInt:soundLevel]}mutableCopy]];
        self.btnNotification.selected = FALSE;
    }
    else{
        soundLevel = ([self.deviceActor.state[kHeroVolume]isEqualToString:kHeroBeepVolumeHigh])?2:1;
        [self.deviceActor performCommand:kCommandPlayAlert withParams:[@{kCharacteristicAlertLevel:[NSNumber numberWithInt:soundLevel]}mutableCopy]];
        self.btnNotification.selected = TRUE;
//        if(self.soundTimer){
//            [self.soundTimer invalidate];
//            self.soundTimer = nil;
//        }
//        self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:(soundLevel==2)?10:7 target:self selector:@selector(buttonSetSelectedFalse) userInfo:nil repeats:NO];
    }
    
}

- (void)buttonSetSelectedFalse{
    [self.btnNotification setSelected:FALSE];
}

- (void)refreshView{
    
    DLog(@"Cell refreshed with RSSI %@",self.deviceActor.averageRSSI);
    if(self.deviceActor.isConnected){
        
        NSString *rssiImage;
        if([self.deviceActor.averageRSSI intValue]>-70){
            rssiImage = @"Signal_N3";
        }
        else if([self.deviceActor.averageRSSI intValue]>-85){
            rssiImage = @"Signal_N2";
        }
        else if([self.deviceActor.averageRSSI intValue]>-95){
            rssiImage = @"Signal_N1";
        }
        else{
            rssiImage = @"Signal_N0";
        }
        
        NSString *batteryImage;
        if([self.deviceActor.state[kBatteryLevel] intValue]>80){
            batteryImage = @"Battery_N4";
        }
        else if([self.deviceActor.state[kBatteryLevel] intValue]>60){
            batteryImage = @"Battery_N3";
        }
        else if([self.deviceActor.state[kBatteryLevel] intValue]>20){
            batteryImage = @"Battery_N2";
        }
        else{
            batteryImage = @"Battery_N1";
        }
        
        [self.imgViewBattery setImage:[UIImage imageNamed:batteryImage]];
        
        [self.btnNearBy setImage:[UIImage imageNamed:rssiImage] forState:UIControlStateNormal];
        self.btnLocation.enabled = true;
        self.btnNearBy.enabled = true;
        self.btnNotification.enabled = true;
        
        
    }
    else{
        
        [self.btnNearBy setImage:[UIImage imageNamed:@"Signal_I"] forState:UIControlStateNormal];
        [self.imgViewBattery setImage:[UIImage imageNamed:@"Battery_I"]];
        self.btnNearBy.enabled = false;
        self.btnNotification.enabled = false;
    }
}

@end