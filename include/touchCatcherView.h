//
//  touchCatcherView.h
//  luminotes
//
//  Created by William Alexander on 11/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#define HIDE_NOTES_LIST_VIEW_DELAY 0.25
#define KEYBOARD_BACKLIGHT_ON_THRESHOLD 0.3
#define UNDO_QUEUE_CAPACITY 50
#define AUTOSAVE_INTERVAL 10


#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "mainTextView.h"
#import "customKeyboardView.h"
#import "notesListView.h"
#import "buttonDialogView.h"
#import "utilities.h"

@class dimmableButton;

@interface touchCatcherView : UIView
{
    /*for recording when buttons are down/up*/
    int notesButtonDown;
    int newButtonDown;
    int prevButtonDown;
    int emailButtonDown;
    int deleteButtonDown;
    int nextButtonDown;
    
    
    /*for the double touch recognition system:*/
    CGPoint hitTestRecordPoint;
    int hasBecomeDoubleTap;
    NSDate *doubleTapIntervalStartDate;
    int doubleTapIntervalInProgress;
    
    /*for keeping track of global brightness:*/
    float globalBrightness;
    float previousGlobalBrightness;
    
    /*For keeping track of device orientation*/
    int currentDeviceOrientation;
    int currentDeviceOrientationSimple;
    
    /*For saved data:*/
    NSURL *archiveURL;
    NSMutableDictionary *archiveDictionary;
    NSMutableArray *arrayOfNotes;
    int currentNote;
    NSTimer *autosaveTimer;
    
    /*for the undo system:*/
    int undoPosition;
    NSMutableArray *undoQueue;
    
    /*various major interface elements*/
    CALayer *darkenLayer;
    mainTextView *theMainTextView;
    customKeyboardView *theCustomKeyboardView;
    UIView *theNotesListView;
    
    buttonDialogView *emailButtonDialogView;
    buttonDialogView *deleteButtonDialogView;
    
    
    /*the many image objects for various interface elements:*/
    CGImageRef toolbar_main_image;
    CGImageRef toolbar_notesButton_image;
    CGImageRef toolbar_notesButton_down_image;
    CGImageRef toolbar_newButton_image;
    CGImageRef toolbar_newButton_down_image;
    CGImageRef toolbar_inverted_main_image;
    CGImageRef toolbar_inverted_notesButton_image;
    CGImageRef toolbar_inverted_notesButton_down_image;
    CGImageRef toolbar_inverted_newButton_image;
    CGImageRef toolbar_inverted_newButton_down_image;
    CGImageRef toolbar_inverted_image;
    
    /*CGImageRef notesButton_default_off_image;
    CGImageRef notesButton_default_on_image;
    CGImageRef notesButton_inverted_off_image;
    CGImageRef notesButton_inverted_on_image;*/
    UIImage *notesButton_default_off_image;
    UIImage *notesButton_default_on_image;
    UIImage *notesButton_intermediate_off_image;
    UIImage *notesButton_intermediate_on_image;
    UIImage *notesButton_inverted_off_image;
    UIImage *notesButton_inverted_on_image;
    
    CGImageRef newButton_default_off_image;
    CGImageRef newButton_default_on_image;
    CGImageRef newButton_inverted_off_image;
    CGImageRef newButton_inverted_on_image;
    
    CGImageRef prevButton_default_off_image;
    CGImageRef prevButton_default_on_image;
    CGImageRef prevButton_inverted_off_image;
    CGImageRef prevButton_inverted_on_image;
    CGImageRef emailButton_default_off_image;
    CGImageRef emailButton_default_on_image;
    CGImageRef emailButton_inverted_off_image;
    CGImageRef emailButton_inverted_on_image;
    CGImageRef deleteButton_default_off_image;
    CGImageRef deleteButton_default_on_image;
    CGImageRef deleteButton_inverted_off_image;
    CGImageRef deleteButton_inverted_on_image;
    CGImageRef nextButton_default_off_image;
    CGImageRef nextButton_default_on_image;
    CGImageRef nextButton_inverted_off_image;
    CGImageRef nextButton_inverted_on_image;
    
    CGImageRef paperTexture_image;
    
    
    /*Dimmable Buttons:*/
    dimmableButton *prevButton; 
    dimmableButton *emailButton; 
    dimmableButton *deleteButton; 
    dimmableButton *nextButton; 
    
    /*for the paper background image:*/
    CGLayerRef paperTexture_layer;
    CGContextRef paperTexture_layerContext;
    
    
    int firstDraw;
    
    /*For use tracking touch movement:*/
    float touchEventStartPos;

    /*this will be assigned as a link to this view's controller*/
    mainViewController *myViewController;

    /*for keeping track of the keyboards position/shape*/
    CGRect currentKeyboardFrame;
    
    UIResponder *appDel;
}

- (id)initWithFrame:(CGRect)frame andInitialOrientation: (UIDeviceOrientation) initOrientation;

- (void)setAppDelegate: (UIResponder *)theAppDel;


- (void)loadData;
- (void)archiveAllData;
- (void)autosaveCallback: (NSTimer *)theTimer;

- (void)collectingTouchesTimeout;

- (void)globalBrightnessChanged: (float)newGlobalBrightness;
- (void)checkGlobalBrightnessOfExposedElements;

- (NSString *)getCurrentNote;
- (void)switchToNoteNumber: (int)numToSwitchTo;
- (void)noteWasSelected: (int)num;

- (void)requestUndo;
- (void)requestRedo;
- (void)newUndoVersionRequired;

- (void)hideNotesListViewTimeout: (NSTimer *)theTimer;

- (void)setupPortraitConfiguration;
- (void)setupLandscapeConfiguration;
- (void)setDeviceOrientationSimple: (int)currentDeviceOrientationNormal;


- (void)keyboardDidShow: (NSNotification *)theNotification;
- (void)keyboardWillChangeFrame: (NSNotification *)theNotification;
- (void)keyboardDidHide: (NSNotification *)theNotification;

- (void)appWillResignActive;
- (void)rearrangeInterfaceForNewOrientation: (int)newOrientation;
- (void)callbackWithValue: (int)val sender: (id)sender;
- (float)getGlobalBrightness;
- (void)addMainTextView: (mainTextView *)theView;
- (void)setMyViewController: (mainViewController *)theController;

- (void)preDealloc;

@end



@interface dimmableButton : UIView
{
    CGImageRef default_image;
    CGImageRef default_down_image;
    CGImageRef inverted_image;
    CGImageRef inverted_down_image;
    
    CGLayerRef default_image_layer;
    CGLayerRef default_down_image_layer;
    CGLayerRef inverted_image_layer;
    CGLayerRef inverted_down_image_layer;
    CGContextRef layerContext;
    
    touchCatcherView *callBackObject;
    
    int buttonIsDown;
    
    int firstDraw;
    
    float globalBrightness;
    
    CGRect bodyRect;
    int cornerRadius;
}

- (id)initWithFrame:(CGRect)frame andDefault: (CGImageRef)image_a defaultDown: (CGImageRef)image_b defaultDown: (CGImageRef)image_c defaultDown: (CGImageRef)image_d;
- (void)setButtonBodyRect: (CGRect)bodyRect_in andCornerRadius: (int)cornerRadius_in;
- (void)setCallbackObject: (touchCatcherView *)val_in;
- (void)setGlobalBrightness: (float)newGlobalBrightness;
- (float)getGlobalBrightness;

@end
