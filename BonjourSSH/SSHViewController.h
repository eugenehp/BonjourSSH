//
//  SSHViewController.h
//  BonjourSSH
//
//  Created by Eugene on 3/27/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSHViewController : UIViewController <UITextViewDelegate>

@property(nonatomic, retain) NSString* serviceName;

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) IBOutlet UITextView *textView;

- (IBAction)disconnect:(id)sender;

@end
