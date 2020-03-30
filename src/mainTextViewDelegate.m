//
//  mainTextViewDelegate.m
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "mainTextViewDelegate.h"

@implementation mainTextViewDelegate

- (void)setCallbackObj: (NSObject *)theObj;
{
    callbackObj = theObj;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    int insertionPoint = [textView selectedRange].location; 
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [callbackObj callbackMethod];
}

- (void)dealloc
{
    [super dealloc];
}

@end
