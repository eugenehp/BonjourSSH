//
//  BonjourViewController.h
//  BonjourSSH
//
//  Created by Eugene on 3/26/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import <UIKit/UIKit.h>

// root/1234567890 port 44

@interface ServiceViewController : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, retain) NSString* serviceName;
@property(nonatomic, retain) NSArray* addresses;

@end
