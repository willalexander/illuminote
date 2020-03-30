//
//  touchCatcherView.m
//  luminotes
//
//  Created by William Alexander on 11/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "touchCatcherView.h"
#import "mainTextView.h"

#import "UIKit/UITextChecker.h"


@implementation touchCatcherView

- (id)initWithFrame:(CGRect)frame andInitialOrientation: (UIDeviceOrientation) initOrientation
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        [self setMultipleTouchEnabled: YES];
        
        /*so that changing orientation works properly:*/
        [self setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin]; 

        /*all buttons start in the 'up' position!*/
        notesButtonDown = 0;
        newButtonDown = 0;
        
        prevButtonDown = 0;
        emailButtonDown = 0;
        deleteButtonDown = 0;
        nextButtonDown = 0;
        
    
        /*the unorthodox single touch/double touch distinguishing setup requires these to be initialised:*/
        hitTestRecordPoint = CGPointMake(-1.0, -1.0);
        hasBecomeDoubleTap = 0;
        doubleTapIntervalInProgress = 0;
        
        /*obvious....*/
        globalBrightness = 1.0;
        
        
        
        /*load up and setup saved data if it exists. Start with a 'clean slate' if not:*/
        [self loadData];
 
        /*set up a timer to autosave everything regularly:*/
        autosaveTimer = [[NSTimer scheduledTimerWithTimeInterval: AUTOSAVE_INTERVAL target: self selector: @selector(autosaveCallback:) userInfo: nil repeats: YES] retain];
       
       
        /*create the undo system: (and give it one undo iteration to start with - the intial state of the current note..)*/
        undoPosition = 0;
        undoQueue = [[NSMutableArray arrayWithCapacity: 0] retain];
        [undoQueue addObject: [self getCurrentNote]];
        
       
        /*Create the fading darken layer over the top of everything:*/
        darkenLayer = [CALayer layer];
        [darkenLayer setFrame: CGRectMake(0, 44, 1024, 960)];
        [darkenLayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [darkenLayer setOpacity: 0.0];
        [[self layer] addSublayer: darkenLayer];
        
        
        /*Create the text field:*/
        theMainTextView = [[mainTextView alloc] initWithFrame: CGRectMake(261, 45, 758, 954)];
        [theMainTextView setText: [self getCurrentNote]];
        [theMainTextView setParentCallbackObject: self];
        [self addSubview: theMainTextView];
       
   
        
        /*Create the keyboard view:*/
        theCustomKeyboardView = [[customKeyboardView alloc] initWithFrame: CGRectMake(0, 0, 768, 264)];
        [theMainTextView setInputView: theCustomKeyboardView];
        [theCustomKeyboardView setTheTextView: theMainTextView];
        [theCustomKeyboardView setParentCallbackObject: self];
        
  
        
        
        /*Create the notes list view::*/
        theNotesListView = [[notesListView alloc] initWithFrame: CGRectMake(233, 25, 360, 610)];
        [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
        [theNotesListView setCurrentlySelectedNote: currentNote];
        [theNotesListView setHidden: YES];
        [self addSubview: theNotesListView];
        
 
        
        /*Create subviews for button dialogs:*/
        NSMutableArray *emailButtonDialogNames = [NSMutableArray arrayWithCapacity: 2];
        [emailButtonDialogNames addObject: @"email note"];
        [emailButtonDialogNames addObject: @"print note"];
        
        NSMutableArray *deleteButtonDialogNames = [NSMutableArray arrayWithCapacity: 1];
        [deleteButtonDialogNames addObject: @"delete note"];
        
        emailButtonDialogView = [[buttonDialogView alloc] initWithFrame: CGRectMake(294, 825, 210, 100) andButtonNames: emailButtonDialogNames];
        deleteButtonDialogView = [[buttonDialogView alloc] initWithFrame: CGRectMake(274, 905, 210, 100) andButtonNames: deleteButtonDialogNames];
        
        [emailButtonDialogView setHidden: YES];
        [deleteButtonDialogView setHidden: YES];
        
        [emailButtonDialogView setCallbackObject: self];
        [deleteButtonDialogView setCallbackObject: self];
        
        [self addSubview: emailButtonDialogView];
        [self addSubview: deleteButtonDialogView];
       
        
        /*load graphics:*/
        toolbar_main_image = [utilities loadCGImageByName: @"toolbar_main"];
        toolbar_notesButton_image = [utilities loadCGImageByName: @"toolbar_notesButton"];
        toolbar_notesButton_down_image = [utilities loadCGImageByName: @"toolbar_notesButton_down"];
        toolbar_newButton_image = [utilities loadCGImageByName: @"toolbar_newButton"];
        toolbar_newButton_down_image = [utilities loadCGImageByName: @"toolbar_newButton_down"];
        toolbar_inverted_main_image = [utilities loadCGImageByName: @"toolbar_inverted_main"];
        toolbar_inverted_notesButton_image = [utilities loadCGImageByName: @"toolbar_inverted_notesButton"];
        toolbar_inverted_notesButton_down_image = [utilities loadCGImageByName: @"toolbar_inverted_notesButton_down"];
        toolbar_inverted_newButton_image = [utilities loadCGImageByName: @"toolbar_inverted_newButton"];
        toolbar_inverted_newButton_down_image = [utilities loadCGImageByName: @"toolbar_inverted_newButton_down"];
        
        notesButton_default_off_image = [[UIImage imageNamed: @"toolbar_notesButton"] retain]; 
        notesButton_default_on_image = [[UIImage imageNamed: @"toolbar_notesButton_down"] retain];
        notesButton_intermediate_off_image = [[UIImage imageNamed: @"toolbar_intermediate_notesButton"] retain];
        notesButton_intermediate_on_image = [[UIImage imageNamed: @"toolbar_intermediate_notesButton_down"] retain];
        notesButton_inverted_off_image = [[UIImage imageNamed: @"toolbar_inverted_notesButton"] retain];
        notesButton_inverted_on_image = [[UIImage imageNamed: @"toolbar_inverted_notesButton_down"] retain];
     
        newButton_default_off_image = [utilities loadCGImageByName: @"newButton_default_off"];
        newButton_default_on_image = [utilities loadCGImageByName: @"newButton_default_on"];
        newButton_inverted_off_image = [utilities loadCGImageByName: @"newButton_inverted_off"];
        newButton_inverted_on_image = [utilities loadCGImageByName: @"newButton_inverted_on"];
   
        prevButton_default_off_image = [utilities loadCGImageByName: @"prevButton_default_off"];
        prevButton_default_on_image = [utilities loadCGImageByName: @"prevButton_default_on"];
        prevButton_inverted_off_image = [utilities loadCGImageByName: @"prevButton_inverted_off"];
        prevButton_inverted_on_image = [utilities loadCGImageByName: @"prevButton_inverted_on"];
        
        emailButton_default_off_image = [utilities loadCGImageByName: @"emailButton_default_off"];
        emailButton_default_on_image = [utilities loadCGImageByName: @"emailButton_default_on"];
        emailButton_inverted_off_image = [utilities loadCGImageByName: @"emailButton_inverted_off"];
        emailButton_inverted_on_image = [utilities loadCGImageByName: @"emailButton_inverted_on"];
    
        deleteButton_default_off_image = [utilities loadCGImageByName: @"deleteButton_default_off"];
        deleteButton_default_on_image = [utilities loadCGImageByName: @"deleteButton_default_on"];
        deleteButton_inverted_off_image = [utilities loadCGImageByName: @"deleteButton_inverted_off"];
        deleteButton_inverted_on_image = [utilities loadCGImageByName: @"deleteButton_inverted_on"];
        
        nextButton_default_off_image = [utilities loadCGImageByName: @"nextButton_default_off"];
        nextButton_default_on_image = [utilities loadCGImageByName: @"nextButton_default_on"];
        nextButton_inverted_off_image = [utilities loadCGImageByName: @"nextButton_inverted_off"];
        nextButton_inverted_on_image = [utilities loadCGImageByName: @"nextButton_inverted_on"];
        
        paperTexture_image = [utilities loadCGImageByName: @"paper"];
        

        
        /*the four control buttons are instances of the 'dimmableButton' class:*/
        prevButton = [[dimmableButton alloc] initWithFrame: CGRectMake(492, 957, 62, 42) andDefault: prevButton_default_off_image defaultDown: prevButton_default_on_image defaultDown: prevButton_inverted_off_image defaultDown: prevButton_inverted_on_image];
        [prevButton setButtonBodyRect: CGRectMake(7, 5, 48, 28) andCornerRadius: 2];
        [prevButton setCallbackObject: self];
        
        emailButton = [[dimmableButton alloc] initWithFrame: CGRectMake(570, 957, 62, 42) andDefault: emailButton_default_off_image defaultDown: emailButton_default_on_image defaultDown: emailButton_inverted_off_image defaultDown: emailButton_inverted_on_image];
        [emailButton setButtonBodyRect: CGRectMake(7, 5, 48, 28) andCornerRadius: 2];
        [emailButton setCallbackObject: self];
        
        deleteButton = [[dimmableButton alloc] initWithFrame: CGRectMake(648, 957, 62, 42) andDefault: deleteButton_default_off_image defaultDown: deleteButton_default_on_image defaultDown: deleteButton_inverted_off_image defaultDown: deleteButton_inverted_on_image];
        [deleteButton setButtonBodyRect: CGRectMake(7, 5, 48, 28) andCornerRadius: 2];
        [deleteButton setCallbackObject: self];
        
        nextButton = [[dimmableButton alloc] initWithFrame: CGRectMake(726, 957, 62, 42) andDefault: nextButton_default_off_image defaultDown: nextButton_default_on_image defaultDown: nextButton_inverted_off_image defaultDown: nextButton_inverted_on_image];
        [nextButton setButtonBodyRect: CGRectMake(7, 5, 48, 28) andCornerRadius: 2];
        [nextButton setCallbackObject: self];
        
        [self addSubview: prevButton];
        [self addSubview: emailButton];
        [self addSubview: deleteButton];
        [self addSubview: nextButton];

        
        /*for lazy loading reasons, we need to be aware of when the draw() method is first used:*/
        firstDraw = 0;
    
      
        /*We need to keep track of exactly where the keyboard is, so register to receive all the relevant notifications:*/
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillChangeFrame:) name: UIKeyboardWillChangeFrameNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object: nil];
        
        
        /*Lay everything out based on the intial orientation:*/
        [self rearrangeInterfaceForNewOrientation: initOrientation];
    }
    

    
    return self;
}


