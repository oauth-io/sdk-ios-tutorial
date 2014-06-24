OAuth.io iOS SDK Tutorial
=========================

This tutorial will show you how to integrate OAuth.io in your iOS application easily.

OAuth.io allows you to retrieve access tokens from 100+ providers, and to perform API calls really easily. Check out [our website](https://oauth.io) to learn more about it.

Prerequisite
============

Before you start this tutorial, you need to make sure you have [subscribed to OAuth.io](https://oauth.io/register) (the [Bootstrap plan](https://oauth.io/pricing) is free). You need to setup an app in your account with the provider Facebook, configured with a `client_id` and a `client_secret`. Also add the `email` scope to be able to retrieve the user's email in addition to his basic information.

Table of contents
=================

The tutorial is divided into 5 different steps. Each step is associated with a tag in the [tutorial repository](https://github.com/oauth-io/sdk-ios-tutorial). Once you have passed the `step-0`, in which you need to configure the app with the public key of your OAuth.io app, you will be able to checkout each step at will, so you don't have to do everything if you don't have enough time ;) (though it's a pretty quick tutorial).


- **Step 0 - Getting the code and configuring the app** (tagged `step-0`)
- **Step 1 - Setting up the OAuthIODelegate** (tagged `step-1`)
- **Step 2 - Authenticating with the OAuthIOModal** (tagged `step-2`)
- **Step 3 - Adding cache support** (tagged `step-3`)
- **Step 4 - Performing a call to the API** (tagged `step-4`)

To the code!
============

Step 0 - Getting the code and configuring the app
-------------------------------------------------

**Cloning the repo**

The first thing you need to do is to clone the tutorial repository by running the following command in your terminal:

```sh
$ git clone https://github.com/oauth-io/sdk-ios-tutorial.git
$ cd sdk-ios-tutorial
```

Once you are in the folder, open the `sdk-ios-tutorial.xcworkspace` (note that we are using the `xcworkspace` here and not the `xcodeproj` as we are using Cocoa Pods to install OAuth.io).

**Updating dependencies**

The installation of OAuth.io is already done for you here (checkout the [SDK's repository README.md](https://github.com/oauth-io/oauth-ios) for more information about the installation), but you need to run the following command to install all the dependencies (it's just the SDK actually):

```sh
$ pod update
```

If you don't have the `pod` command, checkout [Cocoa Pods](http://cocoapods.org) to install it.

**Configuration**

From XCode, create a configuration file called `config.plist`:

- Right click on the `Supporting files` folder and choose `New file...`
- Choose `iOS` > `Resource` and select `Property list`
- Click on `Next`, call the file `config.plist` and click on `create`

In that file, add a row under the Root. Call it `app_key`, and as value, put your *OAuth.io app's public key* (which you can get in your [dashboard](https://oauth.io/dashboard)). Don't forget to save the file.

That's it for step 0.

Step 1 - Authenticating with the OAuth.io modal
-----------------------------------------------

In this step, we'll set the main view controller, `WSViewController` as a `OAuthIODelegate`, which will allow it to control an `OAuthIOModal`, which shows a popup for the user to log in and accept your app's permissions.

Open the `WSViewController.h` file and import the OAuth.io SDK there:

```Objective-C
#import <UIKit/UIKit.h>
//Add this line here
#import <OAuthiOS/OAuthiOS.h>

@interface WSViewController : UIViewController
//...
@end
```

Then set this view controller as an `OAuthIODelegate` in the same file:

```Objective-C
//...
@interface WSViewController : UIViewController<OAuthIODelegate>
//...
@end
```

Now, add the associated methods to the implementation file (`WSViewController.m`), right above the `@end` statement:

```Objective-C

-(void) didReceiveOAuthIOResponse:(OAuthIORequest *)request
{
    // Here we'll handle the authentication response
}

-(void) didFailWithOAuthIOError:(NSError *)error
{
    // Here we'll handle the authenication errors
}

```

That's it for step 1.

If you want to get the code from step 1, just run the following command:

```sh
$ git checkout step-1 --force
```

Note that any change you made will be discarded and replaced by the code shown in this tutorial (except for your config.plist file, that is ignored and will remain there).

Step 2 - Authenticating with the OAuthIOModal
---------------------------------------------

In this step, we'll setup the authentication, which is handled by a `OAuthIOModal` instance. First add the following properties at the top of the implementation file (`WSViewController.m`), in the `@interface` block:

```Objective-C
@property OAuthIOModal *oauthio_modal;
@property OAuthIORequest *request_object;
```

The `oauthio_modal` is what will allow us to show a popup to let the user login and accept permissions. When the popup disappears, we are given an `OAuthIORequest` instance which we'll put in `request_object`.

First we have to initialize the `oauthio_modal` in the `viewDidLoad` method. Replace the comment placeholder:

```Objective-C
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    _config = [[NSDictionary alloc] initWithContentsOfFile:path];
    _login_state_label.text = @"Not connected";
    
    //Replace this placeholder with the modal initialization code
}
```

with the following code:

```Objective-C
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    _config = [[NSDictionary alloc] initWithContentsOfFile:path];
    _login_state_label.text = @"Not connected";
    
    _oauthio_modal = [[OAuthIOModal alloc] initWithKey:[_config objectForKey:@"app_key"] delegate:self];
}
```

Then find the method called `authenticate`. Replace the comment placeholder:

```Objective-C
-(void) authenticate
{
    _state_label.text = @"Logging in via Facebook";
    [_state_view setHidden:NO];
    
    
    //Replace this placeholder with the authentication code
}
```

with the following code:

```Objective-C
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
```

Then we need to edit the `didReceiveOAuthIOResponse` and `didFailWithOAuthIOError` methods to handle the OAuth.io response. Find the methods and fill them with the following code:

```Objective-C
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

```

Once you've done that, you should be able to run the application, tap on the switch in the top right hand corder. This will show a popup in which you'll be able to authenticate to Facebook, and accept your app's permissions.

Find the `logout` method, and replace the placeholder:

```Objective-C
-(void) logout
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
    
    //Replace this placeholder with the logout code
}
```

with the following code, which will remove the request_object from the instance:

```Objective-C
-(void) logout
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _login_state_label.text = @"Not connected";
    
    //This removes the _request_object reference, and thus logs out your user
    _request_object = nil;
}
```

That's it for step 2.

If you want to get the code from step 2, just run the following command:

```sh
$ git checkout step-2 --force
```

Note that any change you made will be discarded and replaced by the code shown in this tutorial (except for your config.plist file, that is ignored and will remain there).

Step 3 - Adding the cache management
------------------------------------

To prevent your user to see the popup everytime he launches the app, you can use the cache feature of the SDK. This will save the credentials returned by the provider (e.g. access tokens, the expiration date, etc.) to a file on the user's phone, which can be reloaded at startup.

We'll add a button that lets you clear the cache so that you can test the feature easily.

First go back to the `authenticate` method, and add the following line before you make the call to `showWithProvider`:

```Objective-C
[options setObject:@"true" forKey:@"cache"];
```

This will activate the cache for the modal. Then, when you run the application, if you try to login, logout and login again, you'll see that on the second login, you are not shown the popup, but are logged in anyway.

You can now replace the following placeholder in the `viewDidAppear` method:

```Objective-C
-(void) viewDidAppear:(BOOL)animated
{
    //Replace this placeholder with code to log the user right away 
    //if his session is cached
}
```

with the following code, so that your user can be logged in from the cache when he launches the app:


```Objective-C
-(void) viewDidAppear:(BOOL)animated
{
    //This tests if a cache file has been saved for the provider 'facebook'
    if ([_oauthio_modal cacheAvailableForProvider:@"facebook"])
    {
        [self authenticate];
    }
}
```

Now if you run the application again, you'll see that you are logged in right away.

To clear the cache, find the `clearCache` method and replace the placeholder:

```Objective-C
-(void) clearCache
{
    //Replace this placeholder with code to clear the cache
}
```

and replace it with the following code:

```Objective-C
-(void) clearCache
{
    [_oauthio_modal clearCache];
}
```

That's it for step 3.

If you want to get the code from step 3, just run the following command:

```sh
$ git checkout step-3 --force
```

Note that any change you made will be discarded and replaced by the code shown in this tutorial (except for your config.plist file, that is ignored and will remain there).


Step 4 - Performing a call to the API
-------------------------------------

Now we'd like to really use the API and retrieve the user's name and email to display them on the screen.

To do that, we're going to use the `request_object` that we set up thanks to what's returned to the `didReceiveOAuthIOResponse`.

To use the `request_object`, find the `makeAPICall` method in `WSViewController.m`, and replace the placeholder:

```Objective-C
-(void) makeAPICall
{
    _name_label.text = @"N/A";
    _email_label.text = @"N/A";
    _state_label.text = @"Fetching your info";
    [_state_view setHidden:NO];
    
    
    //Replace this placeholder with the request code
}
```

with the following code:

```Objective-C
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
```

This uses the `me` method to retrieve a `NSDictionary` instance containing unified fields describing the user. The values `name` and `email` are then respectively put into the `name_label` and `email_label` labels, which shows them on the screen.

There are of course more methods than the `me`, to perform usual HTTP requests to the API, like the `get` method or the `post` method. You can refer to the [SDK Github repository](https://github.com/oauth-io/oauth-ios) to get more information about these methods.

That's it for step 4.

If you want to get the code from step 3, just run the following command:

```sh
$ git checkout step-4 --force
```

Note that any change you made will be discarded and replaced by the code shown in this tutorial (except for your config.plist file, that is ignored and will remain there).

The tutorial is now finished :). Thanks for reading. We hope that it helped you understand how the OAuth.io iOS SDK works.

If you want to learn more about OAuth.io, visit us on [https://oauth.io](https://oauth.io).

