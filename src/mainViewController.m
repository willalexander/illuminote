//
//  mainViewController.m
//  luminotes
//
//  Created by William Alexander on 31/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "mainViewController.h"

#import <MessageUI/MessageUI.h>


@implementation mainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    int newOrientationSimple = 0;
    if((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation == UIDeviceOrientationLandscapeRight)) newOrientationSimple = 1;
    
    [mainView rearrangeInterfaceForNewOrientation: toInterfaceOrientation];
}


- (void)presentEmailUIWithContents: (NSString *)theNoteString;
{
    /*Bring up the standard system email dialog with the current note's text as the email content:*/
    emailViewController = [[MFMailComposeViewController alloc] init];
    [emailViewController setMailComposeDelegate: self];
    [emailViewController setMessageBody: theNoteString isHTML: NO];
    
    if([MFMailComposeViewController canSendMail] == YES) [self presentModalViewController: emailViewController animated: YES];
}

/*callback for when the user dismisses the email view:*/
- (void)mailComposeController: (MFMessageComposeViewController *)controller didFinishWithResult: (MFMailComposeResult)result error: (NSError *)error
{
    [emailViewController dismissViewControllerAnimated: YES completion: nil];
    
    [emailViewController release];
}

- (void)setMainView: (touchCatcherView *)val_in
{
    mainView = val_in;
}

- (void)dealloc
{
    [super dealloc];
}

@end
