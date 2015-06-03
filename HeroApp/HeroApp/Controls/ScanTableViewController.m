//
//  ScanTableViewController.m
//  HiroApp
//
//  Created by Jaycon Systems on 07/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "ScanTableViewController.h"

@interface ScanTableViewController ()

@end

@implementation ScanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Add new device";
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_OPENSANS_LIGHT size:18.0f],NSForegroundColorAttributeName : [UIColor whiteColor]}];

    RegisterForNotes(@[@"ScanResultPeripheralFound",@"DeviceIsReady"], self);
    self.peripherals = [NSMutableArray array];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:37/255.0 green:143/255.0 blue:223/255.0 alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(startScanning)
                  forControlEvents:UIControlEventValueChanged];
    [self startScanning];
    

}

- (void)deviceIsReady:(NSNotification *)note{
    
    HeroActor *actor = note.object;
    if(actor.peripheralActor.peripheral == self.selectedPeripheral){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (void)scanResultPeripheralFound:(NSNotification *)note{
    CBPeripheral *peripheral = note.object;
    DLog(@"---------------------------------");
    DLog(@"scanResultPeripheralFound: %@ ", peripheral.name);
    DLog(@"=================================");
    NSUInteger idx = [self.peripherals indexOfObject:peripheral];
    if (NSNotFound == idx) {
        [self.peripherals addObject:peripheral];
        [self.tableView reloadData];
    }
}

- (void)scanTimerExceed{
    
    [self.scanTimer invalidate];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to scan again." attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    [self.refreshControl endRefreshing];
    if ([self.peripherals count] == 0) {
        ShowAlert(@"Sorry!", @"No near by Hiros, Please make sure you put Hiro in pairing mode. Press Scan button to scan again.");
    }
    self.btnScan.title = @"Scan";
    [AppDelegate_.centralManagerActor.centralManager stopScan];
}

- (void) startScanning{
    if(AppDelegate_.centralManagerActor.centralManager.state == CBCentralManagerStatePoweredOn){
        [AppDelegate_.centralManagerActor retrievePeripherals];
        self.btnScan.title = @"Stop";
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Scanning Near by Hiros" attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl beginRefreshing];
        
        if(self.scanTimer){
            [self.scanTimer invalidate];
            self.scanTimer = nil;
        }
        
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(scanTimerExceed) userInfo:nil repeats:NO];
    }
    else{
        self.btnScan.title = @"Scan";
        ShowAlert(@"Turn on Bluetooth", @"Please turn on Bluetooth from Setting->Bluetooth");
        [self.refreshControl endRefreshing];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.peripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scanCell" forIndexPath:indexPath];
    
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = @"Tap to Pair";//[peripheral.identifier UUIDString];
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self scanTimerExceed];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @"Pairing with device";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Give your Hiro a name" message:@"Enter Name Here" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alert.delegate = self;
    alert.tag = indexPath.row;
    [alert show];

}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save"]) {
        UITextField *txtLogicalName = [alertView textFieldAtIndex:0];
        if(txtLogicalName.text.length!=0){
            AppDelegate_.deviceLogicalName = txtLogicalName.text;
        }
        else{
            AppDelegate_.deviceLogicalName = @"My Hero";
        }
        self.selectedPeripheral = self.peripherals[alertView.tag];
        [AppDelegate_.centralManagerActor addPeripheral:self.peripherals[alertView.tag]];
    }
}

- (IBAction)actionScan:(id)sender {
    UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
    
    if([barButton.title isEqualToString:@"Stop"]){
        [self scanTimerExceed];
    }
    else{
        [self startScanning];
    }
}

- (IBAction)actionCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
