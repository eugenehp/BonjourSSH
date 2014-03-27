//
//  AddressesViewController.h
//  BonjourSSH
//
//  Created by Eugene on 3/26/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, retain) NSString* serviceName;
@property(nonatomic, retain) NSArray* addresses;
@property(nonatomic, retain) NSString* hostAndPort;

@property(nonatomic, retain) NSString* username;
@property(nonatomic, retain) NSString* password;

@end