- (void)setAppDelegate: (UIResponder *)theAppDel
{
    appDel = theAppDel;
}


- (void)loadData
{
    /*create URL of archive date file:*/
    archiveURL = [[[[[NSFileManager defaultManager] URLsForDirectory: NSLibraryDirectory inDomains: NSUserDomainMask] objectAtIndex: 0] URLByAppendingPathComponent: @"archiveData.dat"] retain];
      
    /*attempt to load data from the file:*/
    archiveDictionary = [NSMutableDictionary dictionaryWithContentsOfURL: archiveURL];
    
    /*if archive exists, then previous data has been saved. Load it and use it:*/
    if(archiveDictionary != nil)
    {
        [archiveDictionary retain];
        
        arrayOfNotes = [[archiveDictionary objectForKey: @"arrayOfNotes"] retain];
        
        currentNote = [[archiveDictionary objectForKey: @"currentNote"] intValue];
        
        
        /*if for some reason, the array is empty, then the user has no saved notes, so start afresh:*/
        if([arrayOfNotes count] == 0)
        {
            [arrayOfNotes addObject: @""];
            currentNote = 0;
        }
    }
    
    /*if not, then start with a clean slate. (empty array of notes)*/
    else
    {
        arrayOfNotes = [[NSMutableArray arrayWithCapacity: 0] retain];
        [arrayOfNotes addObject: @""];
        
        currentNote = 0;
        
        archiveDictionary = [[NSMutableDictionary dictionaryWithCapacity: 2] retain];
        [archiveDictionary setObject: arrayOfNotes forKey: @"arrayOfNotes"];
    }
}


- (void)archiveAllData
{
    /*discard this current note if it has nothing in it:*/
    if([[theMainTextView text] length] == 0) [arrayOfNotes removeObjectAtIndex: currentNote];
    
    /*if not, then save the current note's text intn the array:*/
    else [arrayOfNotes replaceObjectAtIndex: currentNote withObject: [theMainTextView text]];
    
    
    /*now do the archiving:*/
    [archiveDictionary removeObjectForKey: @"currentNote"];
    
    /*for logistical reasons above, the value of 'currentNote' might be larger than the number of notes that we're saving. if so, then set it to the last note:*/
    if(currentNote < [arrayOfNotes count]) [archiveDictionary setValue: [NSNumber numberWithInt: currentNote] forKey: @"currentNote"];
    else [archiveDictionary setValue: [NSNumber numberWithInt: [arrayOfNotes count] - 1] forKey: @"currentNote"];
        
    [archiveDictionary writeToURL: archiveURL atomically: YES];
    
    
    /*if the current note was empty, re-insert an empty string in its place in the array:*/
    if([[theMainTextView text] length] == 0) [arrayOfNotes insertObject: @"" atIndex: currentNote];
}

