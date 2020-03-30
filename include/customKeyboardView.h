//
//  customKeyboardView.h
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>
#import "QuartzCore/CALayer.h"
#import "utilities.h"



#import "mainTextView.h"

#define KEYBOARD_BACKLIGHT_ON_THRESHOLD 0.3
#define BACKLIGHT_KEYBOARD_SWITCH_DURATION 0.25

#define CUSTOMKEYBOARDVIEW_INVERSION_SWITCH_THRESHOLD 0.5
#define BACKSPACE_REPEAT_INTERVAL 0.1
#define DOUBLE_TAP_MAX_DURATION 0.25

#define DEFAULT_NUM 0
#define NUMBERS_NUM 1
#define SYMBOLS_NUM 2

@class touchCatcherView;

@interface dumbClass: NSObject;

- (float)getGlobalBrightness;

@end


@interface customKeyboardView : UIView
{
    mainTextView *theTextView;
    
    
    /*hierarchical collection of keyboard images: portrait/landscape -> default/numbers/symbols -> up/down -> lit/intermediate/illuminated*/
    CGImageRef keyboardImages[2][3][2][3];
    CGLayerRef keyboardImageLayers[2][3][2][3];
    
    /*hierarchical collection of shift key images for various states: portrait/landscape -> left/right -> lit/illuminated -> on/held*/
    CGImageRef shiftKeyImage[2][2][3][2];
    NSArray *shiftKeyRects;
    
    /*Core Animation layers for all the keyboard blending:*/
    CALayer *blendSublayer;
    
    CALayer *keyDownLayer;
    CALayer *keyDownLayer_blendSublayer;
    CALayer *keyDownMaskLayer;
    CALayer *keyDownMaskLayer_b;
    
    NSMutableArray *keyDownMaskLayers;
    NSMutableArray *keyDownMaskLayers_b;
    
    CALayer *shiftKey_left_layer;
    CALayer *shiftKey_right_layer;
    CALayer *shiftKey_left_layer_blendSublayer;
    CALayer *shiftKey_right_layer_blendSublayer;
    
    
    
    /*arrays to determine where the spacial boundaries between keys are:*/
    int *keyCells_numberOfKeyBoundariesInRow;
    
    int **keyCells_boundaries;
    int keyRows_boundaries[5];
    
    /*landscape equivalents:*/
    int **keyCells_boundaries_l;
    int keyRows_boundaries_l[5];
    
    
    /*this array structure holds the actual string value for each key:*/
    NSMutableArray *keyCellValues;
    
    
    
    /*the following variables are used during operation of the keyboard to keep track of keyboard type, buttons that are touched, held down etc:*/
    int keyboardState;
    int shiftKeyDown;
    
    int doubleTapInProgress;
    
    NSMutableArray *recordedTouches;
    
    NSMutableArray *keysDown;
    NSMutableArray *keysDown_rowNum;
    NSMutableArray *keysDown_keyCellNum;
    NSMutableArray *keysDown_StrVal;
    
    int shiftState;
    CGRect shiftKeyLeft_portrait_rect;
    CGRect shiftKeyRight_portrait_rect;
    CGRect shiftKeyLeft_landscape_rect;
    CGRect shiftKeyRight_landscape_rect;
    
    NSTimer *backspaceKeyIsPressed_timer;
    int backspaceCount;
    
    
    
    /*internal record of this info:*/
    int currentOrientation;
    float globalBrightness;
    
    touchCatcherView *parentCallbackObject;
}

- (void)setTheTextView: (mainTextView *)theTextView_in;
- (void)setParentCallbackObject: (touchCatcherView *)val_in;
- (void)setGlobalBrightness: (float)val_in;
- (void)drawKeyboard;
- (void)setShiftKeysForCurrentGlobalBrightness;
- (void)keyDown: (CGRect)keyDownRect;
- (void)keyUp: (CGRect)keyUpRect andTouchNumThatEnded: (int)touchNumThatEnded;

- (int)findRowThatPointFallsIn: (CGPoint)p;
- (int)findCellThatPointFallsIn: (CGPoint)p cellList: (int *)cellList startIndex: (int)startIndex length: (int)length;
- (NSString *)returnStringKeyValueFromTouchPoint: (CGPoint)thePoint;
- (CGRect)convertKeyCellCoordsToCGRectWithRowNum: (int)rowNum andCellNum: (int)cellNum;

- (void)backspaceKeyIsPressed: (NSTimer *)theTimer;
- (void)doubleTapMaxDurationReached: (NSTimer *)theTimer;

- (void)isInPortrait;
- (void)isInLandscape;
- (void)setAllSubLayersToCorrectSize;


- (void)lazyLoadCGImage: (CGImageRef)theImage toCGLayer: (CGLayerRef *)theLayer fromContext: (CGContextRef)theContext inRect: (CGRect)theRect;

- (void)appWillResignActive;

- (void)keyboardWillShow: (NSNotification *)theNotification;

- (void)touchesEndedSlashCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
