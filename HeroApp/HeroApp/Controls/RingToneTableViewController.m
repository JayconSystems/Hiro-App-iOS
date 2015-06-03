//
//  RingToneTableViewController.m
//  HiroApp
//
//  Created by -Jaycon Systems on 19/01/15.
//  Copyright (c) 2015 Jaycon Systems. All rights reserved.
//

#import "RingToneTableViewController.h"

@interface RingToneTableViewController (){
    NSArray *arrOfSounds;
}

@end

@implementation RingToneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     arrOfSounds = [NSArray arrayWithObjects:@"HiroTone1",@"HiroTone2",@"HiroTone3",@"HiroTone4", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger value;
    if (self.seletedValue == 1) {
        value = self.actor.state[SOUND_PHONE_SOUND_ALERT] ? [arrOfSounds indexOfObject:self.actor.state[SOUND_PHONE_SOUND_ALERT]] :  [arrOfSounds indexOfObject:@"HiroTone2"];
    }else{
        value = (ReadValue(SOUND_FIND_PHONE_THUR_HIRO)) ? [arrOfSounds indexOfObject:ReadValue(SOUND_FIND_PHONE_THUR_HIRO)] :  [arrOfSounds indexOfObject:@"HiroTone1"];
    }
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:value inSection:0];
    [self.tableView cellForRowAtIndexPath:indexpath].accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrOfSounds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ringtonecell" forIndexPath:indexPath];
    cell.textLabel.text = arrOfSounds[indexPath.row];
//    if (self.seletedValue == 1) {
//        if ([self.actor.state[SOUND_PHONE_SOUND_ALERT] isEqualToString:arrOfSounds[indexPath.row]]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }else{
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    }else{
//        if ([self.actor.state[SOUND_FIND_PHONE_THUR_HIRO] isEqualToString:arrOfSounds[indexPath.row]]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    playSound(indexPath.row);
    soundAlert(arrOfSounds[indexPath.row]);
    if (self.seletedValue == 1) {
        self.actor.state[SOUND_PHONE_SOUND_ALERT] = arrOfSounds[indexPath.row];
    }else{
        StoreValue(SOUND_FIND_PHONE_THUR_HIRO, arrOfSounds[indexPath.row]);
    }

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


@end
