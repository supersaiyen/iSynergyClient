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

#import "ConfigurationViewController.h"
#import "SynergyClient.h"
#import "BackgroundApplication.h"

@implementation ConfigurationViewController

@synthesize synergyClient;
@synthesize serverAddress;
@synthesize clientName;
@synthesize activeSwitch;
@synthesize homeButtonSwitch;
@synthesize activityIndicator;
@synthesize autoConnectOnLoad;

NSString *keyAutoConnect = @"AutoConnect";

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"WillRotate!!!!");
}

// Pickup changes to settings outside of app
- (void)defaultsChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
//    CLIENT_STATE state = [synergyClient clientState];
//    if (state == STATE_NOT_CONNECTED) {
//        //reload table to show changed data
//        //only if we're not connected
//        [self.tableView reloadData];
//    }
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:Nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear...");
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	static NSString * titles[] = { @"Server Address", @"Client Name", @"Special Keys", @"Activation", @"Status", @"Keyboard Support"}; 
	return titles[section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"Cell";
	if ([indexPath row] == 1) {
		cellIdentifier = @"Explanation";
	} else {
		cellIdentifier = [NSString stringWithFormat:@"Field-%u", [indexPath indexAtPosition:0]]; 
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	CGRect textFrame;
	// Configure the cell...
	int inset = 7;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

		UITextField * textField;
		if ([indexPath row] == 0){
			switch ([indexPath section]){
				case 0:
				case 1:
					textFrame = CGRectMake(inset, inset, cell.contentView.bounds.size.width-(2*inset),
										   cell.contentView.bounds.size.height-(2*inset));
					textField = [[UITextField alloc] initWithFrame:textFrame];
					textField.borderStyle = UITextBorderStyleBezel;
					textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
					textField.returnKeyType = UIReturnKeyDone;
					textField.delegate = self;
					[cell.contentView addSubview:textField];
					if ([indexPath indexAtPosition:0] == 0){
						textField.text = [synergyClient serverAddress];
						serverAddress = textField;
					} else {
						textField.text = [synergyClient clientName];
						textField.placeholder = [synergyClient hostName];
						clientName = textField;
					}
					break;
				case 2:
                    cell.textLabel.text = @"Home Button Hot Key";
					homeButtonSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					homeButtonSwitch.on = [synergyClient homeButtonHotkey];
					cell.accessoryView = homeButtonSwitch;
					break;
				case 3:
					cell.textLabel.text = @"Mouse";
					activeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
					activeSwitch.on = [synergyClient enabled];
					[activeSwitch addTarget:self action:@selector(switchToggled) forControlEvents:UIControlEventValueChanged];
					activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
					cell.accessoryView = activeSwitch;
					break;
				case 4:
					cell.textLabel.text = @"Purchase BTstack Keyboard from Cydia Store";
					// keyboard support installed?
					// click goes to cydia store
					break;
			}
		}
    }
		
	if ([indexPath row] == 0){
		switch ([indexPath section]){
			case 0:
				serverAddress.text = [synergyClient serverAddress];
				break;
			case 1:
				clientName.text = [synergyClient clientName];
				break;
			case 2:
                homeButtonSwitch.on = [synergyClient homeButtonHotkey];
				break;
			case 3:
				break;
			case 4:
				break;
		}
	}

	if ([indexPath indexAtPosition:1] == 1){

		NSString * helpTexts[] = {
			@"IP address of Synergy server, either as dot notation like 192.168.3.2 or server.home.com",
			@"Client name as configured on server, leave empty for local hostname",
            @"Use Command + Shift + H to simulate pressing the Home button?",
			@"Start/stop connection to server",
			@"Current status, indicates if connection was established successfully",
			@"To enter text, the BTstack Keyboard package is required"
		};
		
		if ([indexPath indexAtPosition:0] == 3) {
			cell.textLabel.text = [NSString stringWithFormat:@"Current status: %@", [synergyClient connectionStatus]];
			CLIENT_STATE state = [synergyClient clientState];
			switch (state) {
				case STATE_CONNECTED:
				case STATE_LIVE: 
					cell.textLabel.textColor = [UIColor greenColor];
					cell.accessoryView = nil;
					[activityIndicator stopAnimating];
					break;
				case STATE_CONNECTING:
					cell.textLabel.textColor = [UIColor redColor];
					cell.accessoryView = activityIndicator;
					[activityIndicator startAnimating];
					break;
				default:
					cell.textLabel.textColor = [UIColor redColor];
					cell.accessoryView = nil;
					[activityIndicator stopAnimating];
					break;
			}
		} else {
			cell.textLabel.text = helpTexts[[indexPath indexAtPosition:0]];
		}
		cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	}

    return cell;
} 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([indexPath indexAtPosition:1] == 1){
		return 30;
	} else {
		return tableView.rowHeight;
	}
}

#pragma mark TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return NO;
}


#pragma mark -
#pragma mark Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	// if ( [indexPath indexAtPosition:1] == 1) {
	//	return nil;
	//}
	//return indexPath;
	return nil;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	/*
//	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//	 [self.navigationController pushViewController:detailViewController animated:YES];
//	 [detailViewController release];
//	 */
//	[tableView deselectRowAtIndexPath:indexPath animated:NO];
//}

- (void) updateDefaultsFromView {
	[synergyClient setClientName:clientName.text];
	[synergyClient setServerAddress:serverAddress.text];
    [synergyClient setHomeButtonHotKey:homeButtonSwitch.on];
	[synergyClient setEnabled:activeSwitch.on];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connectionStateChanged {
	// NSLog(@"Connection changed %@, %u", [synergyClient connectionStatus], [synergyClient clientState]);
	[self.tableView reloadData];
}

- (void)updateAfterDisconnect {
	[BackgroundApplication setRunInBackground:NO];
	serverAddress.enabled = YES;
	clientName.enabled = YES;
    homeButtonSwitch.enabled = YES;
	serverAddress.borderStyle = UITextBorderStyleBezel;
	clientName.borderStyle = UITextBorderStyleBezel;
}

- (void) remoteDisconnected {
	activeSwitch.on = NO;
	[self.tableView reloadData];
	[self updateAfterDisconnect];
}
- (void) connectionFailed{
	// get error
	NSString *error = [synergyClient connectionError];
	// NSLog(@"Error: %@", error);
	UIAlertView * connectionErrorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:error delegate:nil
									cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[connectionErrorAlert show];
	[self remoteDisconnected];
}

-(void) switchToggled{
	// NSLog(@"Switch toggled!");
	[self updateDefaultsFromView];
	if (activeSwitch.on){
        serverAddress.borderStyle = 0;
        clientName.borderStyle = 0;
        serverAddress.enabled = NO;
        clientName.enabled = NO;
        homeButtonSwitch.enabled = NO;
        [self.tableView reloadData];
        [BackgroundApplication setRunInBackground:YES];
        
        [NSThread detachNewThreadSelector:@selector(startOpeningConnection) toTarget:synergyClient withObject:nil];
	} else {
        [synergyClient stopConnection];
        [self updateAfterDisconnect];
	}
}

- (BOOL) shouldAutoConnect {
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyAutoConnect];
}

- (void) viewDidAppear:(BOOL)animated {
    // toggle switch and launch connection if auto connect key is set
    if ([self shouldAutoConnect]) {
        [[self activeSwitch] setOn:YES animated:NO];
        [self switchToggled];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}



@end

