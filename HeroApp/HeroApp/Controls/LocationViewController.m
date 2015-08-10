//
//  LocationViewController.m
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "LocationViewController.h"
#import "JPSThumbnailAnnotation.h"
#import <QuartzCore/QuartzCore.h>

@interface MyCustomAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;


// Other methods and properties.
@end

@interface LocationViewController ()

@end

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Hiro's name in location screen
    self.title = self.actor.state[kDeviceName];
    self.mapView.layer.cornerRadius = 3.0f;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.camera.altitude *= 1.4;
    self.mapView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mapView.layer.shadowOpacity = 0.8;
    self.mapView.layer.shadowRadius = 3;
    self.mapView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.mapView.layer.masksToBounds = NO;
    [self.mapView addAnnotations:[self annotations]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self zoomMapViewToFitAnnotations:self.mapView animated:animated];
    //or maybe you would do the call above in the code path that sets the annotations array
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark for Addpin to mapview
- (NSArray *)annotations {
    
    JPSThumbnail *apple = [[JPSThumbnail alloc] init];
    
    if (self.actor.state[@"profilePic"]) {
        apple.image = getProfileImageFromDocumentDirectory(self.actor.state[@"profilePic"]);
    }
    else{
        apple.image = [UIImage imageNamed:@"plus"];
    }
    
    apple.title = self.actor.state[kDeviceName];
    apple.subtitle = @"Last Location";
    
    
    
    apple.coordinate = CLLocationCoordinate2DMake([self.actor.state[kHeroLastLocation][0]floatValue],[self.actor.state[kHeroLastLocation][1]floatValue]);
    
//    apple.disclosureBlock = ^{
//        DLog(@"selected Keys");
//        UIImage *image = [LocationViewController imageWithView:self.mapView];
//    };
    
    return @[[JPSThumbnailAnnotation annotationWithThumbnail:apple]];
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}


@end
