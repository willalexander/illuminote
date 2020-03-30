//
//  buttonDialogView.h
//  luminotes
//
//  Created by William Alexander on 22/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

#define KEYBOARD_BACKLIGHT_ON_THRESHOLD 0.3

@interface buttonDialogView : UIView
{
    NSArray *buttonNames;
    int buttonIsDown;
    
    CGImageRef dialogGraphicImage;
    CGImageRef dialogGraphicImage_intermediate;
    CGImageRef dialogGraphicImage_inverted;
    
    
    CALayer *baseLayer;
    CALayer *lightEffectLayer;
    
    
    NSObject *callbackObject;
    
    float globalBrightness;
}

- (id)initWithFrame:(CGRect)frame andButtonNames: (NSArray *)buttonNames_in;

- (void)setGlobalBrightness: (float)val_in;
- (float)getGlobalBrightness;

- (void)setCallbackObject: (NSObject *)theObj;

@end
