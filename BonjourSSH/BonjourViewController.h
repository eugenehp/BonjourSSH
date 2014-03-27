//
//  BonjourViewController.h
//  BonjourSSH
//
//  Created by Eugene on 3/26/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BonjourViewController : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
