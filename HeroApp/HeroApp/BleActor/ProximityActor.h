//
//  ProximityActor.h
//  Hero
//
//  Created by Jaycon Systems on 04/02/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "Actor.h"
#import "NSArray+Statistics.h"

@interface ProximityActor : Actor{
   
}
- (void)startRSSITimer:(HeroActor *)actor;
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error;
@end
