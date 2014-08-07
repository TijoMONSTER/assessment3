//
//  MMMapViewController.m
//  Assessment3_ObjectiveC
//
//  Created by Kevin McQuown on 8/5/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MMMapViewController.h"
#import <MapKit/MapKit.h>

@interface MMMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *myMapView;
@property (nonatomic, strong) MKPointAnnotation *currentLocationAnnotation;

@end

@implementation MMMapViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self.myMapView removeAnnotations:self.myMapView.annotations];

	MKPointAnnotation *annotation = [MKPointAnnotation new];
	annotation.coordinate = CLLocationCoordinate2DMake([self.station.dictionary[@"latitude"] doubleValue], [self.station.dictionary[@"longitude"] doubleValue]);
	annotation.title = self.station.dictionary[@"stAddress1"];

	[self.myMapView addAnnotation:annotation];

	self.currentLocationAnnotation = [MKPointAnnotation new];
	self.currentLocationAnnotation.coordinate = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
	[self.myMapView addAnnotation:annotation];

	// zoom in
	CLLocationCoordinate2D centerCoordinate = annotation.coordinate;
	MKCoordinateSpan coordinateSpan;
	coordinateSpan.latitudeDelta = 0.05;
	coordinateSpan.longitudeDelta = 0.05;
	MKCoordinateRegion region;
	region.center = centerCoordinate;
	region.span = coordinateSpan;

	[self.myMapView setRegion:region animated:YES];
}

- (void)getDirectionsTo:(MKMapItem *)mapItem
{
	MKDirectionsRequest *request = [MKDirectionsRequest new];
	request.source = [MKMapItem mapItemForCurrentLocation];
	request.destination = mapItem;

	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		MKRoute *route = [response.routes firstObject];
		int stepNumber = 1;
		NSMutableString *directionsString = [NSMutableString string];

		for (MKRouteStep *step in route.steps) {
			NSLog(@"%@", step.instructions);
			[directionsString appendFormat:@"%d: %@\n", stepNumber, step.instructions];
			stepNumber++;
		}

		UIAlertView *alertView = [UIAlertView new];
		alertView.title = @"Directions";
		alertView.message = directionsString;
		[alertView addButtonWithTitle:@"OK"];
		[alertView show];
	}];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
	if ([annotation isEqual:self.currentLocation]) {
		pin.image = [UIImage imageNamed:@"currentLocation"];
	} else {
		pin.canShowCallout = YES;
		pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		pin.image = [UIImage imageNamed:@"divvy"];
	}

	return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude) addressDictionary:nil];
	MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
	[self getDirectionsTo:mapItem];
}

@end
