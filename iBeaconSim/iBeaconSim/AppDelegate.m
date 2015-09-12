//
//  AppDelegate.m
//  iBeaconSim
//
//  Created by Tom Jay on 9/12/15.
//  Copyright (c) 2015 Tom Jay. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define BEACON_UUID @"4F52D93B-18DA-4E81-B512-1FBF5ED4626F"
#define BEACON_MAJOR 0x1000
#define BEACON_MINOR 0x0001


@interface AppDelegate () <CBPeripheralManagerDelegate> {
    BOOL started;
    BOOL advertising;
}

@property (strong, nonatomic) CLBeaconRegion *primaryBeaconRegion;
@property (strong, nonatomic) NSDictionary *primaryBeaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@end





@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // Initialize the Beacon Region
    self.primaryBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACON_UUID]
                                                                  major:BEACON_MAJOR
                                                                  minor:BEACON_MINOR
                                                             identifier:@"com.tomjay.primaryBeaconRegion"];
    // Get the beacon data to advertise
    self.primaryBeaconData = [self.primaryBeaconRegion peripheralDataWithMeasuredPower:nil];
    
    // Start the peripheral manager
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];

    return YES;
}

-(void) startAdvertising {
    
    started = YES;
    
    // Start broadcasting
    [self.peripheralManager startAdvertising:self.primaryBeaconData];
    
    advertising = YES;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iBeacon Live" message:[NSString stringWithFormat:@"Advertising %@ %d %d", BEACON_UUID, BEACON_MAJOR, BEACON_MINOR] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    return;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self.peripheralManager stopAdvertising];
    
    advertising = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if (started) {
        
        if (!advertising) {
            [self performSelector:@selector(startAdvertising) withObject:nil afterDelay:1.0];

        }
        
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma CBPeripheralManagerDelegate methods

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported Device" message:@"You can not Broadcast with this device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
        
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        
        [self performSelector:@selector(startAdvertising) withObject:nil afterDelay:2.0];
        
        return;
    }
    
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        // Bluetooth isn't on.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Not Powered On" message:@"Make sure the device BLE is powered on" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
}


@end
