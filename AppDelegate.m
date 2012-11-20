/*
 * Copyright (C) 2009 by Matthias Ringwald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MATTHIAS RINGWALD AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MATTHIAS
 * RINGWALD OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#import "AppDelegate.h"
#import "mouse_msgs.h"
#import "ConfigurationViewController.h"
#import "SynergyClient.h"

#define VERSION "0.8"

@implementation AppDelegate


@synthesize window;
@synthesize navController;
@synthesize configViewController;
@synthesize synergyClient;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
	// create config view controller
	configViewController = [[ConfigurationViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[configViewController setTitle:[NSString stringWithFormat:@"iSynergyClient %@", @VERSION]];
	// [configViewController setDelegate:self];
		
	navController = [[UINavigationController alloc] initWithRootViewController:configViewController];
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:navController.view];
	[window makeKeyAndVisible];

	self.synergyClient = [[SynergyClient alloc] init];
	[configViewController setSynergyClient:synergyClient];
	[synergyClient setDelegate:configViewController];
	CGRect screenBound = [[UIScreen mainScreen] bounds];
	// NSLog(@"Screen width = %f, height = %f", screenBound.size.width, screenBound.size.height);
	[synergyClient setScreenWidth:screenBound.size.width andHeight:screenBound.size.height];
	
    //saiyen
    //Detect orientation change
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    //saiyen
    
	return YES;
}

//saiyen
-(void)detectOrientation{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.        
    
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) 
    {
        CGRect temp;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;      
    }
	[self.synergyClient setScreenWidth:fullScreenRect.size.width andHeight:fullScreenRect.size.height];
    [self.synergyClient sendResetOptionsMessage];
}
//saiyen

- (void)applicationWillTerminate:(UIApplication *)application{
	[configViewController updateDefaultsFromView];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
