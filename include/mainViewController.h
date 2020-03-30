//
//  mainViewController.h
//  luminotes
//
//  Created by William Alexander on 31/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class touchCatcherView;

@interface mainViewController : UIViewController <MFMessageComposeViewControllerDelegate>
{
    /*for presenting the user with an email interface containing the current note when requested:*/
    MFMailComposeViewController *emailViewController;
    
    touchCatcherView *mainView;
}

- (void)presentEmailUIWithContents: (NSString *)theNoteString;
- (void)setMainView: (touchCatcherView *)val_in;

@end