- (void)autosaveCallback: (NSTimer *)theTimer
{
    [self archiveAllData];
}


- (void)globalBrightnessChanged: (float)newGlobalBrightness
{
    mainTextView *myMainTextSubview = [[self subviews] objectAtIndex: 0];

    /*adjust this view's interface elements*/
    [darkenLayer setOpacity: 1.0 - newGlobalBrightness];
    [darkenLayer removeAllAnimations];
    [self setNeedsDisplayInRect: CGRectMake(0, 0, [self bounds].size.width, 55)];
    
    

    /*notify relevant sub elements of global brightness change (for effiency's sake, only change their brightness if they are visible)*/
    [myMainTextSubview setGlobalBrightness: newGlobalBrightness];
    
    /*notify the notes list view (if visible)*/
    if([theNotesListView isHidden] == NO) [theNotesListView setGlobalBrightness: newGlobalBrightness];
    
    /*notify the email button dialog view (if active)*/
    if([emailButtonDialogView isHidden] == NO)
    {
        /*..and not obscured by the keyboard:*/
        if((currentKeyboardFrame.origin.y > ([emailButtonDialogView frame].origin.y + [emailButtonDialogView frame].size.height))||((currentKeyboardFrame.origin.y + currentKeyboardFrame.size.height) < [emailButtonDialogView frame].origin.y))
        {
            [emailButtonDialogView setGlobalBrightness: newGlobalBrightness];
        }
    }
    
    /*notify the delete button dialog view (if active)*/
    if([deleteButtonDialogView isHidden] == NO)
    {
        /*..and not obscured by the keyboard:*/
        if((currentKeyboardFrame.origin.y > ([deleteButtonDialogView frame].origin.y + [deleteButtonDialogView frame].size.height))||((currentKeyboardFrame.origin.y + currentKeyboardFrame.size.height) < [deleteButtonDialogView frame].origin.y))
        {
            [deleteButtonDialogView setGlobalBrightness: newGlobalBrightness];
        }
    }
    
    /*notify the prev/email/delete/next buttons (if not obscured)*/
    if((currentKeyboardFrame.origin.y > ([prevButton frame].origin.y + [prevButton frame].size.height))||((currentKeyboardFrame.origin.y + currentKeyboardFrame.size.height) < [prevButton frame].origin.y))
    {
        [prevButton setGlobalBrightness: newGlobalBrightness];
        [emailButton setGlobalBrightness: newGlobalBrightness];
        [deleteButton setGlobalBrightness: newGlobalBrightness];
        [nextButton setGlobalBrightness: newGlobalBrightness];
    }

    
    if([theMainTextView isFirstResponder] == YES) [theCustomKeyboardView setGlobalBrightness: newGlobalBrightness];
}

- (void)checkGlobalBrightnessOfExposedElements
{
    /*if one's wrong, they're all wrong. So just check the 'prev' button*/
    if([prevButton getGlobalBrightness] != globalBrightness)
    {
        [prevButton setGlobalBrightness: globalBrightness];
        [emailButton setGlobalBrightness: globalBrightness];
        [deleteButton setGlobalBrightness: globalBrightness];
        [nextButton setGlobalBrightness: globalBrightness];
    }
    
    /*dialog views only need doing if they're visible:*/
    if([emailButtonDialogView isHidden] == NO) 
    {
        if([emailButtonDialogView getGlobalBrightness] != globalBrightness) [emailButtonDialogView setGlobalBrightness: globalBrightness];
    }
    
    if([deleteButtonDialogView isHidden] == NO) 
    {
        if([deleteButtonDialogView getGlobalBrightness] != globalBrightness) [deleteButtonDialogView setGlobalBrightness: globalBrightness];
    }
}


- (NSString *)getCurrentNote
{
    return [arrayOfNotes objectAtIndex: currentNote];
}

- (void)switchToNoteNumber: (int)numToSwitchTo;
{
    /*only save current note back to the list if it is not empty:*/
    if([[theMainTextView text] length] != 0) [arrayOfNotes replaceObjectAtIndex: currentNote withObject: [theMainTextView text]];
    else [arrayOfNotes removeObjectAtIndex: currentNote];
    
    /*in the instance that there is only one empty note left and therefore the note we're switching to is the same note as the current note, then we've just deleted the last note from arrayOfNotes. Put it back:*/
    if([arrayOfNotes count] == 0) [arrayOfNotes addObject: @""];
    
    [theMainTextView setText: [arrayOfNotes objectAtIndex: numToSwitchTo]];
    [theMainTextView didSwitchNote];
    currentNote = numToSwitchTo;
    
    /*clear the undo queue:*/
    undoPosition = 0;
    [undoQueue removeAllObjects];
    [undoQueue addObject: [arrayOfNotes objectAtIndex: numToSwitchTo]];
}

- (void)noteWasSelected: (int)num
{
    [self switchToNoteNumber: num];
    
    /*if we're in portrait mode, then hide the notes list view after a nice delay:*/
    if(currentDeviceOrientationSimple == 0) [NSTimer scheduledTimerWithTimeInterval: HIDE_NOTES_LIST_VIEW_DELAY target: self selector: @selector(hideNotesListViewTimeout:) userInfo: nil repeats: NO];
}


/*if there are any steps further back to go, then go one back:*/
- (void)requestUndo
{
    if(undoPosition > 0)
    {
         undoPosition--;
        [theMainTextView setText: [undoQueue objectAtIndex: undoPosition]];
    }
}

/*if there are any steps further forward to go, then go one forward:*/
- (void)requestRedo
{
    if((undoPosition < (UNDO_QUEUE_CAPACITY - 1))&&(undoPosition < (int)([undoQueue count] - 1)))
    {
        undoPosition++;
        [theMainTextView setText: [undoQueue objectAtIndex: undoPosition]];
    }
}

/*a significant enough change has been made by the user to warrant a new undo version:*/
- (void)newUndoVersionRequired
{
    /*if we're at the end of the queue and need to add a new version, then shift all the versions back one and add this new one at the end:*/
    if(undoPosition == (UNDO_QUEUE_CAPACITY - 1))
    {
        [undoQueue removeObjectAtIndex: 0];
        [undoQueue insertObject: [theMainTextView text] atIndex: undoPosition];
    }
    
    /*if this is just a normal version addition, then add it to the current next position:*/
    else
    {
        /*if we're adding a new version after having backtracked, then all the data ahead of us is now junk, so remove it:*/
        if((int)([undoQueue count]) > (undoPosition + 1))
        {
            int currentUndoQueueCount = [undoQueue count];
            for(int i = undoPosition + 1; i < currentUndoQueueCount; i++) [undoQueue removeObjectAtIndex: (undoPosition + 1)];
        }
        
        undoPosition++;
        [undoQueue insertObject: [theMainTextView text] atIndex: undoPosition];
    }
}


