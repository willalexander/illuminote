//
//  notesListView.h
//  luminotes
//
//  Created by William Alexander on 04/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

#import "utilities.h"

#define KEYBOARD_BACKLIGHT_ON_THRESHOLD 0.3

@class notesListView_scrollableSubview;
@class notesListDrawView;
@class borderCALayer;


@interface notesListView: UIView
{
    CGImageRef backgroundImage_lit;
    CGImageRef backgroundImage_intermediate;
    CGImageRef backgroundImage_illuminated;
    
    CGImageRef backgroundImage_lit_l;
    CGImageRef backgroundImage_intermediate_l;
    CGImageRef backgroundImage_illuminated_l;
    
    CALayer *lightEffectLayer;
    
    notesListView_scrollableSubview *theSrollableSubview;
    
    float globalBrightness;
    
    int UIorientation;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
- (void)setCurrentlySelectedNote: (int)currentNote;

- (void)setGlobalBrightness: (float)val_in;
- (float)getGlobalBrightness;

- (void)setUIOrientation: (int)orient_in;

@end



@interface notesListView_scrollableSubview : UIScrollView
{
    notesListDrawView *theContentView;
    NSMutableArray *theArrayOfNotes_copy;
    
    float globalBrightness;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
- (void)setCurrentlySelectedNote: (int)currentNote;
- (void)setGlobalBrightness: (float)val_in;

@end



@interface notesListDrawView : UIView
{
    NSMutableArray *theArrayOfNotes;
    
    int noteNumTouched;
    
    float globalBrightness;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
- (void)setCurrentlySelectedNote: (int)currentNote;
- (void)setGlobalBrightness: (float)val_in;

@end 

