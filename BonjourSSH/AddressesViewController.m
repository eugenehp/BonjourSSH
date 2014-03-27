//
//  AddressesViewController.m
//  BonjourSSH
//
//  Created by Eugene on 3/26/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import "AddressesViewController.h"

@interface AddressesViewController ()

@end

@implementation AddressesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:self.serviceName];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark UITableViewDataSourceDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self.addresses count];
    if (count == 0) {
        return 1;
    } else {
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    int count = [self.addresses count];
    NSString* displayString;
    
    if (count == 0) {
        displayString = @"Searching...";
    } else {
        displayString = [self.addresses objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = displayString;
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int count = [self.addresses count];
    if (count != 0) {
        NSString* currentHostandPort = [self.addresses objectAtIndex:indexPath.row];
        
        UIAlertView *confirmSSH = [[UIAlertView alloc]initWithTitle:@"Do you want to connect to:"
                                                            message:currentHostandPort
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Connect by SSH", nil];
        
        [confirmSSH show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button: %i, was pressed.", buttonIndex);
}


@end