- (void)hideNotesListViewTimeout: (NSTimer *)theTimer
{
    [theNotesListView setHidden: YES];
}


- (void)setupPortraitConfiguration
{
    [self setFrame: CGRectMake(0, 20, 768, 1004)];
    [self setNeedsDisplay];
}

- (void)setupLandscapeConfiguration
{
    [self setFrame: CGRectMake(0, 20, 1024, 764)];
    [self setNeedsDisplay];
}

- (void)setDeviceOrientationSimple: (int)currentDeviceOrientationNormal
{
    /*Only change from the current recorded orientation if the new one is one of the main four:*/
    if((currentDeviceOrientationNormal != UIDeviceOrientationPortrait)&&(currentDeviceOrientationNormal != UIDeviceOrientationPortraitUpsideDown)&&(currentDeviceOrientationNormal != UIDeviceOrientationLandscapeLeft)&&(currentDeviceOrientationNormal != UIDeviceOrientationLandscapeRight)) return;
    
    if((currentDeviceOrientationNormal == UIDeviceOrientationPortrait)||(currentDeviceOrientationNormal == UIDeviceOrientationPortraitUpsideDown)) currentDeviceOrientationSimple = 0;
    
    else currentDeviceOrientationSimple = 1;
}


- (void)keyboardDidShow: (NSNotification *)theNotification
{
}

