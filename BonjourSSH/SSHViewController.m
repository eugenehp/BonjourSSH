//
//  SSHViewController.m
//  BonjourSSH
//
//  Created by Eugene on 3/27/14.
//  Copyright (c) 2014 www.eugenehp.tk. All rights reserved.
//

#import "SSHViewController.h"
#import <NMSSH/NMSSH.h>

@interface SSHViewController ()<NMSSHSessionDelegate, NMSSHChannelDelegate>

@property (nonatomic, strong) dispatch_queue_t sshQueue;
@property (nonatomic, strong) NMSSHSession *session;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableString *lastCommand;

@end

@implementation SSHViewController

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
    // Do any additional setup after loading the view.
    [self setTitle:self.serviceName];
    
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.lastCommand = [[NSMutableString alloc] init];
    
    self.sshQueue = dispatch_queue_create("NMSSH.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    dispatch_once(&_onceToken, ^{
        dispatch_async(self.sshQueue, ^{
            self.session = [NMSSHSession connectToHost:self.host withUsername:self.username];
            self.session.delegate = self;
            
            if (!self.session.connected) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToTextView:@"Connection error"];
                });
                
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendToTextView:[NSString stringWithFormat:@"ssh %@@%@\n", self.session.username, self.host]];
            });
            
            if (self.password.length>0) {
                [self.session authenticateByPassword:self.password];
            }
            else {
                [self.session authenticateByKeyboardInteractive];
            }
            
            if (!self.session.authorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToTextView:@"Authentication error"];
                    self.textView.editable = NO;
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.textView.editable = YES;
                });
                
                self.session.channel.delegate = self;
                self.session.channel.requestPty = YES;
                self.session.channel.ptyTerminalType = NMSSHChannelPtyTerminalVT100;
                
                NSError *error;
                [self.session.channel startShell:&error];
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self appendToTextView:error.localizedDescription];
                        self.textView.editable = NO;
                    });
                }
            }
        });
    });
}

- (IBAction)disconnect:(id)sender {
    dispatch_async(self.sshQueue, ^{
        [self.session disconnect];
    });
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)appendToTextView:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, text];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length] - 1, 1)];
}

- (void)performCommand {
    if (self.semaphore) {
        self.password = [self.lastCommand substringToIndex:MAX(0, self.lastCommand.length - 1)];
        dispatch_semaphore_signal(self.semaphore);
    }
    else {
        NSString *command = [self.lastCommand copy];
        dispatch_async(self.sshQueue, ^{
            [[self.session channel] write:command error:nil timeout:@10];
        });
    }
    
    [self.lastCommand setString:@""];
}

- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:message];
    });
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:error];
    });
}

- (void)channelShellDidClose:(NMSSHChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:@"\nShell closed\n"];
        self.textView.editable = NO;
    });
}

- (NSString *)session:(NMSSHSession *)session keyboardInteractiveRequest:(NSString *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:request];
        self.textView.editable = YES;
    });
    
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.semaphore = nil;
    
    return self.password;
}

- (void)session:(NMSSHSession *)session didDisconnectWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:[NSString stringWithFormat:@"\nDisconnected with error: %@", error.localizedDescription]];
        
        self.textView.editable = NO;
    });
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange([textView.text length] - 1, 1)];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (textView.selectedRange.location < textView.text.length - self.lastCommand.length - 1) {
        textView.selectedRange = NSMakeRange([textView.text length], 0);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length == 0) {
        
        if ([self.lastCommand length] > 0) {
            [self.lastCommand replaceCharactersInRange:NSMakeRange(self.lastCommand.length-1, 1) withString:@""];
            return YES;
        }
        else {
            return NO;
        }
    }
    
    [self.lastCommand appendString:text];
    
    if ([text isEqualToString:@"\n"]) {
        [self performCommand];
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
	CGRect ownFrame = [[[[UIApplication sharedApplication] delegate] window] convertRect:self.textView.frame fromView:self.textView.superview];
    
	CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
	coveredFrame = [[[[UIApplication sharedApplication] delegate] window] convertRect:coveredFrame toView:self.textView.superview];
    
	self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top, 0, coveredFrame.size.height, 0);
	self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
	self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top, 0, 0, 0);
	self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

@end
