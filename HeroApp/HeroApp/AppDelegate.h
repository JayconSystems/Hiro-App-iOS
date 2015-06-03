//
//  AppDelegate.h
//  HiroApp
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeroActor.h"
#import "ProximityActor.h"
#import "AppUtils.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CentralManagerActor *centralManagerActor;
@property (strong, nonatomic) NSMutableArray *deviceActors;
@property (strong,nonatomic) NSMutableDictionary *accountInformation;
@property (nonatomic,strong) NSTimer *connectionTimer;
@property (strong,nonatomic) NSString *deviceLogicalName;
@property (strong,nonatomic) ProximityActor *rssiActor;
@property (strong,nonatomic) NSMutableArray *wifiSafeZones;


-(void)storeDevicesState;
- (void)reconnectDevices;
@end


