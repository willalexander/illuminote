//
//  mainTextView.m
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "mainTextView.h"


@implementation mainTextView

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*White background*/
        [self setBackgroundColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0]];
        
        /*Font is a pretty standard 16pt Helvetica:*/
        [self setFont: [UIFont fontWithName: @"Helvetica" size: 16.0]];
        
        /*Create a UITextChecker instance - for use with recognising/correcting incorrectly spelt words:*/
        theTextChecker = [[UITextChecker alloc] init];
        
        /*these keep a record of the last character (and its position) that the user entered:*/
        lastEnteredCharacter = nil;
        lastSelectionPosition = NSMakeRange(-1, -1);
        
        /*the corrector view is a little green helper that appears to suggest a correct spelling of a word that the user is typing*/
        theCorrectorView = [[correctorView alloc] initWithFrame: CGRectMake(0, 0, 124, 27)];
        [theCorrectorView setHidden: YES];
        [self addSubview: theCorrectorView];
        
        /*Use these variables to keep track of whether the current word is correct/spelt wrong/should be learnt:*/
        currentWordCorrection = nil;
        currentWordShouldBeLearnt = 0;
        
        /*the following characters are 'delineators', those that are considered to come between words, as opposed to being part of words:*/
        delineationCharacters = [NSCharacterSet characterSetWithCharactersInString: @"\n,.!? :;&'\"()-"];
        [delineationCharacters retain];
        
        /*global brightness starts off at 1.0:*/
        globalBrightness = 1.0;
    
        /*We have a delegate object that helps respond to certain changes in the text:*/
        theDelegate = [[mainTextViewDelegate alloc] init];
        [self setDelegate: theDelegate];
        [theDelegate setCallbackObj: self];
    }
    
    return self;
}

/*
    This will be called every time the user presses a key:
 */
- (void)keyWasPressed: (NSString *)theKey
{
    /*find out the current cursor position, and enter the character that the user has pressed:*/
    NSRange currentSelectedRange = [self selectedRange];
    
    [self setText: [[self text] stringByReplacingCharactersInRange: currentSelectedRange withString: theKey]];
    [self setSelectedRange: NSMakeRange(currentSelectedRange.location + 1, 0)];
    
    
    /*Determine whether this key represents a 'normal' character or is a delineation character (punctuation)*/
    int isADelineationChar = 1;
    if([theKey rangeOfCharacterFromSet: delineationCharacters].location == NSNotFound) isADelineationChar = 0;
    
    
    /*If this key is a character, spell-check the word that is currently being written:*/
    if(isADelineationChar == 0)
    {
        [self spellCheckCurrentWord];
    }
       
    /*otherwise, its the end of a word, so deal with the word as a whole:*/
    else
    {
        /*if the word should be corrected:*/
        if(currentWordCorrection != nil) [self replaceLastWordWithCorrection: currentWordCorrection];
        else if(currentWordShouldBeLearnt == 1)
        {
            [UITextChecker learnWord: [[self text] substringWithRange: [self getRangeOfLastTypedWordBeforeDelineator]]];
        }
        
        [theCorrectorView setHidden: YES];
        
        [currentWordCorrection release];
        currentWordCorrection = nil;
        currentWordShouldBeLearnt = 0;
        
        /*notify the parent object that a new word has finished and therefore to add the current state to its undo queue: (ONLY do this if at least one non-delineation character is before the delineation character that was just typed:)*/
        if((lastKeyEntered != nil)&&([lastKeyEntered rangeOfCharacterFromSet: delineationCharacters].location == NSNotFound)) [parentCallbackObject newUndoVersionRequired];
    }
    
    /*record this entry:*/
    lastKeyEntered = theKey;
    lastEnteredCharacter = theKey;
}

