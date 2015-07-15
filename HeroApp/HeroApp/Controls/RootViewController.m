//
//  RootViewController.m
//  HiroApp
//
//  Created by -Jaycon Systems on 05/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "RootViewController.h"
#import "LocationViewController.h"
#import "SettingViewController.h"


@interface RootViewController ()
{
    
}

@end

@implementation RootViewController

static NSInteger selectedIndexValue;;

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndexValue = 0;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_OPENSANS_LIGHT size:18.0f]}];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:197/255.0 green:197/255.0 blue:197/255.0 alpha:1.0];
    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 256, 0);
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-Light" size:18],
      NSFontAttributeName, nil]];
    RegisterForNotes(@[@"DeviceIsReady"], self);

    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)deviceIsReady:(NSNotification *)note{
    
    HeroActor *actor = note.object;
    [actor readProperty:kBatteryLevel];
    
    
    if(actor.isConnected){
        
        int linkLossLevel;
        if([actor.state[kHeroAlertIsEnable] boolValue]){
            if([actor.state[kHeroAlertVolume] isEqualToString:kHeroBeepVolumeMild]){
                linkLossLevel = 1;
            }
            else{
                linkLossLevel = 2;
            }
        }
        else{
            linkLossLevel = 0;
        }
        
        [actor performCommand:kCommandUpdateLinkLoss withParams:[@{kCharacteristicLinkLossLevel:[NSNumber numberWithInt:linkLossLevel]}mutableCopy]];
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueLocation"]) {
        LocationViewController *location = segue.destinationViewController;
        location.actor = AppDelegate_.deviceActors[selectedIndexValue];
    }
    else if([segue.identifier isEqualToString:@"segueSetting"]){
        SettingViewController *settings = segue.destinationViewController;
        settings.actor = AppDelegate_.deviceActors[selectedIndexValue];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AppDelegate_.deviceActors.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HeroCell";
    HeroActor *actor;

    actor = AppDelegate_.deviceActors[indexPath.row];
    
    HeroCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [cell initializeCell:actor];
    
    cell.txtFieldName.text =  actor.state[kDeviceName];
    cell.txtFieldName.delegate = (id)self;
    cell.txtFieldName.tag = indexPath.row;
    cell.btnNotification.tag = indexPath.row;
    if (actor.state[@"profilePic"]) {
        cell.imgHeroPic.image = getProfileImageFromDocumentDirectory(actor.state[@"profilePic"]);
    }
    else{
        cell.imgHeroPic.image = [UIImage imageNamed:@"plus"];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImagePick:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    cell.viewBase.layer.cornerRadius = 3;
    cell.imgHeroPic.tag = indexPath.row;
    [cell.imgHeroPic addGestureRecognizer:tap];
    cell.imgHeroPic.userInteractionEnabled = true;
    
    cell.imgViewBattery.tag = indexPath.row;
    cell.btnLocation.tag = indexPath.row;
    cell.btnNearBy.tag = indexPath.row;
    cell.btnNotification.tag = indexPath.row;
    cell.btnSetting.tag = indexPath.row;
    [cell.btnLocation addTarget:self action:@selector(actionLocation:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnNearBy addTarget:self action:@selector(actionNearBy:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnSetting addTarget:self action:@selector(actionSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)actionBattery:(UIButton  *)sender;
{
    selectedIndexValue = sender.tag;
}

-(void)actionLocation:(UIButton  *)sender;
{
    selectedIndexValue = sender.tag;
    [self performSegueWithIdentifier:@"segueLocation" sender:self];
}

-(void)actionNearBy:(UIButton  *)sender;
{
    selectedIndexValue = sender.tag;
}

-(void)actionSettings:(UIButton  *)sender;
{
    selectedIndexValue = sender.tag;
    [self performSegueWithIdentifier:@"segueSetting" sender:self];
}

- (IBAction)actionAddDevice:(id)sender
{
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navScan"];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)ImagePick:(UITapGestureRecognizer *)gesture
{
    DLog(@"Gesture %@",gesture);
    selectedIndexValue = [(UIGestureRecognizer *)gesture view].tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Profile picture from" delegate:(id)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Gallery" otherButtonTitles:@"Camera", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 1 || buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        [picker setEditing:YES];
        picker.sourceType =  buttonIndex == 1 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    
        
    }else{
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    HeroActor *actor = AppDelegate_.deviceActors[textField.tag];
    if([textField.text length]!=0){
        actor.state[kDeviceName] = textField.text;
    }
    [textField resignFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    ((HeroActor *)AppDelegate_.deviceActors[selectedIndexValue]).state[@"profilePic"] = saveImageToDocumentDirectory(chosenImage);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}




@end
