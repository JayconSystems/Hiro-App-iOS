//
//  LocationViewController.h
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>


@interface LocationViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) HeroActor *actor;


@end
