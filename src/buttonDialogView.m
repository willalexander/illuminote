//
//  buttonDialogView.m
//  luminotes
//
//  Created by William Alexander on 22/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "utilities.h"

#import "buttonDialogView.h"

@implementation buttonDialogView

- (id)initWithFrame:(CGRect)frame andButtonNames: (NSArray *)buttonNames_in;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        buttonNames = [buttonNames_in retain];
        buttonIsDown = -1;
        
        [self setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0]];
        
        /*load graphics:*/
        dialogGraphicImage = [utilities loadCGImageByName: @"dialogButton"];
        dialogGraphicImage_intermediate = [utilities loadCGImageByName: @"dialogButton_intermediate"];
        dialogGraphicImage_inverted = [utilities loadCGImageByName: @"dialogButton_inverted"];
        
        
        baseLayer = [CALayer layer];
        [baseLayer setFrame: [self bounds]];
        [baseLayer setContents: (id)(dialogGraphicImage)];
        [[self layer] addSublayer: baseLayer];
        
        lightEffectLayer = [CALayer layer];
        [lightEffectLayer setFrame: CGRectMake(29.75, 29.75, 150.5, 40.5)];
        [lightEffectLayer setCornerRadius: 11];
        [lightEffectLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [lightEffectLayer setOpacity: 0.0];
        [[self layer] addSublayer: lightEffectLayer];
        
        
        /*initial settings:*/
        globalBrightness = 1.0;
    }
    return self;
}


- (void)setGlobalBrightness:(float)val_in
{
    float globalBrightness_old = globalBrightness;
    
    globalBrightness = val_in;
    
    /*if in normal, lit mode:*/
    if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        [baseLayer setContents: (id)(dialogGraphicImage)];
        [baseLayer removeAllAnimations];
        
        [lightEffectLayer setOpacity: 1.0 - globalBrightness];
        [lightEffectLayer setFrame: CGRectMake(29.75, 29.75, 150.5, 40.5)];
        [lightEffectLayer setCornerRadius: 11];
        [lightEffectLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [lightEffectLayer setContents: (id)(nil)];
        [lightEffectLayer removeAllAnimations];
        
        /*if we've just crossed the threshold, then redraw the content of this view:*/
        if(globalBrightness_old <= KEYBOARD_BACKLIGHT_ON_THRESHOLD) [self setNeedsDisplay];
    }
    
    else 
    {
        [baseLayer setContents: (id)(dialogGraphicImage_intermediate)];
        [baseLayer removeAllAnimations];
        
        [lightEffectLayer setOpacity: 1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];
        [lightEffectLayer setFrame: CGRectMake(30, 30, 150, 40)];
        [lightEffectLayer setCornerRadius: 0];
        [lightEffectLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0] CGColor]];
        [lightEffectLayer setContents: (id)(dialogGraphicImage_inverted)];
        [lightEffectLayer removeAllAnimations];
        
        /*if we've just crossed the threshold, then redraw the content of this view:*/
        if(globalBrightness_old > KEYBOARD_BACKLIGHT_ON_THRESHOLD) [self setNeedsDisplay];
    }
}

- (float)getGlobalBrightness
{
    return globalBrightness;
}


- (void)drawRect:(CGRect)rect
{
    /*Get the drawing context:*/
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    /*background color: (white for email, red for delete, blue if pressed down)*/
    if(buttonIsDown != -1)
    {
        CGContextSetRGBFillColor(theContext, 0.5, 0.775, 1.0, 1.0);
    }
    else
    {
        if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD)
        {
            if([buttonNames objectAtIndex: 0] == @"email note") CGContextSetRGBFillColor(theContext, 1.0, 1.0, 1.0, 1.0);
            if([buttonNames objectAtIndex: 0] == @"delete note") CGContextSetRGBFillColor(theContext, 1.0, 0.5, 0.5, 1.0);
        }
        
        else 
        {
            if([buttonNames objectAtIndex: 0] == @"email note") CGContextSetRGBFillColor(theContext, 0.3, 0.3, 0.3, 1.0);
            if([buttonNames objectAtIndex: 0] == @"delete note") CGContextSetRGBFillColor(theContext, 0.5, 0.0, 0.0, 1.0);
        }
    }
    CGContextFillRect(theContext, CGRectMake(34, 34, 142, 32));
    
    /*Write Button names between the boundaries:*/
    CGContextSelectFont(theContext, "Helvetica", 18, kCGEncodingMacRoman);
    CGContextSetTextMatrix(theContext, CGAffineTransformMake(1, 0, 0, -1, 0, 0));	
    
    if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD) CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0);
    else CGContextSetRGBFillColor(theContext, 1.0, 1.0, 1.0, 1.0);
    
    /*position text at correct position based upon what the text is:*/
    if([buttonNames objectAtIndex: 0] == @"email note") CGContextShowTextAtPoint(theContext, 64, 56, [@"email note" UTF8String], 10);
    if([buttonNames objectAtIndex: 0] == @"delete note") CGContextShowTextAtPoint(theContext, 61, 56, [@"delete note" UTF8String], 11); 
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView: self];
    
    buttonIsDown = (int)(touchPoint.y / (self.bounds.size.height / [buttonNames count]));
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [callbackObject callbackWithValue: buttonIsDown sender: self];
    
    buttonIsDown = -1;
    [self setNeedsDisplay];
}


- (void)setCallbackObject:(NSObject *)theObj
{
    callbackObject = theObj;
}


- (void)dealloc
{
    [buttonNames release];
    
    CGImageRelease(dialogGraphicImage);
    CGImageRelease(dialogGraphicImage_intermediate);
    CGImageRelease(dialogGraphicImage_inverted);
    
    [baseLayer removeFromSuperlayer];
    [lightEffectLayer removeFromSuperlayer];
    
    [super dealloc];
}

@end
