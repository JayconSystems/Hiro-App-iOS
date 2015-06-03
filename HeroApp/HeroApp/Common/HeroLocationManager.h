//
//  HeroLocationManager.h
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define LOCATION_MONITORED @"LOCATION_MONITORED"
@interface HeroLocationManager : NSObject<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (nonatomic,retain)CLLocationManager *locationManager;
@property (nonatomic,retain)CLLocation *currentLocation;
//@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property(nonatomic) BOOL ISLOCATIONMANAGERCONFIGURED;

+(id)sharedInstance;
- (void) _stopUpdatingLocation;
- (void) _startUpdatingLocation;
- (void)getCurrentLocation;
- (void)stopMonitoringForBeacons;
@end