- (void)keyboardWillChangeFrame: (NSNotification *)theNotification
{
    currentKeyboardFrame = [[[theNotification userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    /*take orientation into account:*/
    if(currentDeviceOrientationSimple == 1)
    {
        float tmp = currentKeyboardFrame.origin.x;
        currentKeyboardFrame.origin.x  = currentKeyboardFrame.origin.y;
        currentKeyboardFrame.origin.y = tmp;
        
        tmp = currentKeyboardFrame.size.width;
        currentKeyboardFrame.size.width = currentKeyboardFrame.size.height;
        currentKeyboardFrame.size.height = tmp;
    }
    
    /*detect if this keyboard was just hidden:*/
    if((currentKeyboardFrame.origin.y == 1024)||(currentKeyboardFrame.origin.y == 768)) [self checkGlobalBrightnessOfExposedElements];
}

- (void)keyboardDidHide: (NSNotification *)theNotification
{
}



- (void)appWillResignActive
{
    /*This is a good time to archive off all the user's current notes:*/
    [self archiveAllData];
    
    /*let the keyboard know that the app is about to stop being access - it may have half finished events it needs to clean up:*/
    [theCustomKeyboardView appWillResignActive];
}

- (void)rearrangeInterfaceForNewOrientation: (int)newOrientation
{
    [self setDeviceOrientationSimple: newOrientation];
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)callbackWithValue: (int)val sender: (id)sender;
{
    if((sender == prevButton)&&(val == 0))
    {
        if(currentNote > 0) [self switchToNoteNumber: currentNote - 1];
        
        /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
        [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
        [theNotesListView setCurrentlySelectedNote: currentNote];
    }
    
    if((sender == emailButton)&&(val == 0))
    {
        if([emailButtonDialogView isHidden] == NO) [emailButtonDialogView setHidden: YES];
        else if([emailButtonDialogView isHidden] == YES) 
        {
            /*we're about to make this dialog view visible. check first that its global brightness val is up-to-date. if not, update it and redraw:*/
            if([emailButtonDialogView getGlobalBrightness] != globalBrightness) [emailButtonDialogView setGlobalBrightness: globalBrightness];
            [emailButtonDialogView setHidden: NO];
        }
        
        /*hide the delete button dialog view if it happens to be visible!*/
        if([deleteButtonDialogView isHidden] == NO) [deleteButtonDialogView setHidden: YES];
    }
    
    if(sender == emailButtonDialogView)
    {
        [myViewController presentEmailUIWithContents: [arrayOfNotes objectAtIndex: currentNote]];
        
        [emailButtonDialogView setHidden: YES];
    }
    
    if((sender == deleteButton)&&(val == 0))
    {
        if([deleteButtonDialogView isHidden] == NO) [deleteButtonDialogView setHidden: YES];
        else if([deleteButtonDialogView isHidden] == YES)
        {
            /*we're about to make this dialog view visible. check first that its global brightness val is up-to-date. if not, update it and redraw:*/
            if([deleteButtonDialogView getGlobalBrightness] != globalBrightness) [deleteButtonDialogView setGlobalBrightness: globalBrightness];
            [deleteButtonDialogView setHidden: NO];
        }
        
        /*hide the email button dialog view if it happens to be visible!*/
        if([emailButtonDialogView isHidden] == NO) [emailButtonDialogView setHidden: YES];
    }
    
    if(sender == deleteButtonDialogView)
    {
        /*if only one note left, then empty it rather than deleting it:*/
        if([arrayOfNotes count] == 1)
        {
            [arrayOfNotes replaceObjectAtIndex: currentNote withObject: @""];
            [theMainTextView setText: @""];
        }
        
        else
        {
            [arrayOfNotes removeObjectAtIndex: currentNote];
            
            /*if the last note on the list was deleted, then we'll need to move backwards to the new last note:*/
            if(currentNote == [arrayOfNotes count]) currentNote -= 1;
            
            /*display the note adjacent to the one just deleted:*/
            [theMainTextView setText: [arrayOfNotes objectAtIndex: currentNote]];
        }
        
        [deleteButtonDialogView setHidden: YES];
        
        /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
        [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
        [theNotesListView setCurrentlySelectedNote: currentNote];
    }
    
    if((sender == nextButton)&&(val == 0))
    {
        if(currentNote < ([arrayOfNotes count] - 1)) [self switchToNoteNumber: currentNote + 1];
        
        /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
        [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
        [theNotesListView setCurrentlySelectedNote: currentNote];
    }
}

- (float)getGlobalBrightness
{
    return globalBrightness;
}

- (void)addMainTextView: (mainTextView *)theView
{
    theMainTextView = theView;
    [self addSubview: theView];
}

- (void)setMyViewController: (mainViewController *)theController
{
    myViewController = theController;
}




- (void)layoutSubviews
{
    /*If we're in portrait orientation:*/
    if(currentDeviceOrientationSimple == 0)
    {
        [theMainTextView setFrame: CGRectMake(261, 45, 758, 954)];
        
        [theCustomKeyboardView setFrame: CGRectMake(0, 0, 768, 264)];
        [theCustomKeyboardView isInPortrait];
        [theCustomKeyboardView setNeedsDisplay];
        
        [theNotesListView setUIOrientation: 0];
        [theNotesListView setFrame: CGRectMake(233, 25, 360, 610)];
        [theNotesListView setNeedsLayout];
        [theNotesListView setHidden: YES];
        
        [prevButton setFrame: CGRectMake(492, 957, 62, 42)];
        [emailButton setFrame: CGRectMake(570, 957, 62, 42)];
        [deleteButton setFrame: CGRectMake(648, 957, 62, 42)];
        [nextButton setFrame: CGRectMake(726, 957, 62, 42)];
        [emailButtonDialogView setFrame: CGRectMake(497, 880, 210, 100)];
        [deleteButtonDialogView setFrame: CGRectMake(576, 880, 210, 100)];
        
        /*if the keyboard is currently hidden, we'll have to do our own job of updating its frame:*/
        if([theMainTextView isFirstResponder] == NO) currentKeyboardFrame = CGRectMake(0, 1024, 0, 0);
    }
    
    else 
    {
        [theMainTextView setFrame: CGRectMake(326, 45, 693, 698)];
        
        [theCustomKeyboardView setFrame: CGRectMake(0, 0, 1024, 352)];
        [theCustomKeyboardView isInLandscape];
        [theCustomKeyboardView setNeedsDisplay];
        
        /*update the notes list view before making it visible:*/
        [theNotesListView setUIOrientation: 1];
        [theNotesListView setFrame: CGRectMake(0, 0, 395, 748)];
        [theNotesListView setNeedsLayout];
        [theNotesListView setHidden: NO];
        
        /*the notes list view may need its global brightness updating:*/
        if([theNotesListView getGlobalBrightness] != globalBrightness) [theNotesListView setGlobalBrightness: globalBrightness];
        
        
        [prevButton setFrame: CGRectMake(525, 701, 62, 42)];
        [emailButton setFrame: CGRectMake(603, 701, 62, 42)];
        [deleteButton setFrame: CGRectMake(681, 701, 62, 42)];
        [nextButton setFrame: CGRectMake(759, 701, 62, 42)];
        [emailButtonDialogView setFrame: CGRectMake(530, 624, 210, 100)];
        [deleteButtonDialogView setFrame: CGRectMake(613, 624, 210, 100)];
        
        /*if the keyboard is currently hidden, we'll have to do our own job of updating its frame:*/
        if([theMainTextView isFirstResponder] == NO) currentKeyboardFrame = CGRectMake(0, 768, 0, 0);
    }
    
}



/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.*/
- (void)drawRect:(CGRect)rect
{
    /*make sure we know what the current device orientation is:*/
    currentDeviceOrientation = [[UIDevice currentDevice] orientation];
    [self setDeviceOrientationSimple: currentDeviceOrientation];
    
    /*Get the drawing context:*/
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(theContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(theContext, [self bounds]);
    
    /*if this is the  first draw, put all the big slow images into cache-able CGLayers:*/
    if(firstDraw == 0)
    {
        paperTexture_layer = CGLayerCreateWithContext(theContext, CGSizeMake(768, 949), NULL);
        paperTexture_layerContext = CGLayerGetContext(paperTexture_layer);
        
        CGContextSaveGState(paperTexture_layerContext);
        CGContextScaleCTM(paperTexture_layerContext, 1.0, -1.0);
        CGContextTranslateCTM(paperTexture_layerContext, 0, -949);
        CGContextDrawImage(paperTexture_layerContext, CGRectMake(0, 0, 768, 949), paperTexture_image);
        CGContextRestoreGState(paperTexture_layerContext);
        
        firstDraw = 1;
    }
    
    /*Draw the paper background:*/
    CGContextDrawLayerInRect(theContext, CGRectMake(0, 55, 1024, 949), paperTexture_layer);
    
    
    /*Draw the tool bar:*/
    CGContextSaveGState(theContext);
    CGContextScaleCTM(theContext, 1.0, -1.0);
    CGContextTranslateCTM(theContext, 0, -1004);
    
    CGContextDrawImage(theContext, CGRectMake(0, 949, 1024, 55), toolbar_main_image);
    
    CGContextRestoreGState(theContext);
    
    /*Draw the Notes button:*/
    //if(notesButtonDown == 0) CGContextDrawImage(theContext, CGRectMake(256, 949, 60, 55), toolbar_notesButton_image);
    if(notesButtonDown == 0) [notesButton_default_off_image drawAtPoint: CGPointMake(256, 0)];
    //else CGContextDrawImage(theContext, CGRectMake(256, 949, 60, 55), toolbar_notesButton_down_image);
    else [notesButton_default_on_image drawAtPoint: CGPointMake(256, 0)];
    
    /*Draw the New Button:*/
    CGContextSaveGState(theContext);
    CGContextScaleCTM(theContext, 1.0, -1.0);
    CGContextTranslateCTM(theContext, 0, -1004);
    
    if(newButtonDown == 0) CGContextDrawImage(theContext, CGRectMake(984, 949, 40, 55), toolbar_newButton_image);
    else CGContextDrawImage(theContext, CGRectMake(984, 949, 40, 55), toolbar_newButton_down_image);
    
    CGContextRestoreGState(theContext);
    
    
    /*Darken for brightness:*/
    CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0 - globalBrightness);
    CGContextFillRect(theContext, CGRectMake(0, 0, [self bounds].size.width, 44));
    
    
    /*illuminate the tool bar when below backlight global brightness threshold:*/
    if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        CGContextSaveGState(theContext);
        CGContextScaleCTM(theContext, 1.0, -1.0);
        CGContextTranslateCTM(theContext, 0, -1004);
        
        CGContextSetBlendMode(theContext, kCGBlendModeScreen);
        
        CGContextDrawImage(theContext, CGRectMake(0, 949, 256, 55), toolbar_inverted_main_image);
        CGContextDrawImage(theContext, CGRectMake(316, 949, 668, 55), toolbar_inverted_main_image);
        
        CGContextRestoreGState(theContext);
        
        if(notesButtonDown == 0)
        {
            [notesButton_intermediate_off_image drawAtPoint: CGPointMake(256, 0)];
            [notesButton_inverted_off_image drawAtPoint: CGPointMake(256, 0) blendMode: kCGBlendModeNormal alpha: (1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD))];
        }
        else
        {
            [notesButton_intermediate_on_image drawAtPoint: CGPointMake(256, 0)];
            [notesButton_inverted_on_image drawAtPoint: CGPointMake(256, 0) blendMode: kCGBlendModeNormal alpha: (1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD))];
        }
        
        
        CGContextSaveGState(theContext);
        CGContextScaleCTM(theContext, 1.0, -1.0);
        CGContextTranslateCTM(theContext, 0, -1004);
        
        CGContextSetBlendMode(theContext, kCGBlendModeScreen);
        
        //if(notesButtonDown == 0) CGContextDrawImage(theContext, CGRectMake(256, 949, 60, 55), toolbar_inverted_notesButton_image);
        //else CGContextDrawImage(theContext, CGRectMake(256, 949, 60, 55), toolbar_inverted_notesButton_down_image);
        
        if(newButtonDown == 0) CGContextDrawImage(theContext, CGRectMake(984, 949, 40, 55), toolbar_inverted_newButton_image);
        else CGContextDrawImage(theContext, CGRectMake(984, 949, 40, 55), toolbar_inverted_newButton_down_image);
        
        CGContextRestoreGState(theContext);
    }
    
    //[notesButton_intermediate_off_image drawAtPoint: CGPointMake(256, 0)];
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    /*If there is a 'double tap interval' in progess, said interval may have expired. Check to see. if so (more than 0.1 seconds passed), then terminate the interval*/
    if(doubleTapIntervalInProgress == 1)
    {
        if(([[NSDate date] timeIntervalSinceReferenceDate] - [doubleTapIntervalStartDate timeIntervalSinceReferenceDate]) > 0.1)
        {   
            doubleTapIntervalInProgress = 0;
            hasBecomeDoubleTap = 0;
            
            [doubleTapIntervalStartDate release];
            
            [theMainTextView setScrollEnabled: YES];
        }   
    }
    
    /*if it has been decided that we are in the middle of a double-tap event, then pass no touches down to subviews, pass automactically pass to self:*/
    if(hasBecomeDoubleTap == 1) return self;
    
    
    /*only start the double-finger distinguishing stuff if this hit has fallen into the main text view: (otherwise just stick to inherited parent behaviour)*/
    if([super hitTest: point withEvent: event] == theMainTextView)
    {
        /*if there is no double tap interval in progress, then one must start now with this touch, so start it:*/
        if(doubleTapIntervalInProgress == 0)
        {      
            doubleTapIntervalInProgress = 1;
            hitTestRecordPoint = point;
            doubleTapIntervalStartDate = [[NSDate date] retain];
        }
        
        /*if a double tap interval IS in progress, this touch might have a different location to others during the interval in which case a 'double tap' has occurred:*/
        else
        {
            if((point.x != hitTestRecordPoint.x)||(point.y != hitTestRecordPoint.y))
            {
                hasBecomeDoubleTap = 1;
                
                [theMainTextView setScrollEnabled: NO];
                
                return self;
            }
            
        }
    }
    
    /*if we get this far, then resort to inherited parent behaviour*/
    return [super hitTest: point withEvent: event];
}


- (void)collectingTouchesTimeout
{
    hitTestRecordPoint = CGPointMake(-1.0, -1.0);
    hasBecomeDoubleTap = 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int buttonPressed = -1;
    
    /*If two touches have started, then this is a two-finger-swipe-to-change-brightness event:*/
    if([[event allTouches] count] == 2)
    {
        /*record the screen 'y' position at which the event starts (average of the two touches' y positions)*/
        touchEventStartPos = 0.5 * ([[[[event allTouches] allObjects] objectAtIndex: 0] locationInView: self].y + [[[[event allTouches] allObjects] objectAtIndex: 1] locationInView: self].y);
        
        previousGlobalBrightness = globalBrightness;
    }
    
    /*if just one touch, then this is just a normal touch down:*/
    if([[event allTouches] count] == 1)
    {
        CGPoint touchPoint = [[[[event allTouches] allObjects] objectAtIndex: 0] locationInView: self];
        
        /*Notes button?*/
        if((currentDeviceOrientationSimple == 0)&&(touchPoint.x >= 261)&&(touchPoint.x <= 311)&&(touchPoint.y >= 5)&&(touchPoint.y <= 35))
        {
            buttonPressed = 0;
            notesButtonDown = 1;
            [self setNeedsDisplayInRect: CGRectMake(256, 0, 60, 55)];
            
            if([theNotesListView isHidden] == YES)
            {
                /*update the current array of notes before showing the list:*/
                [arrayOfNotes replaceObjectAtIndex: currentNote withObject: [theMainTextView text]];
                [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
                [theNotesListView setCurrentlySelectedNote: currentNote];
                
                /*make sure that the notes list view has the up-to-date global brightness setting:*/
                if([theNotesListView getGlobalBrightness] != globalBrightness) [theNotesListView setGlobalBrightness: globalBrightness];
                
                [theNotesListView setHidden: NO];
            }
            
            else [theNotesListView setHidden: YES];
        }
        
        /*New Note Button?*/
        if((touchPoint.x >= 989)&&(touchPoint.x <= 1019)&&(touchPoint.y >= 5)&&(touchPoint.y <= 35))
        {
            [appDel callbackMethod];
            
            buttonPressed = 1;
            newButtonDown = 1;
            [self setNeedsDisplayInRect: CGRectMake(984, 0, 40, 55)];
            
            /*do nothing if the current note is empty:*/
            if([[theMainTextView text] length] != 0)
            {
                [arrayOfNotes replaceObjectAtIndex: currentNote withObject: [theMainTextView text]];
                
                [arrayOfNotes addObject: @""];
                currentNote = [arrayOfNotes count] - 1;
                
                /*clear the undo queue:*/
                undoPosition = 0;
                [undoQueue removeAllObjects];
                [undoQueue addObject: @""];
                
                /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
                [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
                [theNotesListView setCurrentlySelectedNote: currentNote];
                
                [theMainTextView setText: @""];
            }
        }
        
        /*'move-back-a-note' button?*/
        if(((currentDeviceOrientationSimple == 0)&&(touchPoint.x >= 242)&&(touchPoint.x <= 292)&&(touchPoint.y >= 964)&&(touchPoint.y <= 994)) ||
           ((currentDeviceOrientationSimple == 1)&&(touchPoint.x >= 540)&&(touchPoint.x <= 590)&&(touchPoint.y >= 708)&&(touchPoint.y <= 738))
           )
        {
            buttonPressed = 2;
            
            if(currentNote > 0) [self switchToNoteNumber: currentNote - 1];
            
            prevButtonDown = 1;
            
            /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
            [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
            [theNotesListView setCurrentlySelectedNote: currentNote];
        }
        
        /*'email/print' button?*/
        if(((currentDeviceOrientationSimple == 0)&&(touchPoint.x >= 327)&&(touchPoint.x <= 372)&&(touchPoint.y >= 964)&&(touchPoint.y <= 994)) ||
           ((currentDeviceOrientationSimple == 1)&&(touchPoint.x >= 618)&&(touchPoint.x <= 668)&&(touchPoint.y >= 708)&&(touchPoint.y <= 738))
           )
        {
            buttonPressed = 3;
            
            emailButtonDown = 1;
            
             if([emailButtonDialogView isHidden] == NO) [emailButtonDialogView setHidden: YES];
            else if([emailButtonDialogView isHidden] == YES) 
            {
                /*we're about to make this dialog view visible. check first that its global bightnes val is up-to-date. if not, update it and redraw:*/
                if([emailButtonDialogView getGlobalBrightness] != globalBrightness) [emailButtonDialogView setGlobalBrightness: globalBrightness];
                [emailButtonDialogView setHidden: NO];
            }
        }
        
        /*'delete' button?*/
        if(((currentDeviceOrientationSimple == 0)&&(touchPoint.x >= 403)&&(touchPoint.x <= 453)&&(touchPoint.y >= 964)&&(touchPoint.y <= 994)) ||
           ((currentDeviceOrientationSimple == 1)&&(touchPoint.x >= 696)&&(touchPoint.x <= 746)&&(touchPoint.y >= 708)&&(touchPoint.y <= 738))
           )
        {
            buttonPressed = 4;
            
            deleteButtonDown = 1;
            
            if([deleteButtonDialogView isHidden] == NO) [deleteButtonDialogView setHidden: YES];
            else if([deleteButtonDialogView isHidden] == YES) [deleteButtonDialogView setHidden: NO];
        }
        
        /*'move-forward-a-note' button?*/
        if(((currentDeviceOrientationSimple == 0)&&(touchPoint.x >= 496)&&(touchPoint.x <= 546)&&(touchPoint.y >= 964)&&(touchPoint.y <= 994)) ||
           ((currentDeviceOrientationSimple == 1)&&(touchPoint.x >= 774)&&(touchPoint.x <= 824)&&(touchPoint.y >= 708)&&(touchPoint.y <= 738))
           )
        {
            buttonPressed = 6;
            
            nextButtonDown = 1;
            
            if(currentNote < ([arrayOfNotes count] - 1)) [self switchToNoteNumber: currentNote + 1];
            
            /*if we're in landscape mode and therefore the notes list view is visible, update it and redisplay it:*/
            [theNotesListView setCurrentArrayOfNotes: arrayOfNotes];
            [theNotesListView setCurrentlySelectedNote: currentNote];
        }
        
        if(buttonPressed != 0) if(currentDeviceOrientationSimple == 0) [theNotesListView setHidden: YES];
        if(buttonPressed != 3) [emailButtonDialogView setHidden: YES];
        if(buttonPressed != 4) [deleteButtonDialogView setHidden: YES];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*only respond if this is a still a two-touch event:*/
    if([[event allTouches] count] != 2) return;
    
    /*calculate the 'position' of the average y position of the two touches:*/
    float touchesAverage = 0.5 * ([[[[event allTouches] allObjects] objectAtIndex: 0] locationInView: self].y + [[[[event allTouches] allObjects] objectAtIndex: 1] locationInView: self].y);
    
    /*the event's 'brightness value' is 0.0 at the bottom of the screen, 1.0 at the top, but equal to the current brightness at whatever y-position at which the user started the touch event:*/
    float eventBrightness;
    float eventPortion;
    
    if(touchesAverage < touchEventStartPos)
    {
        eventPortion = 1.0 - (touchesAverage / touchEventStartPos);
        eventBrightness = (1.0 - eventPortion)*(previousGlobalBrightness) + (eventPortion)*(1.0);
    }
    else
    {
        int viewHeight = 1004;
        if(currentDeviceOrientationSimple == 1) viewHeight = 748;
        
        eventPortion = 1.0 - ((touchesAverage - touchEventStartPos) / ( viewHeight - touchEventStartPos));
        eventBrightness = eventPortion * previousGlobalBrightness;
    }
    
    globalBrightness = eventBrightness;
    [self globalBrightnessChanged: globalBrightness];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(notesButtonDown == 1)
    {
        notesButtonDown = 0;
        [self setNeedsDisplayInRect: CGRectMake(256, 0, 60, 55)];
    }
    
    if(newButtonDown == 1)
    {
        newButtonDown = 0;
        [self setNeedsDisplayInRect: CGRectMake(984, 0, 40, 55)];
    }
    
    if(prevButtonDown == 1) 
    {
        prevButtonDown = 0;
    }
    
    if(emailButtonDown == 1) 
    {
        emailButtonDown = 0;
    }
    
    if(deleteButtonDown == 1) 
    {
        deleteButtonDown = 0;
    }
    if(nextButtonDown == 1) 
    {
        nextButtonDown = 0;
    }
}

- (void)preDealloc
{
    [autosaveTimer invalidate];
    [autosaveTimer release];
}

- (void)dealloc
{
    [archiveURL release];
    
    [arrayOfNotes release];
    [archiveDictionary release];
    
    
    [undoQueue removeAllObjects];
    [undoQueue release];
    
    [darkenLayer removeFromSuperlayer];
    
    [theMainTextView removeFromSuperview];
    [theMainTextView release];
    
    [theCustomKeyboardView removeFromSuperview];
    [theCustomKeyboardView release];
    
    [theNotesListView removeFromSuperview];
    [theNotesListView release];
    
    [emailButtonDialogView removeFromSuperview];
    [emailButtonDialogView release];
    [deleteButtonDialogView removeFromSuperview];
    [deleteButtonDialogView release];
    
    CGImageRelease(toolbar_main_image);
    CGImageRelease(toolbar_notesButton_image);
    CGImageRelease(toolbar_notesButton_down_image);
    CGImageRelease(toolbar_newButton_image);
    CGImageRelease(toolbar_newButton_down_image);
    CGImageRelease(toolbar_inverted_main_image);
    CGImageRelease(toolbar_inverted_notesButton_image);
    CGImageRelease(toolbar_inverted_notesButton_down_image);
    CGImageRelease(toolbar_inverted_newButton_image);
    CGImageRelease(toolbar_inverted_newButton_down_image);
    
    CGImageRelease(notesButton_default_off_image);
    CGImageRelease(notesButton_default_on_image);
    CGImageRelease(notesButton_inverted_off_image);
    CGImageRelease(notesButton_inverted_on_image);
    
    CGImageRelease(newButton_default_off_image);
    CGImageRelease(newButton_default_on_image);
    CGImageRelease(newButton_inverted_off_image);
    CGImageRelease(newButton_inverted_on_image);
    
    CGImageRelease(prevButton_default_off_image);
    CGImageRelease(prevButton_default_on_image);
    CGImageRelease(prevButton_inverted_off_image);
    CGImageRelease(prevButton_inverted_on_image);
    
    CGImageRelease(emailButton_default_off_image);
    CGImageRelease(emailButton_default_on_image);
    CGImageRelease(emailButton_inverted_off_image);
    CGImageRelease(emailButton_inverted_on_image);
    
    CGImageRelease(deleteButton_default_off_image);
    CGImageRelease(deleteButton_default_on_image);
    CGImageRelease(deleteButton_inverted_off_image);
    CGImageRelease(deleteButton_inverted_on_image);
    
    CGImageRelease(nextButton_default_off_image);
    CGImageRelease(nextButton_default_on_image);
    CGImageRelease(nextButton_inverted_off_image);
    CGImageRelease(nextButton_inverted_on_image);
    
    CGImageRelease(paperTexture_image);
    
    
    [prevButton removeFromSuperview];
    [prevButton release];
    
    [emailButton removeFromSuperview];
    [emailButton release];
    
    [deleteButton removeFromSuperview];
    [deleteButton release];
    
    [nextButton removeFromSuperview];
    [nextButton release];
    
    
    [super dealloc];
}

@end







@implementation dimmableButton

- (id)initWithFrame:(CGRect)frame andDefault:(CGImageRef)image_a defaultDown:(CGImageRef)image_b defaultDown:(CGImageRef)image_c defaultDown:(CGImageRef)image_d
{
    self = [super initWithFrame: frame];
    [self setBackgroundColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0]];
    
    default_image = image_a;
    default_down_image = image_b;
    inverted_image = image_c;
    inverted_down_image = image_d;
    
    firstDraw = 0;
    buttonIsDown = 0;
    globalBrightness = 1.0;
    
    return self;
}

- (void)setButtonBodyRect: (CGRect)bodyRect_in andCornerRadius: (int)cornerRadius_in;
{
    bodyRect = bodyRect_in;
    cornerRadius = cornerRadius_in;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    if(firstDraw == 0)
    {
        default_image_layer = CGLayerCreateWithContext(theContext, CGSizeMake([self bounds].size.width, [self bounds].size.height), NULL);
        layerContext = CGLayerGetContext(default_image_layer);
        CGContextSaveGState(layerContext);
        CGContextScaleCTM(layerContext, 1.0, -1.0);
        CGContextTranslateCTM(layerContext, 0, -1.0 * [self bounds].size.height);
        CGContextDrawImage(layerContext, [self bounds], default_image);
        CGContextRestoreGState(layerContext);
        
        
        default_down_image_layer = CGLayerCreateWithContext(theContext, CGSizeMake([self bounds].size.width, [self bounds].size.height), NULL);
        layerContext = CGLayerGetContext(default_down_image_layer);
        CGContextSaveGState(layerContext);
        CGContextScaleCTM(layerContext, 1.0, -1.0);
        CGContextTranslateCTM(layerContext, 0, -1.0 * [self bounds].size.height);
        CGContextDrawImage(layerContext, [self bounds], default_down_image);
        CGContextRestoreGState(layerContext);
        
        
        inverted_image_layer = CGLayerCreateWithContext(theContext, CGSizeMake([self bounds].size.width, [self bounds].size.height), NULL);
        layerContext = CGLayerGetContext(inverted_image_layer);
        CGContextSaveGState(layerContext);
        CGContextScaleCTM(layerContext, 1.0, -1.0);
        CGContextTranslateCTM(layerContext, 0, -1.0 * [self bounds].size.height);
        CGContextDrawImage(layerContext, [self bounds], inverted_image);
        CGContextRestoreGState(layerContext);
        
        
        inverted_down_image_layer = CGLayerCreateWithContext(theContext, CGSizeMake([self bounds].size.width, [self bounds].size.height), NULL);
        layerContext = CGLayerGetContext(inverted_down_image_layer);
        CGContextSaveGState(layerContext);
        CGContextScaleCTM(layerContext, 1.0, -1.0);
        CGContextTranslateCTM(layerContext, 0, -1.0 * [self bounds].size.height);
        CGContextDrawImage(layerContext, [self bounds], inverted_down_image);
        CGContextRestoreGState(layerContext);
        
        firstDraw = 1;
    }
    
    CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0 - globalBrightness);
    
    if(buttonIsDown == 0) 
    {
        CGContextDrawLayerInRect(theContext, rect, default_image_layer);
        [utilities drawRoundedRect: theContext rect: bodyRect radius: cornerRadius];
        
        if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD)
        {
            CGContextSaveGState(theContext);
            CGContextSetBlendMode(theContext, kCGBlendModeScreen);
            CGContextDrawLayerInRect(theContext, rect, inverted_image_layer);
            CGContextRestoreGState(theContext);
        }
    }
    
    else     
    {
        CGContextDrawLayerInRect(theContext, rect, default_down_image_layer);
        [utilities drawRoundedRect: theContext rect: CGRectMake(bodyRect.origin.x, bodyRect.origin.y + 1, bodyRect.size.width, bodyRect.size.height) radius: cornerRadius];
        
        if(globalBrightness <= KEYBOARD_BACKLIGHT_ON_THRESHOLD)
        {
            CGContextSaveGState(theContext);
            CGContextSetBlendMode(theContext, kCGBlendModeScreen);
            CGContextDrawLayerInRect(theContext, rect, inverted_down_image_layer);
            CGContextRestoreGState(theContext);
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    buttonIsDown = 1;
    [self setNeedsDisplay];
    
    [callBackObject callbackWithValue: 1 sender: self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    buttonIsDown = 0;
    [self setNeedsDisplay];
    
    [callBackObject callbackWithValue: 0 sender: self];
}

- (void)setCallbackObject: (touchCatcherView *)val_in;
{
    callBackObject = val_in;
}

- (void)setGlobalBrightness:(float)newGlobalBrightness
{
    globalBrightness = newGlobalBrightness;
    [self setNeedsDisplay];
}

- (float)getGlobalBrightness
{
    return globalBrightness;
}


- (void)dealloc
{
    CGLayerRelease(default_image_layer);
    CGLayerRelease(default_down_image_layer);
    CGLayerRelease(inverted_image_layer);
    CGLayerRelease(inverted_down_image_layer);
    
    [super dealloc];
}


@end
