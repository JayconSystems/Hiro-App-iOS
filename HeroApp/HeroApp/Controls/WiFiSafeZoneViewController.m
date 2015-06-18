//
//  WiFiSafeZoneViewController.m
//  Hiro
//
//  Created by Jaycon Systems on 16/03/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "WiFiSafeZoneViewController.h"

@interface WiFiSafeZoneViewController ()

@end

@implementation WiFiSafeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Wi-Fi Safe Zones";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_OPENSANS_LIGHT size:18.0f]}];
    self.navigationController.navigationBar.translucent = NO;
    
    self.viewContainer.layer.cornerRadius = 3.0f;
    
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    [reach startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    
    
}

- (void)appDidBecomeActive:(NSNotification *)note {
    [self checkIfNetworkConnected];
}
- (void)reachabilityChanged:(NSNotification *)note {
    
    [self checkIfNetworkConnected];

}
- (void)viewWillAppear:(BOOL)animated{
    [self checkIfNetworkConnected];
}

- (void)checkIfNetworkConnected{
    if(currentWifiSSID()){
        self.btnAdd.hidden = false;
        self.lblConnectedWiFi.text = currentWifiSSID();
        self.imgStrengh.hidden = false;
    }
    else{
        self.btnAdd.hidden = true;
        self.lblConnectedWiFi.text = @"No Wi-Fi Connected";
        self.imgStrengh.hidden = true;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AppDelegate_.wifiSafeZones.count;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"wificell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = AppDelegate_.wifiSafeZones[indexPath.row];
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [AppDelegate_.wifiSafeZones removeObjectAtIndex:indexPath.row];
        StoreValue(kHiroWiFiSafeZones, AppDelegate_.wifiSafeZones);
        [self.tableView reloadData];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionAdd:(id)sender {
    
    if([AppDelegate_.wifiSafeZones containsObject:self.lblConnectedWiFi.text]){
        ShowAlert(@"Already Added", @"This Wi-Fi Safe Zone is already added");
        return;
    }
    [AppDelegate_.wifiSafeZones addObject:self.lblConnectedWiFi.text];
    StoreValue(kHiroWiFiSafeZones, AppDelegate_.wifiSafeZones);
    [self.tableView reloadData];
    
}
@end
