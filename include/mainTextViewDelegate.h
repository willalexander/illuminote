//
//  mainTextViewDelegate.h
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mainTextViewDelegate : NSObject <UITextViewDelegate>
{
    NSObject *callbackObj;
}

- (void)setCallbackObj: (NSObject *)theObj;

@end
