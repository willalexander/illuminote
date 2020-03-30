//
//  utilities.m
//  luminotes
//
//  Created by William Alexander on 21/04/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "utilities.h"

@implementation utilities

+ (void)drawRoundedRect:(CGContextRef)drawingCGContextRef rect:(CGRect)rect radius:(float)rad
{
	CGContextBeginPath(drawingCGContextRef);
    
    /*move to top left corner - and start to the right of the rounded edge:*/
	CGContextMoveToPoint(drawingCGContextRef, rect.origin.x + rad, rect.origin.y);
	
	/*draw the rectangle from here:*/
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rect.size.width - rad, rect.origin.y);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + rad, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - rad);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - rad, rect.origin.y + rect.size.height, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x + rad, rect.origin.y + rect.size.height);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - rad, rad);
	CGContextAddLineToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y + rad);
	CGContextAddArcToPoint(drawingCGContextRef, rect.origin.x, rect.origin.y, rect.origin.x + rad, rect.origin.y, rad);
    
    CGContextClosePath(drawingCGContextRef);
    CGContextFillPath(drawingCGContextRef);
}

+ (CGImageRef)loadCGImageByName: (NSString *)imageName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource: imageName ofType: @"png"];
    CFStringRef pathString = CFStringCreateWithCString(NULL, [filePath UTF8String], kCFStringEncodingUTF8);
    CFURLRef URLRef = CFURLCreateWithFileSystemPath(NULL, pathString, kCFURLPOSIXPathStyle, NO);
    CGDataProviderRef provider = CGDataProviderCreateWithURL(URLRef);
    
    CGImageRef returnVal = CGImageCreateWithPNGDataProvider(provider, NULL, YES, kCGRenderingIntentDefault);
    
    CFRelease(pathString);
    CFRelease(URLRef);
    CGDataProviderRelease(provider);
    
    return returnVal;
}

@end
