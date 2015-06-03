
//
//  HeroLocationManager
//  Hero
//
//  Created by Jaycon Systems on 24/12/14.
//  Copyright (c) 2014 Jaycon Systems. All rights reserved.
//

#import "HeroLocationManager.h"
#import "AppDelegate.h"


static HeroLocationManager *sharedInst = nil;
@implementation HeroLocationManager
@synthesize locationManager;
@synthesize currentLocation;
@synthesize ISLOCATIONMANAGERCONFIGURED;


typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

+(id)sharedInstance
{
    
    if ( sharedInst == nil ) {
        /* sharedInst set up in init */
        
        DLog(@"Shared Instance Created");
        sharedInst = [[self alloc] init];
        
    }
    
    return sharedInst;
}
-(id)init{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager setDelegate:(id)self];
    
    if ([self.locationManager respondsToSelector:
         @selector(requestAlwaysAuthorization)]) {
        [self.locationManager   requestAlwaysAuthorization];
    }
    return self;
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations.lastObject;
    NSLog(@"didUpdateLocations newLocation = %@", newLocation);
    self.currentLocation = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:{
                ISLOCATIONMANAGERCONFIGURED = FALSE;
                
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You have denied permission to identify the current location of your device.\n To enable Location Services for Hiro go to iOS Settings: Privacy->Location Services->Hiro." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
            }
                break;
                
            case kCLErrorLocationUnknown:
                 ISLOCATIONMANAGERCONFIGURED = FALSE;
                break;
            default:
                break;
        }
    } else {
        // We handle all non-CoreLocation errors here
    }
}
- (void)getCurrentLocation{
    if([CLLocationManager locationServicesEnabled] == NO){
        self.ISLOCATIONMANAGERCONFIGURED = FALSE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning:Location Services Disabled" message:@"Enable Location services from iOS Settings: Privacy -> Location Services -> On." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    self.ISLOCATIONMANAGERCONFIGURED = TRUE;
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    
    self.currentLocation = nil;
    if(self.ISLOCATIONMANAGERCONFIGURED)
    [self performSelectorInBackground:@selector(setLocationInBackground) withObject:nil];
    
}
-(void)setLocationInBackground{
    BOOL ISCURRENTLOCATION = false;
    while (!ISCURRENTLOCATION) {
        if(!self.ISLOCATIONMANAGERCONFIGURED){
            ISCURRENTLOCATION = TRUE;
            return;
        }
        
        if(self.currentLocation!=nil){
            ISCURRENTLOCATION = TRUE;
            [NSThread sleepForTimeInterval:2];
            [self.locationManager stopUpdatingLocation];
        }
    }
    
    
}

/**
 * Stops updating the location in realtime.
 * Starts the significantLocationChange service instead.
 * Called when the application is about to be put
 * in the background so the user's battery isn't 
 * killed.
 */
- (void) _stopUpdatingLocation
{
    DLog(@"_stopUpdatingLocation");
    
    [[self locationManager] stopUpdatingLocation];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        
        [self.locationManager startMonitoringSignificantLocationChanges];
    }  
}


/**
 * Starts updating the location in realtime,
 * Stops the background monitoring.
 * Called when the application is brought back
 * into foreground
 */
- (void) _startUpdatingLocation
{
    
    DLog(@"_startUpdatingLocation");
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        
        [[self locationManager] stopMonitoringSignificantLocationChanges];
    }
    
    // note that we can make this call even if it's already updating no problem
    [[self locationManager] startUpdatingLocation];
}



#pragma mark - Beacon advertising



- (void)startAdvertisingBeacon
{
    NSLog(@"Turning on advertising...");
    
}

- (void)startMonitoringForBeacons
{
    [self turnOnMonitoring];
}

- (void)turnOnMonitoring
{
    NSLog(@"Turning on monitoring...");
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"Couldn't turn on region monitoring: Region monitoring is not available for CLBeaconRegion class.");
        return;
    }
    
    NSLog(@"Monitoring turned on for region: %@.", self.beaconRegion);
}
- (void)stopMonitoringForBeacons
{
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"Turned off monitoring");
}

#pragma mark - Beacon ranging
- (void)changeRangingState:(BOOL)shouldStart
{
    if (shouldStart) {
        [self startRangingForBeacons];
    } else {
        [self stopRangingForBeacons];
    }
}

- (void)startRangingForBeacons
{
    self.detectedBeacons = [NSArray array];
    [self turnOnRanging];
}

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
}

- (void)stopRangingForBeacons
{
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    self.detectedBeacons = [NSArray array];
    NSLog(@"Turned off ranging.");
}

//#pragma mark - Beacon advertising delegate methods
//- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
//{
//    if (error) {
//        NSLog(@"Couldn't turn on advertising: %@", error);
//        return;
//    }
//    
//    if (peripheralManager.isAdvertising) {
//        NSLog(@"Turned on advertising.");
//    }
//}
//
//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
//{
//    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
//        NSLog(@"Peripheral manager is off.");
//        return;
//    }
//    
//    NSLog(@"Peripheral manager is on.");
//    [self changeAdvertisingState];
//}

#pragma mark - Location manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
       
            NSLog(@"Couldn't turn on monitoring: Location services are not enabled.");
    }
    
    
    
}


- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
   
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region: %@", region);
    
    //[self sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stateString = nil;
    switch (state) {
        case CLRegionStateInside:
            stateString = @"inside";
            break;
        case CLRegionStateOutside:
            stateString = @"outside";
            break;
        case CLRegionStateUnknown:
            stateString = @"unknown";
            break;
    }
    NSLog(@"State changed to %@ for region %@.", stateString, region);
}


@end