- (void)backspace
{
    /*can't backspace anywhere if we're at the very beginning!!*/
    if([self selectedRange].location == 0) return;
    
    /*if there is no text selected, then the single character before the current position should be deleted. If there is, then the selected text should be deleted:*/
    NSRange previousCharAsRange;
    if([self selectedRange].length > 0) previousCharAsRange = [self selectedRange];
    else previousCharAsRange = NSMakeRange([self selectedRange].location - 1, 1);
    
    
    [self setText: [[self text] stringByReplacingCharactersInRange: previousCharAsRange withString: @""]];
    [self setSelectedRange: NSMakeRange(previousCharAsRange.location, 0)];
    
    /*we might be in the middle of spell checking a word. If this is the case, then end checking here and now. Not appropriate if user is deleting:*/
    if(currentWordCorrection != nil)
    {
        [theCorrectorView setHidden: YES];
        
        [currentWordCorrection release];
        currentWordCorrection = nil;
        currentWordShouldBeLearnt = 0;
    }
}

/*At any point, returns the spacial position, in this view's coordinate system, of the cursor (top of the cursor)*/
- (CGPoint)getSpacialPosOfCursor;
{
    CGRect caretRect = [self caretRectForPosition: [[self selectedTextRange] start]];
    return CGPointMake(caretRect.origin.x, caretRect.origin.y + caretRect.size.height);
}


/*tracks back through the text to find the beginning of and isolate the current word, then checks to see whether it is being correctly spelt!*/
- (void)spellCheckCurrentWord
{
    /*If the user has already indicated that they don't want this word to be corrected, rather they want it to be learnt, then don't bother searching for corrections:*/
    if(currentWordShouldBeLearnt == 1) return;
    
    /*record current cursor position:*/
    int currentCursorPosition = [self selectedRange].location;
    
    /*first of all, find the NSRange ('rangeOfLastWord') of the last word in the text: this is the range from the last delineation char to the current point:*/
    NSRange lastDelChar = [[self text] rangeOfCharacterFromSet: delineationCharacters options: NSBackwardsSearch range: NSMakeRange(0, [self selectedRange].location )];
    if(lastDelChar.location >= INT32_MAX) lastDelChar.location = -1;
    
    NSRange rangeOfLastWord = NSMakeRange(lastDelChar.location + 1, [self selectedRange].location - (lastDelChar.location + 1));

    
    /*is this word spelt incorrectly? If so, replace it if possible with the correct spelling:*/
    NSRange rangeOfMisspellingsInString = [theTextChecker rangeOfMisspelledWordInString: [self text] range: rangeOfLastWord startingAt: 0 wrap: NO language: @"en"];
    
    if(rangeOfMisspellingsInString.location < INT32_MAX)
    {
        NSArray *spellCheckResult = [theTextChecker guessesForWordRange: rangeOfLastWord inString: [self text] language: @"en"];
        
        /*if there is a conceivable correct spelling, report!*/
        if([spellCheckResult count] > 0)
        {
            CGPoint cursorPos = [self getSpacialPosOfCursor];
            
            [theCorrectorView setWord: [spellCheckResult objectAtIndex: 0]];
            [theCorrectorView setFrame: CGRectMake(cursorPos.x, cursorPos.y, [theCorrectorView bounds].size.width, [theCorrectorView bounds].size.height)];
            [theCorrectorView setHidden: NO];
            
            currentWordCorrection = [[spellCheckResult objectAtIndex: 0] retain];
        }
        else 
        {
            currentWordCorrection = nil;
        }
    }
    else 
    {
        if([theCorrectorView isHidden] == NO) [theCorrectorView setHidden: YES];
        currentWordCorrection = nil;
    }
}

- (void)userRejectedWordCorrectionSuggestion
{
    [currentWordCorrection release];
    currentWordCorrection = nil;
    currentWordShouldBeLearnt = 1;
    [theCorrectorView setHidden: YES];
}

- (NSRange)getRangeOfLastTypedWordBeforeDelineator
{
    /*could have started with a space or a new line)*/
    NSRange lastDelChar = [[self text] rangeOfCharacterFromSet: delineationCharacters options: NSBackwardsSearch range: NSMakeRange(0, [self selectedRange].location - 1)];
    if(lastDelChar.location >= INT32_MAX) lastDelChar.location = -1;
    
    int startOfLastWord = lastDelChar.location + 1;
    
    return NSMakeRange(startOfLastWord, [self selectedRange].location - startOfLastWord - 1);
}

