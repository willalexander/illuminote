//
//  notesListView.m
//  luminotes
//
//  Created by William Alexander on 04/03/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "notesListView.h"



@implementation notesListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0]];
        
        /*Load up the border image:*/
        backgroundImage_lit = [utilities loadCGImageByName: @"notesListView_lit"];
        backgroundImage_intermediate = [utilities loadCGImageByName: @"notesListView_intermediate"];
        backgroundImage_illuminated = [utilities loadCGImageByName: @"notesListView_illuminated"];
        
        backgroundImage_lit_l = [utilities loadCGImageByName: @"notesListView_lit_l"];
        backgroundImage_intermediate_l = [utilities loadCGImageByName: @"notesListView_intermediate_l"];
        backgroundImage_illuminated_l = [utilities loadCGImageByName: @"notesListView_illuminated_l"];

        
        /*set initial values:*/
        globalBrightness = 0.0;
        UIorientation = 0;
        [self setGlobalBrightness: 1.0];
        [[self layer] setCornerRadius: 15.0];
    
        
        /*create the over-the top layer that will darken as the user lowers the global brightness:*/
        lightEffectLayer = [CALayer layer];
        [lightEffectLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [lightEffectLayer setOpacity: 0.0];
        [[self layer] addSublayer: lightEffectLayer];
        
        /*Create the scrollable subview that will contain the list of notes:*/
        theSrollableSubview = [[notesListView_scrollableSubview alloc] initWithFrame: CGRectMake(34, 34, 292, 542)];
        [self addSubview: theSrollableSubview];
    }
    
    return self;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
{
    [theSrollableSubview setCurrentArrayOfNotes: arrayOfNotes];
}

- (void)setCurrentlySelectedNote: (int)currentNote;
{
    [theSrollableSubview setCurrentlySelectedNote: currentNote];
}

- (void)setGlobalBrightness:(float)val_in
{
    [theSrollableSubview setGlobalBrightness: val_in];
    
    /*if in normal lit mode, */
    if(val_in > KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        /*if we've just entered this mode from illuminated mode, then change the contents of the layers appropriately:*/
        if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD)
        {
            if(UIorientation == 0)  [[self layer] setContents: (id)(backgroundImage_lit)];
            else                    [[self layer] setContents: (id)(backgroundImage_lit_l)];
            [[self layer] removeAllAnimations];
            
            [lightEffectLayer setContents: nil];
            [lightEffectLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
            [lightEffectLayer removeAllAnimations];
        }
         
        /*however, light effects get adjusted *every* time the global brightness changes:*/
        [lightEffectLayer setOpacity: 1.0 - val_in];
        [lightEffectLayer removeAllAnimations];
    }
    else
    {
        if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD) 
        {
            if(UIorientation == 0)
            {
                [[self layer] setContents: (id)(backgroundImage_intermediate)];
                [[self layer] removeAllAnimations];
                [lightEffectLayer setContents: (id)(backgroundImage_illuminated)];
                [lightEffectLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha:0.0] CGColor]];
                [lightEffectLayer removeAllAnimations];
            }
            else
            {
                [[self layer] setContents: (id)(backgroundImage_intermediate_l)];
                [[self layer] removeAllAnimations];
                [lightEffectLayer setContents: (id)(backgroundImage_illuminated_l)];
                [lightEffectLayer setBackgroundColor: [[UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha:0.0] CGColor]];
                [lightEffectLayer removeAllAnimations];
            }
        }
        
        [lightEffectLayer setOpacity: 1.0 - (val_in / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];
        [lightEffectLayer removeAllAnimations];
    }
    
    /*update internal record:*/
    globalBrightness = val_in;
}

- (float)getGlobalBrightness 
{
    return globalBrightness;
}

- (void)setUIOrientation: (int)orient_in
{
    UIorientation = orient_in;
}

- (void)layoutSubviews
{
    /*apply appropriate images to the layers  based upon brightness and orientation (bit of an ugly hacked use of 'setGlobalBrightness:' here):*/
    float globalBrightness_prev = globalBrightness;
    if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD)  globalBrightness = 0.0;
    else globalBrightness = 1.0;
    [self setGlobalBrightness: globalBrightness_prev];
    
    if(UIorientation == 0)
    {
        [lightEffectLayer setFrame: CGRectMake(30, 25, 300, 550)];
        [lightEffectLayer setCornerRadius: 9.0];
        [lightEffectLayer removeAllAnimations];
        
        [theSrollableSubview setFrame: CGRectMake(34, 29, 292, 542)];
        [theSrollableSubview setNeedsLayout];
    }
    
    if(UIorientation == 1)
    {
        [lightEffectLayer setFrame: CGRectMake(0, 0, 320, 748)];
        [lightEffectLayer setCornerRadius: 8.0];
        [lightEffectLayer removeAllAnimations];
        
        [theSrollableSubview setFrame: CGRectMake(5, 5, 310, 738 )];
        [theSrollableSubview setNeedsLayout];
    }
}



- (void)dealloc
{
    CGImageRelease(backgroundImage_lit);
    CGImageRelease(backgroundImage_intermediate);
    CGImageRelease(backgroundImage_illuminated);
    
    CGImageRelease(backgroundImage_lit_l);
    CGImageRelease(backgroundImage_intermediate_l);
    CGImageRelease(backgroundImage_illuminated_l);
    
    
    [lightEffectLayer removeFromSuperlayer];
    
    [theSrollableSubview removeFromSuperview];
    [theSrollableSubview release];
    
    [super dealloc];
}

