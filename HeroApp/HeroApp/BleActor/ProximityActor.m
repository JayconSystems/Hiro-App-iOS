//
//  ProximityActor.m
//  Hero
//
//  Created by Jaycon Systems on 04/02/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "ProximityActor.h"

@implementation ProximityActor
- (void)startRSSITimer:(HeroActor *)actor{
    
    [self onWorkerThreadDoBlock:^{
        actor.RSSITimer = [NSTimer timerWithTimeInterval:1.2 target:actor.peripheralActor.peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:actor.RSSITimer forMode:NSRunLoopCommonModes];
    }];
    
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    
    [self onWorkerThreadDoBlock:^{
        HeroActor *deviceActor = [AppDelegate_.deviceActors find:^BOOL(HeroActor *a) {
            return [a isActorForPeripheral:peripheral];
        }];
        if(deviceActor.rssiCounter!=0){
            deviceActor.rssiCounter--;
            if (error) {
                //DLog(@"error: %@", error);
                
                if (peripheral.state == CBPeripheralStateConnected && (error.code == CBErrorOperationCancelled || error.code == CBErrorUnknown)) {
                    [deviceActor.rssiReading addObject:peripheral.RSSI];
                   
                }
                
            }
            else
                [deviceActor.rssiReading addObject:peripheral.RSSI];
            deviceActor.averageRSSI = peripheral.RSSI;
        }
        else{
           
            NSMutableArray *sortedArray = [[deviceActor.rssiReading sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber * obj2) {
                return [obj1 compare:obj2];
            }] mutableCopy];
            
            int highestRecordCount = ([sortedArray count]*10)/100;
            int lowestRecordCount = ([sortedArray count]*20)/100;
            
            for(int i=0;i<highestRecordCount;i++){
                [sortedArray removeObjectAtIndex:0];
            }
            for(int i=0;i<lowestRecordCount;i++){
                [sortedArray removeLastObject];
            }
           
            [deviceActor.rssiReading removeAllObjects];
            deviceActor.averageRSSI = [sortedArray standardDeviation];
            deviceActor.rssiCounter = RSSIReadindCount;
            DLog(@"Average RSSI %d",[deviceActor.averageRSSI intValue]);
           
        }
    }];
    
    
    
}


@end