- (void)replaceLastWordWithCorrection: (NSString *)correctWord
{
    NSRange rangeOfLastWord = [self getRangeOfLastTypedWordBeforeDelineator];
    
    /*now we have the range of it, replace it with its correction:*/
    [self setText: [[self text] stringByReplacingCharactersInRange: rangeOfLastWord withString: correctWord]];
    
    /*make sure the cursor stays in the same position as before:*/
    [self setSelectedRange: NSMakeRange(rangeOfLastWord.location + [correctWord length] + 1, 0)];
}



- (void)setGlobalBrightness: (float)val_in;
{
    globalBrightness = val_in;
    
    if(globalBrightness >= KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        [self setTextColor: [UIColor blackColor]];
    }
    
    else 
    {
        [self setTextColor: [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.75 alpha: 1.0]];
    }
}

- (void)setParentCallbackObject: (touchCatcherView *)in_val
{
    parentCallbackObject = in_val;
}

- (void)callbackMethod
{
    [self textViewDidChangeSelection];
}

- (void)textViewDidChangeSelection
{
    /*if the user has just moved to a diffent position in the text, they might have typed a word without leaving a space or other delineating character after it, in which case a new undo version is required: */
    if(([self selectedRange].location != (lastSelectionPosition.location + 1))&&(lastEnteredCharacter != nil))
    {
        /*if the last entered character was not a delineation character, then the word was left 'unfinished', in which case, record this as an extra undo version:*/
        if([lastEnteredCharacter rangeOfCharacterFromSet: delineationCharacters].location == NSNotFound)
        {
            [parentCallbackObject newUndoVersionRequired];
            
            /*we might also be in the middle of spell checking a word. If this is the case, then end checking here and now. Not appropriate if user has moved to a different position:*/
            if(currentWordCorrection != nil)
            {
                [theCorrectorView setHidden: YES];
                
                [currentWordCorrection release];
                currentWordCorrection = nil;
                currentWordShouldBeLearnt = 0;
            }
        }
        
        [lastEnteredCharacter release];
        lastEnteredCharacter = nil;
    }
    
    
    lastSelectionPosition = [self selectedRange];
}

/*called by main view whenever the content of this view is switched to a different view. use this opportunity to reset some values:*/
- (void)didSwitchNote
{
    if(lastEnteredCharacter != nil)
    {
        [lastEnteredCharacter release];
        lastEnteredCharacter = nil;
    }
    lastSelectionPosition = NSMakeRange(-1, -1);
}



- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    
    return YES;
}

- (void)dealloc
{
    [theTextChecker release];
    
    [theCorrectorView removeFromSuperview];
    [theCorrectorView release];
    
    [delineationCharacters release];
    
    [theDelegate release];
    
    [super dealloc];
}

@end







@implementation correctorView

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        textContentView = [[UITextView alloc] initWithFrame: CGRectMake(3, -7, 300, 28)];
        [textContentView setBackgroundColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0]];
        [textContentView setFont: [UIFont fontWithName: @"Helvetica" size: 16.0]];
        [textContentView setEditable: NO];
        [textContentView setUserInteractionEnabled: NO];
        [self addSubview: textContentView];
        
        background_image = [utilities loadCGImageByName: @"correctorView"];
        
        [[self layer] setContents: (id)background_image];
        [[self layer] setContentsCenter: CGRectMake(0.15, 0.0, 0.65, 1.0)];
    }
    
    return self;
}

- (void)setWord: (NSString *)theWord_in
{
    [textContentView setText: theWord_in];
    
    [self setBounds: CGRectMake(0, 0, [self widthToFitWord] + 38, 33)];
}

- (int)widthToFitWord
{
    CGRect caretRectStart = [textContentView caretRectForPosition: [textContentView beginningOfDocument]];
    CGRect caretRectEnd = [textContentView caretRectForPosition: [textContentView endOfDocument]];
    
    return caretRectEnd.origin.x - caretRectStart.origin.x;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPos = [[touches anyObject] locationInView: self];
    
    if((self.bounds.size.width - touchPos.x) < 20) [[self superview] userRejectedWordCorrectionSuggestion];
}

- (void)dealloc
{
    [textContentView removeFromSuperview];
    [textContentView release];
    
    CGImageRelease(background_image);
    
    [super dealloc];
}

@end 