@end





@implementation notesListView_scrollableSubview


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0]];
        
        theContentView = [[notesListDrawView alloc] initWithFrame: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview: theContentView];
        
        globalBrightness = 1.0;
        
        [[self layer] setCornerRadius: 5.0];
    }
    
    return self;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
{
    theArrayOfNotes_copy = arrayOfNotes;
    [theContentView setCurrentArrayOfNotes: arrayOfNotes];
    [self setContentSize: [theContentView frame].size];
}

- (void)setCurrentlySelectedNote: (int)currentNote;
{
    [theContentView setCurrentlySelectedNote: currentNote];
}

- (void)layoutSubviews
{
    [theContentView setCurrentArrayOfNotes: theArrayOfNotes_copy];
    
    /*set the contents view to the appropriate width:*/
    CGRect contentViewFrame = [theContentView frame];
    [theContentView setFrame: CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, [self frame].size.width, contentViewFrame.size.height)];
    
    [self setContentSize: [theContentView frame].size];
    [theContentView setNeedsDisplay];
}

- (void)setGlobalBrightness:(float)val_in
{
    globalBrightness = val_in;
    [theContentView setGlobalBrightness: globalBrightness];
    
    if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD) [self setIndicatorStyle: UIScrollViewIndicatorStyleWhite];
    else [self setIndicatorStyle: UIScrollViewIndicatorStyleBlack];
}

- (void)dealloc
{
    [theContentView removeFromSuperview];
    [theContentView release];
    
    [super dealloc];
}

@end





@implementation notesListDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0]];
        
        /*no notes are highlighted by default:*/
        noteNumTouched = -1;
        
        globalBrightness = 1.0;
    }
    return self;
}

- (void)setCurrentArrayOfNotes: (NSMutableArray *)arrayOfNotes;
{
    theArrayOfNotes = arrayOfNotes;
    
    if(([theArrayOfNotes count] * 35) > [self superview].bounds.size.height) [self setFrame: CGRectMake(0, 0, self.bounds.size.width, [theArrayOfNotes count] * 35) ];
    else [self setFrame: [[self superview] bounds] ];
    
    if(noteNumTouched >= [theArrayOfNotes count]) noteNumTouched = [theArrayOfNotes count] - 1;
    
    
    [self setNeedsDisplay];
}

- (void)setCurrentlySelectedNote: (int)currentNote;
{
    if(currentNote != noteNumTouched)
    {
        noteNumTouched = currentNote;
        [self setNeedsDisplay];
    }
}

- (void)setGlobalBrightness:(float)val_in
{
    globalBrightness = val_in;
    [self setNeedsDisplay];
}



- (void)drawRect:(CGRect)rect
{
    /*Get the drawing context:*/
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    /*do we need to highlight a note?*/
    if(noteNumTouched != -1)
    {
        CGContextSetRGBFillColor(theContext, 0.0, 0.5, 1.0, 0.5);
        CGContextFillRect(theContext, CGRectMake(0, noteNumTouched * 35.0, self.bounds.size.width, 36.0));
    }
    
    /*Draw the notes' strings and boundaries between them:*/
    CGPoint linePoints[2];
    NSString *firstLineOfNote;
    if(theArrayOfNotes != nil)
    {
        for(int i = 0; i < [theArrayOfNotes count]; i++)
        {
            CGContextSetTextMatrix(theContext, CGAffineTransformMake(1, 0, 0, -1, 0, 0));	
            CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0);
            if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD) CGContextSetRGBFillColor(theContext, 0.75, 0.75, 0.75, 1.0);
            CGContextSelectFont(theContext, "Helvetica", 18, kCGEncodingMacRoman);
            
            /*get a string version of the first line of the note only:*/
            int indexOfFirstNewlineCharacter = [[theArrayOfNotes objectAtIndex: i] rangeOfString: @"\n"].location;
            if(indexOfFirstNewlineCharacter > [[theArrayOfNotes objectAtIndex: i] length]) indexOfFirstNewlineCharacter = [[theArrayOfNotes objectAtIndex: i] length];
            firstLineOfNote = [[theArrayOfNotes objectAtIndex: i] substringToIndex: indexOfFirstNewlineCharacter];
            CGContextShowTextAtPoint(theContext, 10, i * 35 + 25, [firstLineOfNote UTF8String], [firstLineOfNote length]);
            
            linePoints[0] = CGPointMake(0, (i + 1) * 35 + 0.5);
            linePoints[1] = CGPointMake(self.bounds.size.width, (i + 1) * 35 + 0.5);
            CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 0.0, 0.25);
            if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD) CGContextSetRGBStrokeColor(theContext, 1.0, 1.0, 1.0, 0.25);
            CGContextStrokeLineSegments(theContext, linePoints, 1);
        }
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView: self];
    
    noteNumTouched = (int)(touchPoint.y / 35.0);
    if(noteNumTouched >= [theArrayOfNotes count]) noteNumTouched = -1;
    
    if(noteNumTouched != -1) [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView: self];
    
    if(noteNumTouched == -1)
    {
        noteNumTouched = (int)(touchPoint.y / 35.0);
        if(noteNumTouched >= [theArrayOfNotes count]) noteNumTouched = -1;
    
        if(noteNumTouched != -1) [self setNeedsDisplay];
    }
    
    if(noteNumTouched != -1)
    {
        [[[[self superview] superview] superview] noteWasSelected: noteNumTouched];
    }
}


- (void)dealloc
{
    [super dealloc];
}

@end

