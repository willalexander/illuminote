//
//  utilities.h
//  luminotes
//
//  Created by William Alexander on 21/04/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utilities : NSObject

+ (void)drawRoundedRect:(CGContextRef)drawingCGContextRef rect:(CGRect)rect radius:(float)rad;
+ (CGImageRef)loadCGImageByName: (NSString *)imageName;

@end
