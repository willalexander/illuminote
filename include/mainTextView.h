//
//  mainTextView.h
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

#import "utilities.h"
#import "mainTextViewDelegate.h"

#define KEYBOARD_BACKLIGHT_ON_THRESHOLD 0.3
#define MAINTEXTVIEW_INVERSION_SWITCH_THRESHOLD 0.5
#define MAINTEXTVIEW_MINIMUM_TEXT_BRIGHTNESS 0.35



@class touchCatcherView;
@class correctorView;


@interface mainTextView : UITextView
{
    UITextChecker *theTextChecker;
    
    correctorView *theCorrectorView;
    
    NSString *currentWordCorrection;
    int currentWordShouldBeLearnt;
    NSCharacterSet *delineationCharacters;
    
    
    /*always keep a record of the last key/character entered:*/
    NSString *lastKeyEntered;
    
    NSString *lastEnteredCharacter;
    NSRange lastSelectionPosition;
    
    mainTextViewDelegate *theDelegate;
    
    touchCatcherView *parentCallbackObject;
    
    float globalBrightness;
}

- (void)keyWasPressed: (NSString *)theKey;
- (void)backspace;
- (void)callbackMethod;
- (void)textViewDidChangeSelection;

- (CGPoint)getSpacialPosOfCursor;
- (void)spellCheckCurrentWord;
- (void)userRejectedWordCorrectionSuggestion;
- (NSRange)getRangeOfLastTypedWordBeforeDelineator;
- (void)replaceLastWordWithCorrection: (NSString *)correctWord;

- (void)setGlobalBrightness: (float)val_in;

- (void)setParentCallbackObject: (touchCatcherView *)in_val;
- (void)didSwitchNote;



@end


/*
    
    correctorView - a simple little view that shoes the user a suggested correct spelling of a word that they are (incorrectly) typing
 
 */
@interface correctorView : UIView
{
    UITextView *textContentView;
    CGImageRef background_image;
}

- (void)setWord: (NSString *)theWord_in;
- (int)widthToFitWord;

@end

