//
//  WSViewController.m
//  sdk-ios-tutorial
//
//  Created by Antoine Jackson on 23/06/14.
//  Copyright (c) 2014 OAuth.io. All rights reserved.
//

#import "WSViewController.h"

@interface WSViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *login_switch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *call_button;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cache_button;
@property (strong, nonatomic) IBOutlet UILabel *name_label;
@property (strong, nonatomic) IBOutlet UILabel *email_label;
@property (strong, nonatomic) IBOutlet UIView *state_view;
@property (strong, nonatomic) IBOutlet UILabel *state_label;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *state_spinner;
@property (strong, nonatomic) IBOutlet UILabel *login_state_label;

@property NSDictionary *config;


@property OAuthIOModal *oauthio_modal;
@property OAuthIORequest *request_object;

@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    _config = [[NSDictionary alloc] initWithContentsOfFile:path];
    _login_state_label.text = @"Not connected";
    
    _oauthio_modal = [[OAuthIOModal alloc] initWithKey:[_config objectForKey:@"app_key"] delegate:self];
}

-(void) viewDidAppear:(BOOL)animated
{
    //Replace this placeholder with code to log the user right away
    //if his session is cached
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) authenticate
{
    _state_label.text = @"Logging in via Facebook";
    [_state_view setHidden:NO];
    
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    //This prevents the webview from keeping cookies and store the session
    [options setObject:@"true" forKey:@"clear-popup-cache"];
    
    //This launches the popup in a webview above the current view
    [_oauthio_modal showWithProvider:@"facebook" options:options];
}

-(void) makeAPICall
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _state_label.text = @"Fetching your info";
    [_state_view setHidden:NO];
    
    
    //Replace this placeholder with the request code
}

-(void) logout
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
    
    _request_object = nil;
}

-(void) clearCache
{
    //Replace this placeholder with code to clear the cache
}

-(IBAction)buttonPressed:(id)sender
{
    if (sender == _login_switch)
    {
        if ([_login_switch isOn])
        {
            [self authenticate];
        }
        else
        {
            [self logout];
        }

    }
    else if (sender == _call_button && _request_object != nil)
    {
        [self makeAPICall];
    }
    else if (sender == _cache_button)
    {
        [self clearCache];
    }
}

-(void) didReceiveOAuthIOResponse:(OAuthIORequest *)request
{
    //This sets up visual responses
    _login_state_label.text = @"Logged in";
    [_state_view setHidden:YES];
    [_login_switch setOn:YES animated:YES];
    
    //This sets request_object with the request object returned by the SDK
    _request_object = request;
}

-(void) didFailWithOAuthIOError:(NSError *)error
{
    //This sets up visual responses
    [_state_view setHidden:YES];
    [_login_switch setOn:NO animated:YES];
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
    
    //This logs the error
    NSLog(@"Error: %@", error.description);
}



@end
