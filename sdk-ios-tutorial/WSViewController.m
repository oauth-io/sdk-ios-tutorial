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

@property OAuthIORequest *request_object;
@property OAuthIOModal *oauthio_modal;
@property NSDictionary *config;

@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    _config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    _oauthio_modal = [[OAuthIOModal alloc] initWithKey:[_config objectForKey:@"app_key"] delegate:self];
    _login_state_label.text = @"Not connected";
}

-(void) viewDidAppear:(BOOL)animated
{
    if ([_oauthio_modal cacheAvailableForProvider:@"facebook"])
    {
        [self login];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) login
{
    _state_label.text = @"Logging in via Facebook";
    [_state_view setHidden:NO];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:@"true" forKey:@"cache"];
    [options setObject:@"true" forKey:@"clear-popup-cache"];
    [_oauthio_modal showWithProvider:@"facebook" options:options];
    
}

-(void) makeAPICall
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _state_label.text = @"Fetching your info";
    [_state_view setHidden:NO];
    [_request_object me:nil success:^(NSDictionary *output, NSString *body, NSHTTPURLResponse *httpResponse) {
        _name_label.text = [output objectForKey:@"name"];
        _email_label.text = [output objectForKey:@"email"];
        [_state_view setHidden:YES];
    }];
}

-(void) logout
{
    _request_object = nil;
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
}

-(void) clearCache
{
    [_oauthio_modal clearCache];
}

-(IBAction)buttonPressed:(id)sender
{
    if (sender == _login_switch)
    {
        if ([_login_switch isOn])
        {
            [self login];
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
    _login_state_label.text = @"Logged in";
    [_state_view setHidden:YES];
    [_login_switch setOn:YES animated:YES];
    _request_object = request;
}

-(void) didFailWithOAuthIOError:(NSError *)error
{
    [_state_view setHidden:YES];
    [_login_switch setOn:NO animated:YES];
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
}



@end
