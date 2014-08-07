//
//  MMViewController.m
//  Assessment3_ObjectiveC
//
//  Created by Kevin McQuown on 8/5/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MMViewController.h"
#import "MMDivvyStation.h"
#import "MMMapViewController.h"

#define urlToRetrieveDivvyData @"http://www.divvybikes.com/stations/json/"

@interface MMViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property NSMutableArray *stationList;
@property NSMutableArray *filteredStationList;

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@property BOOL isSearching;

@end

@implementation MMViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.isSearching) {
		return [self.filteredStationList count];
	}
    return [self.stationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"divvyCell"];

	MMDivvyStation *station;
	if (self.isSearching) {
		station = self.filteredStationList[indexPath.row];
	}
	else {
		station = self.stationList[indexPath.row];
	}

	cell.textLabel.text = station.dictionary[@"stAddress1"];
	cell.detailTextLabel.text = [station.dictionary[@"availableBikes"] stringValue];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.myTableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // probably need to do something here to send data to the map view controller
	MMMapViewController *mapVC = (MMMapViewController *)segue.destinationViewController;
	NSIndexPath *selectedIndexPath = [self.myTableView indexPathForSelectedRow];
	mapVC.station = self.stationList[selectedIndexPath.row];
	mapVC.currentLocation = self.currentLocation;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Divvy Bike Locator";
	self.stationList = [NSMutableArray array];
	self.filteredStationList = [NSMutableArray array];

	self.locationManager = [CLLocationManager new];
	self.locationManager.delegate = self;

	[self.locationManager startUpdatingLocation];
	[self loadDivvyBikeJSON];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDivvyBikeJSON
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlToRetrieveDivvyData]];
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
							   if (!connectionError) {

								   NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

								   for (NSDictionary *dictionary in decodedJSON[@"stationBeanList"]) {
									   MMDivvyStation *station = [[MMDivvyStation alloc] initWithDictionary:dictionary];
									   [self.stationList addObject:station];
								   }

								   [self.stationList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
									   MMDivvyStation *station1 = (MMDivvyStation *)obj1;
									   MMDivvyStation *station2 = (MMDivvyStation *)obj2;

									   CLLocation *location1 = [[CLLocation alloc] initWithLatitude:[station1.dictionary[@"latitude"] doubleValue]
																						  longitude:[station1.dictionary[@"longitude"] doubleValue]];
									   CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[station2.dictionary[@"latitude"] doubleValue]
																						  longitude:[station2.dictionary[@"longitude"] doubleValue]];

									   NSNumber *distance1 = [NSNumber numberWithDouble:[self.currentLocation distanceFromLocation:location1]];
									   NSNumber *distance2 = [NSNumber numberWithDouble:[self.currentLocation distanceFromLocation:location2]];
									   return [distance1 compare:distance2];
								   }];

								   [self.myTableView reloadData];
							   } else {
								   NSLog(@"Error loading json : %@", [connectionError localizedDescription]);
							   }
						   }];
}

- (void)searchTableList
{
	NSString *searchString = self.searchBar.text;
	for (MMDivvyStation *station in self.stationList) {
		if (!([station.dictionary[@"stAddress1"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location == NSNotFound)) {
			[self.filteredStationList addObject:station];
		}
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	for (CLLocation *location in locations) {
		[self.locationManager stopUpdatingLocation];
		self.currentLocation = location;
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"location error %@", [error localizedDescription]);
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self searchTableList];
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    //Remove all objects first.
    [self.filteredStationList removeAllObjects];

    if([searchText length] != 0) {
        self.isSearching = YES;
        [self searchTableList];
    }
    else {
        self.isSearching = NO;
    }
     [self.myTableView reloadData];
}


@end
