//
//  MMMapViewController.h
//  Assessment3_ObjectiveC
//
//  Created by Kevin McQuown on 8/5/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDivvyStation.h"

@interface MMMapViewController : UIViewController

@property (nonatomic, strong) MMDivvyStation *station;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
