//
//  customKeyboardView.m
//  luminotes
//
//  Created by William Alexander on 05/02/2012.
//  Copyright (c) 2012 Framestore-CFC. All rights reserved.
//

#import "customKeyboardView.h"


@implementation customKeyboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        globalBrightness = 1.0;
        
        currentOrientation = 0;
        
        // Initialization code
        [self setMultipleTouchEnabled: YES];
        
        /*Load up the keyboard images for drawing:*/
        NSArray *k_o_str = [NSArray arrayWithObjects: @"", @"_lscap", nil];
        NSArray *k_m_str = [NSArray arrayWithObjects: @"_default", @"_numbers", @"_symbols", nil];
        NSArray *k_p_str = [NSArray arrayWithObjects: @"_up", @"_down", nil];
        NSArray *k_l_str = [NSArray arrayWithObjects: @"_lit", @"_intermediate", @"_illuminated", nil];
        
        
        for(int orient = 0; orient <= 1; orient++)
        {
            for(int mode = 0; mode <= 2; mode++)
            {
                for(int pressed = 0; pressed <= 1; pressed++)
                {
                    for(int light = 0; light <= 2; light++)
                    {
                        NSString *imageName =  [[[[@"keyboard" stringByAppendingString: [k_m_str objectAtIndex: mode]] stringByAppendingString: [k_l_str objectAtIndex: light]] stringByAppendingString: [k_p_str objectAtIndex: pressed]] stringByAppendingString: [k_o_str objectAtIndex: orient]];
                        
                        keyboardImages[orient][mode][pressed][light] = [utilities loadCGImageByName: imageName];
                    }
                }
            }
        }
        
        
        /*load up the various shift key images:*/
        k_o_str = [NSArray arrayWithObjects: @"_ptrat", @"_lscap", nil];
        NSArray *k_s_str = [NSArray arrayWithObjects: @"_left", @"_right", nil];
        k_m_str = [NSArray arrayWithObjects: @"_on", @"_held", nil];
        
        for(int orient = 0; orient <= 1; orient++)
        {
            for(int side = 0; side <= 1; side++)
            {
                for(int light = 0; light <= 2; light++)
                {
                    for(int mode = 0; mode <= 1; mode++)
                    {
                        NSString *imageName = [[[[@"shiftKey" stringByAppendingString: [k_o_str objectAtIndex: orient]] stringByAppendingString: [k_s_str objectAtIndex: side]] stringByAppendingString: [k_l_str objectAtIndex: light]] stringByAppendingString: [k_m_str objectAtIndex: mode]];
         
                        shiftKeyImage[orient][side][light][mode] = [utilities loadCGImageByName: imageName];
                    }
                }
            }
        }    
        
        /*create hierarchical array of CGRects that desribe the the rectangles of the left and right shift keys on the portrait/landscape keyboards:*/
        shiftKeyRects = [NSArray arrayWithObjects:  [NSArray arrayWithObjects: [NSValue valueWithCGRect: CGRectMake(3, 68, 63, 63)], [NSValue valueWithCGRect: CGRectMake(682, 68, 83, 63)], nil],
                                                    [NSArray arrayWithObjects: [NSValue valueWithCGRect: CGRectMake(0, 90, 91, 86)], [NSValue valueWithCGRect: CGRectMake(907, 90, 115, 86)], nil],
                        nil];
        
        [shiftKeyRects retain];
        
        
        
        
        /*set up the geometric data about key positions that allows for efficient determination of which key a touch has pressed:*/
        keyCells_numberOfKeyBoundariesInRow = (int *)(malloc(4 * sizeof(int)));
        keyCells_numberOfKeyBoundariesInRow[0] = 12;
        keyCells_numberOfKeyBoundariesInRow[1] = 11;
        keyCells_numberOfKeyBoundariesInRow[2] = 12;
        keyCells_numberOfKeyBoundariesInRow[3] = 5;
       
        
        keyCells_boundaries = (int **)(malloc(4 * sizeof(int *)));
        
        keyCells_boundaries[0] = (int *)(malloc(12 * sizeof(int)));
        keyCells_boundaries[1] = (int *)(malloc(11 * sizeof(int)));
        keyCells_boundaries[2] = (int *)(malloc(12 * sizeof(int)));
        keyCells_boundaries[3] = (int *)(malloc(5 * sizeof(int)));
        
        keyCells_boundaries[0][0] = 0;
        keyCells_boundaries[0][1] = 69;
        keyCells_boundaries[0][2] = 138;
        keyCells_boundaries[0][3] = 208;
        keyCells_boundaries[0][4] = 278;
        keyCells_boundaries[0][5] = 345;
        keyCells_boundaries[0][6] = 415;
        keyCells_boundaries[0][7] = 486;
        keyCells_boundaries[0][8] = 555;
        keyCells_boundaries[0][9] = 625;
        keyCells_boundaries[0][10] = 695;
        keyCells_boundaries[0][11] = 768;
        
        keyCells_boundaries[1][0] = 0;
        keyCells_boundaries[1][1] = 99;
        keyCells_boundaries[1][2] = 168;
        keyCells_boundaries[1][3] = 237;
        keyCells_boundaries[1][4] = 306;
        keyCells_boundaries[1][5] = 374;
        keyCells_boundaries[1][6] = 442;
        keyCells_boundaries[1][7] = 513;
        keyCells_boundaries[1][8] = 579;
        keyCells_boundaries[1][9] = 651;
        keyCells_boundaries[1][10] = 768;
        
        keyCells_boundaries[2][0] = 0;
        keyCells_boundaries[2][1] = 68;
        keyCells_boundaries[2][2] = 136;
        keyCells_boundaries[2][3] = 205;
        keyCells_boundaries[2][4] = 274;
        keyCells_boundaries[2][5] = 340;
        keyCells_boundaries[2][6] = 409;
        keyCells_boundaries[2][7] = 475;
        keyCells_boundaries[2][8] = 544;
        keyCells_boundaries[2][9] = 612;
        keyCells_boundaries[2][10] = 680;
        keyCells_boundaries[2][11] = 768;
        
        keyCells_boundaries[3][0] = 0;
        keyCells_boundaries[3][1] = 205;
        keyCells_boundaries[3][2] = 612;
        keyCells_boundaries[3][3] = 699;
        keyCells_boundaries[3][4] = 768;
        
        keyRows_boundaries[0] = 0;
        keyRows_boundaries[1] = 68;
        keyRows_boundaries[2] = 132;
        keyRows_boundaries[3] = 196;
        keyRows_boundaries[4] = 264;
        
       
        
        
        
        /*landscape cells:*/
        keyCells_boundaries_l = (int **)(malloc(4 * sizeof(int *)));
        
        keyCells_boundaries_l[0] = (int *)(malloc(12 * sizeof(int)));
        keyCells_boundaries_l[1] = (int *)(malloc(11 * sizeof(int)));
        keyCells_boundaries_l[2] = (int *)(malloc(12 * sizeof(int)));
        keyCells_boundaries_l[3] = (int *)(malloc(5 * sizeof(int)));
        
        keyCells_boundaries_l[0][0] = 0;
        keyCells_boundaries_l[0][1] = 93;
        keyCells_boundaries_l[0][2] = 186;
        keyCells_boundaries_l[0][3] = 279;
        keyCells_boundaries_l[0][4] = 372;
        keyCells_boundaries_l[0][5] = 465;
        keyCells_boundaries_l[0][6] = 558;
        keyCells_boundaries_l[0][7] = 651;
        keyCells_boundaries_l[0][8] = 744;
        keyCells_boundaries_l[0][9] = 837;
        keyCells_boundaries_l[0][10] = 930;
        keyCells_boundaries_l[0][11] = 1024;
        
        keyCells_boundaries_l[1][0] = 0;
        keyCells_boundaries_l[1][1] = 130;
        keyCells_boundaries_l[1][2] = 222;
        keyCells_boundaries_l[1][3] = 313;
        keyCells_boundaries_l[1][4] = 405;
        keyCells_boundaries_l[1][5] = 497;
        keyCells_boundaries_l[1][6] = 589;
        keyCells_boundaries_l[1][7] = 681;
        keyCells_boundaries_l[1][8] = 773;
        keyCells_boundaries_l[1][9] = 864;
        keyCells_boundaries_l[1][10] = 1024;
        
        keyCells_boundaries_l[2][0] = 0;
        keyCells_boundaries_l[2][1] = 90;
        keyCells_boundaries_l[2][2] = 181;
        keyCells_boundaries_l[2][3] = 271;
        keyCells_boundaries_l[2][4] = 362;
        keyCells_boundaries_l[2][5] = 452;
        keyCells_boundaries_l[2][6] = 543;
        keyCells_boundaries_l[2][7] = 633;
        keyCells_boundaries_l[2][8] = 724;
        keyCells_boundaries_l[2][9] = 814;
        keyCells_boundaries_l[2][10] = 905;
        keyCells_boundaries_l[2][11] = 1024;
        
        keyCells_boundaries_l[3][0] = 0;
        keyCells_boundaries_l[3][1] = 271;
        keyCells_boundaries_l[3][2] = 814;
        keyCells_boundaries_l[3][3] = 933;
        keyCells_boundaries_l[3][4] = 1024;
        
        keyRows_boundaries_l[0] = 0;
        keyRows_boundaries_l[1] = 91;
        keyRows_boundaries_l[2] = 177;
        keyRows_boundaries_l[3] = 263;
        keyRows_boundaries_l[4] = 352;
        
      
        
        /*create huge multi-dimensional array for the values associated with each key on the keyboard:*/
        keyCellValues = [NSMutableArray arrayWithCapacity: 1];
        [keyCellValues addObject: [NSMutableArray arrayWithCapacity: 1]];
        [keyCellValues addObject: [NSMutableArray arrayWithCapacity: 1]];
        [keyCellValues addObject: [NSMutableArray arrayWithCapacity: 1]];
        [keyCellValues addObject: [NSMutableArray arrayWithCapacity: 1]];
        
        /*DEFAULT STATE KEY VALUES: (MOSTLY LOWER CASE LETTERS)*/
        [[keyCellValues objectAtIndex: 0] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 0] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 0] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 0] addObject: [NSMutableArray arrayWithCapacity: 1]];
        
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"q"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"w"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"e"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"r"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"t"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"y"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"u"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"i"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"o"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"p"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 0] addObject: @"BACKSPACE"];
        
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"a"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"s"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"d"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"f"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"g"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"h"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"j"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"k"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"l"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 1] addObject: @"\n"];
        
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"SHIFT"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"z"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"x"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"c"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"v"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"b"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"n"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"m"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @","];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"."];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 2] addObject: @"SHIFT"];
        
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 3] addObject: @"NUMBERS"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 3] addObject: @" "];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 3] addObject: @"NUMBERS"];
        [[[keyCellValues objectAtIndex: 0] objectAtIndex: 3] addObject: @"QUIT"];
        
        
        /*'SHIFT ON' STATE KEY VALUES: (MOSTLY UPPER CASE LETTERS)*/
        [[keyCellValues objectAtIndex: 1] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 1] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 1] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 1] addObject: [NSMutableArray arrayWithCapacity: 1]];
        
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"Q"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"W"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"E"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"R"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"T"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"Y"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"U"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"I"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"O"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"P"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 0] addObject: @"BACKSPACE"];
        
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"A"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"S"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"D"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"F"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"G"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"H"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"J"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"K"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"L"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 1] addObject: @"\n"];
        
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"SHIFT"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"Z"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"X"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"C"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"V"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"B"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"N"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"M"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"!"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"?"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 2] addObject: @"SHIFT"];
        
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 3] addObject: @"NUMBERS"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 3] addObject: @" "];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 3] addObject: @"NUMBERS"];
        [[[keyCellValues objectAtIndex: 1] objectAtIndex: 3] addObject: @"QUIT"];
        
        
        /*'NUMBERS' STATE KEY VALUES:*/
        [[keyCellValues objectAtIndex: 2] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 2] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 2] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 2] addObject: [NSMutableArray arrayWithCapacity: 1]];
        
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"1"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"2"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"3"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"4"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"5"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"6"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"7"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"8"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"9"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"0"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 0] addObject: @"BACKSPACE"];
        
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"-"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"/"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @":"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @";"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"("];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @")"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"£"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"&"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"@"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 1] addObject: @"\n"];
        
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"SYMBOLS"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"UNDO"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"UNDO"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"."];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @","];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"?"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"!"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"'"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"\""];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"NIL"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 2] addObject: @"SYMBOLS"];
        
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 3] addObject: @"LETTERS"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 3] addObject: @" "];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 3] addObject: @"LETTERS"];
        [[[keyCellValues objectAtIndex: 2] objectAtIndex: 3] addObject: @"QUIT"];
        
        
        /*'SYMBOLS' STATE KEY VALUES:*/
        [[keyCellValues objectAtIndex: 3] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 3] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 3] addObject: [NSMutableArray arrayWithCapacity: 1]];
        [[keyCellValues objectAtIndex: 3] addObject: [NSMutableArray arrayWithCapacity: 1]];
        
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"["];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"]"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"{"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"}"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"#"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"%"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"^"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"*"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"+"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"="];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 0] addObject: @"BACKSPACE"];
        
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"_"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"\\"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"|"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"~"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"<"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @">"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"€"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"$"]; 
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"‡"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 1] addObject: @"\n"];
        
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"NUMBERS"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"REDO"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"REDO"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"."];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @","];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"?"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"!"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"'"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"\""];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"NIL"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 2] addObject: @"NUMBERS"];
        
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 3] addObject: @"LETTERS"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 3] addObject: @" "];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 3] addObject: @"LETTERS"];
        [[[keyCellValues objectAtIndex: 3] objectAtIndex: 3] addObject: @"QUIT"];
        
        [keyCellValues retain];
        
       
        
        
        /*we start with the keyboard in 'default' state (default key set)*/
        keyboardState = 0;
        
        /*shift key(s) start 'up':*/
        shiftKeyDown = 0;
        
        
        /*Use this variable top record double taps:*/
        doubleTapInProgress = 0;
        
        /*When multiple touches hit the keyboard, we'll need to keep track of the all separately:*/
        recordedTouches = [[NSMutableArray arrayWithCapacity: 10] retain];
        
        keysDown_rowNum = [[NSMutableArray arrayWithCapacity: 10] retain];
        keysDown_keyCellNum = [[NSMutableArray arrayWithCapacity: 10] retain];
        keysDown_StrVal = [[NSMutableArray arrayWithCapacity: 10] retain];
      
        
        keysDown = [NSMutableArray arrayWithCapacity: 0];
        [keysDown retain];
        
        shiftState = 0;
        
        shiftKeyLeft_portrait_rect = CGRectMake(3, 133, 63, 63);
        shiftKeyRight_portrait_rect = CGRectMake(682, 133, 83, 63);
        
        shiftKeyLeft_landscape_rect = CGRectMake(0, 176, 91, 86);
        shiftKeyRight_landscape_rect = CGRectMake(907, 176, 115, 86);
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
        
        
        
        
        /*Create and setup all the CALayers that allow for various keyboard blending:*/
        blendSublayer = [CALayer layer];
        [blendSublayer setFrame: [[self layer] bounds]];
        [blendSublayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [blendSublayer setOpacity: 0.0];
        [blendSublayer removeAllAnimations];
         
        [[self layer] addSublayer: blendSublayer];
        
        
        keyDownLayer = [CALayer layer];
        [keyDownLayer setFrame: [[self layer] bounds]];
        [keyDownLayer setHidden: YES];
        keyDownLayer_blendSublayer = [CALayer layer];
        [keyDownLayer_blendSublayer setFrame: [[self layer] bounds]];
        [keyDownLayer_blendSublayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [keyDownLayer_blendSublayer setHidden: YES];
        
        
        keyDownMaskLayer = [CALayer layer];
        [keyDownMaskLayer setFrame: [[self layer] bounds]];
        keyDownMaskLayer_b = [CALayer layer];
        [keyDownMaskLayer_b setFrame: [[self layer] bounds]];
         
        [keyDownLayer setMask: keyDownMaskLayer];
        [keyDownLayer_blendSublayer setMask: keyDownMaskLayer_b];
        [[self layer] addSublayer: keyDownLayer];
        [[self layer] addSublayer: keyDownLayer_blendSublayer];
        
        
        keyDownMaskLayers = [[NSMutableArray arrayWithCapacity: 1] retain];
        keyDownMaskLayers_b = [[NSMutableArray arrayWithCapacity: 1] retain];
        
        
        /*Shift Key Layers:*/
        shiftKey_left_layer = [CALayer layer];
        shiftKey_right_layer = [CALayer layer];
        [shiftKey_left_layer setHidden: YES];
        [shiftKey_right_layer setHidden: YES];
        [[self layer] addSublayer: shiftKey_left_layer];
        [[self layer] addSublayer: shiftKey_right_layer];
        
        
        shiftKey_left_layer_blendSublayer = [CALayer layer];
        shiftKey_right_layer_blendSublayer = [CALayer layer];   
        [shiftKey_left_layer_blendSublayer setHidden: YES];
        [shiftKey_right_layer_blendSublayer setHidden: YES];
        [shiftKey_left_layer_blendSublayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [shiftKey_right_layer_blendSublayer setBackgroundColor: [[UIColor blackColor] CGColor]];
        [[self layer] addSublayer: shiftKey_left_layer_blendSublayer];
        [[self layer] addSublayer: shiftKey_right_layer_blendSublayer];
        
        
        [self setAllSubLayersToCorrectSize];
        
         
        [self drawKeyboard];
    }
    return self;
}


- (void)setTheTextView: (mainTextView *)theTextView_in
{
    theTextView = theTextView_in;
}

- (void)setParentCallbackObject: (touchCatcherView *)val_in
{
    parentCallbackObject = val_in;
}

- (void)setGlobalBrightness: (float)val_in
{
    /*record new global brightness info*/
    globalBrightness = val_in;
    

    /*Now adjust the keyboard based on this:*/
    [self drawKeyboard];
    
    //
    //[blendSublayer setOpacity: (1.0 - globalBrightness)];
    //[blendSublayer removeAllAnimations];
    
    //[self setNeedsDisplay];
}


- (void)drawKeyboard
{
    /*easy-access info about the current state of things:*/
    int keyboardState_simple = keyboardState - 1;
    if(keyboardState_simple == -1) keyboardState_simple = 0;
    
    
    
    /*if we're in the normal 'lit' lighting stage, then just draw the classic keyboard and darken it based on the global brightness.*/
    if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        [[self layer] setContents: keyboardImages[currentOrientation][keyboardState_simple][0][0]];
        [blendSublayer setContents: nil];
        [keyDownLayer setContents: keyboardImages[currentOrientation][keyboardState_simple][1][0]];
        [keyDownLayer_blendSublayer setContents: nil];
        
        [blendSublayer setOpacity: 1.0 - globalBrightness];
        [keyDownLayer_blendSublayer setOpacity: 1.0 - globalBrightness];
    }
        
    else
    {
        [[self layer] setContents: keyboardImages[currentOrientation][keyboardState_simple][0][1]];
        [blendSublayer setContents: keyboardImages[currentOrientation][keyboardState_simple][0][2]];
        [keyDownLayer setContents: keyboardImages[currentOrientation][keyboardState_simple][1][1]];
        [keyDownLayer_blendSublayer setContents: keyboardImages[currentOrientation][keyboardState_simple][1][2]];
        
        [blendSublayer setOpacity: 1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];
        [keyDownLayer_blendSublayer setOpacity: 1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];   
    }
    
    [[self layer] removeAllAnimations];
    [blendSublayer removeAllAnimations];
    [keyDownLayer removeAllAnimations];
    [keyDownLayer_blendSublayer removeAllAnimations];
    
    [self setShiftKeysForCurrentGlobalBrightness];
}

- (void)shiftStateChanged
{
    /*if shift is off, hide any shift override:*/
    if((shiftKeyDown == 0)||(keyboardState > 1))
    {
        [shiftKey_left_layer setHidden: YES];
        [shiftKey_right_layer setHidden: YES];
        [shiftKey_left_layer_blendSublayer setHidden: YES];
        [shiftKey_right_layer_blendSublayer setHidden: YES];
    }
    
    /*if down or held, show the the shift key layers and give them the right image:*/
    else 
    {
        [shiftKey_left_layer setHidden: NO];
        [shiftKey_right_layer setHidden: NO];
        [shiftKey_left_layer_blendSublayer setHidden: NO];
        [shiftKey_right_layer_blendSublayer setHidden: NO];
        
        [self setShiftKeysForCurrentGlobalBrightness];
    }
    
    [shiftKey_left_layer removeAllAnimations];
    [shiftKey_right_layer removeAllAnimations];
    [shiftKey_left_layer_blendSublayer removeAllAnimations];
    [shiftKey_right_layer_blendSublayer removeAllAnimations];
}

- (void)setShiftKeysForCurrentGlobalBrightness
{
    /*of the shift state is off, then we don't need to do anything:*/
    if(shiftKeyDown == 0) return;
    
    
    /*easy-access info about the current state of things:*/
    int keyboardState_simple = keyboardState - 1;
    if(keyboardState_simple == -1) keyboardState_simple = 0;
    
    
    /*if we're in the normal 'lit' lighting stage, then just draw the classic keyboard and darken it based on the global brightness.*/
    if(globalBrightness > KEYBOARD_BACKLIGHT_ON_THRESHOLD)
    {
        [shiftKey_left_layer setContents: shiftKeyImage[currentOrientation][0][0][shiftKeyDown - 1]];
        [shiftKey_right_layer setContents: shiftKeyImage[currentOrientation][1][0][shiftKeyDown - 1]];
        [shiftKey_left_layer_blendSublayer setContents: nil];
        [shiftKey_right_layer_blendSublayer setContents: nil];
        
        [shiftKey_left_layer_blendSublayer setOpacity: 1.0 - globalBrightness];
        [shiftKey_right_layer_blendSublayer setOpacity: 1.0 - globalBrightness];
    }
    
    else
    {
        [shiftKey_left_layer setContents: shiftKeyImage[currentOrientation][0][1][shiftKeyDown - 1]];
        [shiftKey_right_layer setContents: shiftKeyImage[currentOrientation][1][1][shiftKeyDown - 1]];
        [shiftKey_left_layer_blendSublayer setContents: shiftKeyImage[currentOrientation][0][2][shiftKeyDown - 1]];
        [shiftKey_right_layer_blendSublayer setContents: shiftKeyImage[currentOrientation][1][2][shiftKeyDown - 1]];
        
        [shiftKey_left_layer_blendSublayer setOpacity: 1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];
        [shiftKey_right_layer_blendSublayer setOpacity: 1.0 - (globalBrightness / KEYBOARD_BACKLIGHT_ON_THRESHOLD)];
    }
    
    [shiftKey_left_layer removeAllAnimations];
    [shiftKey_right_layer removeAllAnimations];
    [shiftKey_left_layer_blendSublayer removeAllAnimations];
    [shiftKey_right_layer_blendSublayer removeAllAnimations];
}


- (void)keyDown: (CGRect)keyDownRect
{
    /*now make sure that the 'down' version of keyboard is drawn for this key:*/
    CALayer *newLayerMaskLayer = [CALayer layer];
    [newLayerMaskLayer setBackgroundColor: [[UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0] CGColor]];
    [newLayerMaskLayer setFrame: keyDownRect];
    [keyDownMaskLayers addObject: newLayerMaskLayer];
    [keyDownMaskLayer addSublayer: newLayerMaskLayer];
    
    newLayerMaskLayer = [CALayer layer];
    [newLayerMaskLayer setBackgroundColor: [[UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0] CGColor]];
    [newLayerMaskLayer setFrame: keyDownRect];
    [keyDownMaskLayers_b addObject: newLayerMaskLayer];
    [keyDownMaskLayer_b addSublayer: newLayerMaskLayer];
    
    
    /*if this is the first key down, then make the key down layer visible:*/
    if([keysDown count] == 1)
    {
        [keyDownLayer setHidden: NO];
        [keyDownLayer_blendSublayer setHidden: NO];
        [keyDownLayer removeAllAnimations];
        [keyDownLayer_blendSublayer removeAllAnimations];
    }
}

- (void)keyUp: (CGRect)keyUpRect andTouchNumThatEnded: (int)touchNumThatEnded;
{
    /*if this is the last key up, then make the key down layer invisible first:*/
    if([keysDown count] == 0)
    {
        [keyDownLayer setHidden: YES];
        [keyDownLayer_blendSublayer setHidden: YES];
        [keyDownLayer removeAllAnimations];
        [keyDownLayer_blendSublayer removeAllAnimations];
    }
    
    /*stop the 'down' version of keyboard being drawn for this key:*/
    CALayer *layerToDelete = [keyDownMaskLayers objectAtIndex: touchNumThatEnded];
    [keyDownMaskLayers removeObjectAtIndex: touchNumThatEnded];
    [layerToDelete removeFromSuperlayer];
    
    layerToDelete = [keyDownMaskLayers_b objectAtIndex: touchNumThatEnded];
    [keyDownMaskLayers_b removeObjectAtIndex: touchNumThatEnded];
    [layerToDelete removeFromSuperlayer];
}


- (int)findRowThatPointFallsIn: (CGPoint)p
{
    if(currentOrientation == 0)
    {
        if(p.y < 132)
        {
            if(p.y < 68) return 0;
            else return 1;
        }
        
        else
        {
            if(p.y < 196) return 2;
            else return 3;
        }
    }
    
    else
    {
        if(p.y < 177)
        {
            if(p.y <= 91) return 0;
            else return 1;
        }
        
        else
        {
            if(p.y < 263) return 2;
            else return 3;
        }
    }
}

- (int)findCellThatPointFallsIn: (CGPoint)p cellList: (int *)cellList startIndex: (int)startIndex length: (int)length
{
    if(length == 1) return startIndex;
    
    int midCellOffset = (int)((float)(length) * 0.5);
    int midCellBoundary = startIndex + midCellOffset;
    
    if(p.x < cellList[midCellBoundary])
    {
        return [self findCellThatPointFallsIn: p cellList: cellList startIndex: startIndex length: midCellOffset];
    }
    
    else
    {
        return [self findCellThatPointFallsIn: p cellList: cellList startIndex: midCellBoundary length: (length - midCellOffset)];
    }
}

- (NSString *)returnStringKeyValueFromTouchPoint: (CGPoint)thePoint;
{
    /*Determine which of the four rows of keys the touch has fallen on:*/
    int rowNum;
    if(thePoint.y < 132)
    {
        if(thePoint.y < 68) rowNum = 0;
        else rowNum = 1;
    }
    else
    {
        if(thePoint.y < 196) rowNum = 2;
        else rowNum = 3;
    }
    
    /*Now we can use this to determine which key the touch has fallen on:*/
    int keyCellNum = [self findCellThatPointFallsIn: thePoint cellList: keyCells_boundaries[rowNum] startIndex: 0 length: keyCells_numberOfKeyBoundariesInRow[rowNum]];
    
    return [[[keyCellValues objectAtIndex: keyboardState] objectAtIndex: rowNum] objectAtIndex: keyCellNum];
}

- (CGRect)convertKeyCellCoordsToCGRectWithRowNum: (int)rowNum andCellNum: (int)cellNum
{
    if(currentOrientation == 0)
    {
        return CGRectMake(keyCells_boundaries[rowNum][cellNum], keyRows_boundaries[rowNum], (keyCells_boundaries[rowNum][cellNum + 1] - keyCells_boundaries[rowNum][cellNum]), (keyRows_boundaries[rowNum + 1] - keyRows_boundaries[rowNum]));
    }
    
    else 
    {
        return CGRectMake(keyCells_boundaries_l[rowNum][cellNum], keyRows_boundaries_l[rowNum], (keyCells_boundaries_l[rowNum][cellNum + 1] - keyCells_boundaries_l[rowNum][cellNum]), (keyRows_boundaries_l[rowNum + 1] - keyRows_boundaries_l[rowNum]));
    }
}



    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*use these to record this touch's properties:*/
    int rowNum;
    int keyCellNum;
    NSString *keyStrVal;
    
    /*for all touches, in order:*/
    for(int i = 0; i < [[touches allObjects] count]; i++)
    {
        /*record the touch:*/
        [recordedTouches addObject: [[touches allObjects] objectAtIndex: i]];
        
        /*determine the touch's coords, and hence which key it has pressed:*/
        CGPoint touchPoint = [[[touches allObjects] objectAtIndex: i] locationInView: self];
        rowNum = [self findRowThatPointFallsIn: touchPoint];
        if(currentOrientation == 0) keyCellNum = [self findCellThatPointFallsIn: touchPoint cellList: keyCells_boundaries[rowNum] startIndex: 0 length: keyCells_numberOfKeyBoundariesInRow[rowNum]];
        else keyCellNum = [self findCellThatPointFallsIn: touchPoint cellList: keyCells_boundaries_l[rowNum] startIndex: 0 length: keyCells_numberOfKeyBoundariesInRow[rowNum]];
        keyStrVal = [[[keyCellValues objectAtIndex: keyboardState] objectAtIndex: rowNum] objectAtIndex: keyCellNum];
        
        /*also record said info here:*/
        [keysDown_rowNum addObject: [NSNumber numberWithInt: rowNum]];
        [keysDown_keyCellNum addObject: [NSNumber numberWithInt: keyCellNum]];
        [keysDown_StrVal addObject: keyStrVal];
        
        /*Record that this key should be down (doesn't apply to keyboard-state-switching keys):*/
        if((keyStrVal != @"LETTERS")&&(keyStrVal != @"NUMBERS")&&(keyStrVal != @"SYMBOLS"))
        {
            CGRect rectForKey = [self convertKeyCellCoordsToCGRectWithRowNum: rowNum andCellNum: keyCellNum];
            
            /*Special case for the undo/redo buttons on their respective keyboards, as that those buttons are twice as wide:*/
            if((keyStrVal == @"UNDO")||(keyStrVal == @"REDO"))
            {
                rectForKey = [self convertKeyCellCoordsToCGRectWithRowNum: rowNum andCellNum: 1];
                rectForKey.size.width *= 2;
            }
            
            [keysDown addObject: [NSValue valueWithCGRect: rectForKey]];
            
            /*Draw the keyboard appropriately:*/
            [self keyDown: rectForKey];
            //[self setNeedsDisplayInRect: rectForKey];
        }
        
        
        /*special action for special keys...*/
        /*if the key pressed was the backspace key, then stuff happens immediately:*/
        if(keyStrVal == @"BACKSPACE") 
        {
            backspaceCount = 0;
            [theTextView backspace];
            backspaceKeyIsPressed_timer = [NSTimer scheduledTimerWithTimeInterval: BACKSPACE_REPEAT_INTERVAL target: self selector: @selector(backspaceKeyIsPressed:) userInfo: nil repeats: YES];
            
            //[self setNeedsDisplay];
        }
        
        else if(keyStrVal == @"SHIFT") 
        {
            /*allow double tap to process:*/
            if(doubleTapInProgress++ == 0) [NSTimer scheduledTimerWithTimeInterval: DOUBLE_TAP_MAX_DURATION target: self selector: @selector(doubleTapMaxDurationReached:) userInfo: nil repeats: YES];
        }
        
        else if(keyStrVal == @"NUMBERS") 
        {
            keyboardState = 2;
            [self shiftStateChanged];
            [self drawKeyboard];
        }
        
        else if(keyStrVal == @"SYMBOLS")
        {
            keyboardState = 3;
            [self shiftStateChanged];
            [self drawKeyboard];
        }
        
        else if(keyStrVal == @"LETTERS") 
        {
            keyboardState = 0;
            shiftKeyDown = 0;
            [self shiftStateChanged];
            [self drawKeyboard];
        }
    }
}

    
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*loop over all current touches...*/
    for(int i = 0; i < [[touches allObjects] count]; i++)
    {
        /*..which touch(es) is it of our ordered list of touches, that moved?*/
        int touchNumThatMoved = [recordedTouches indexOfObject: [[touches allObjects] objectAtIndex: i]];
        if(touchNumThatMoved == NSNotFound) continue;
        
        
        /*if the user's finger drifts off the key they pressed, then it is no longer down:*/
        CGPoint touchPoint = [[recordedTouches objectAtIndex: touchNumThatMoved] locationInView: self];
        
        /*Determine which of the four rows of keys the touch has fallen on:*/
        int rowNum = [self findRowThatPointFallsIn: touchPoint];
        
        /*Now we can use this to determine which key the touch has fallen on:*/
        int keyCellNum;
        
        if(currentOrientation == 0) keyCellNum = [self findCellThatPointFallsIn: touchPoint cellList: keyCells_boundaries[rowNum] startIndex: 0 length: keyCells_numberOfKeyBoundariesInRow[rowNum]];
        else keyCellNum = [self findCellThatPointFallsIn: touchPoint cellList: keyCells_boundaries_l[rowNum] startIndex: 0 length: keyCells_numberOfKeyBoundariesInRow[rowNum]];
        
        int rowNum_origPress = [[keysDown_rowNum objectAtIndex: touchNumThatMoved] intValue];
        int keyCellNum_origPress = [[keysDown_keyCellNum objectAtIndex: touchNumThatMoved] intValue];
        
        /*if its no longer the same key that the touch pressed down on, then this touch/press is no longer valid, so end it:*/
        if((rowNum != rowNum_origPress)||(keyCellNum != keyCellNum_origPress))
        {
            CGRect rectForKey = [self convertKeyCellCoordsToCGRectWithRowNum: rowNum_origPress andCellNum: keyCellNum_origPress];

            /*Special case for the undo/redo buttons on their respective keyboards, as that those buttons are twice as wide:*/
            if(([keysDown_StrVal objectAtIndex: touchNumThatMoved] == @"UNDO")||([keysDown_StrVal objectAtIndex: touchNumThatMoved] == @"REDO"))
            {
                if((rowNum == 2)&&((keyCellNum == 1)||(keyCellNum == 2))) continue;
                
                rectForKey = [self convertKeyCellCoordsToCGRectWithRowNum: rowNum_origPress andCellNum: 1];
                rectForKey.size.width *= 2;
            }
            
            /*if the user has moved their touch from the backspace key, we can stop backspacing:*/
            if([keysDown_StrVal objectAtIndex: touchNumThatMoved] == @"BACKSPACE")
            {
                if(backspaceKeyIsPressed_timer != nil)
                {
                    [backspaceKeyIsPressed_timer invalidate];
                    backspaceKeyIsPressed_timer = nil;
                }
            }
            
            [recordedTouches removeObjectAtIndex: touchNumThatMoved];
            [keysDown_rowNum removeObjectAtIndex: touchNumThatMoved];
            [keysDown_keyCellNum removeObjectAtIndex: touchNumThatMoved];
            [keysDown_StrVal removeObjectAtIndex: touchNumThatMoved];
            [keysDown removeObjectAtIndex: touchNumThatMoved];
            
            //[self setNeedsDisplayInRect: rectForKey];
            [self keyUp: rectForKey andTouchNumThatEnded: touchNumThatMoved];
        }
    }
}
    

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEndedSlashCancelled: touches withEvent: event];
}
    
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEndedSlashCancelled: touches withEvent: event];
}
    
/*Exactly the same behaviour for touches that end and are cancelled, so here's the core effect, both ended: and cancelled: methods simply call this:*/
- (void)touchesEndedSlashCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(int i = 0; i < [[touches allObjects] count]; i++)
    {
        int touchNumThatEnded = [recordedTouches indexOfObject: [[touches allObjects] objectAtIndex: i]];
        if(touchNumThatEnded == NSNotFound) continue;
        
        NSString *keyDown_StrVal = [keysDown_StrVal objectAtIndex: touchNumThatEnded];
        
        /*this key will now have to be drawn 'up' again (unless its one of the keys that doesn't get pressed down):*/
        if((keyDown_StrVal != @"LETTERS")&&(keyDown_StrVal != @"NUMBERS")&&(keyDown_StrVal != @"SYMBOLS"))
        {
            CGRect keyRect = [[keysDown objectAtIndex: touchNumThatEnded] CGRectValue];
            [keysDown removeObjectAtIndex: touchNumThatEnded];
            //[self setNeedsDisplayInRect: keyRect];
            
            [self keyUp: keyRect andTouchNumThatEnded: touchNumThatEnded];
        }
        
        [recordedTouches removeObjectAtIndex: touchNumThatEnded];
        [keysDown_rowNum removeObjectAtIndex: touchNumThatEnded];
        [keysDown_keyCellNum removeObjectAtIndex: touchNumThatEnded];
        [keysDown_StrVal removeObjectAtIndex: touchNumThatEnded];
        
        
        
        /*if the user has lifted their touch from the backspace key, we can stop backspacing:*/
        if(keyDown_StrVal == @"BACKSPACE")
        {
            if(backspaceKeyIsPressed_timer != nil)
            {
                [backspaceKeyIsPressed_timer invalidate];
                backspaceKeyIsPressed_timer = nil;
            }
        }
        
        /*Notify the parent view if an undo or redo request was made:*/
        if(keyDown_StrVal == @"UNDO") [parentCallbackObject requestUndo];
        if(keyDown_StrVal == @"REDO") [parentCallbackObject requestRedo];
        
        if(keyDown_StrVal == @"SHIFT")
        {
            /*if shift was off, make it on, and vice versa*/
            if(shiftKeyDown == 0) shiftKeyDown = 1;
            else shiftKeyDown = 0;
            
            
            keyboardState = 1 - keyboardState;
            
            /*continue to record the possibility of double taps:*/
            if(doubleTapInProgress == 1) doubleTapInProgress = 2;
            
            if(doubleTapInProgress == 3)
            {
                shiftKeyDown = 2;
                keyboardState = 1;
                shiftState = 2;
            }
            
            else 
            {
                if(shiftState == 0) shiftState = 1;
                else shiftState = 0;
            }
            
            [self shiftStateChanged];
        }
        
        /*if shift is on, and the user has just tapped any key other than the shift key then shift is now no longer on!*/
        else if(shiftState == 1)
        {
            shiftState = 0;
            [self shiftStateChanged];
        }
        
        /*if the user pressd the quit key, then stop text input:*/
        if(keyDown_StrVal == @"QUIT")
        {
            [theTextView resignFirstResponder];
        }
        
        /*touch end is the point at which a key takes its effect in the text view:*/
        if((keyDown_StrVal != @"BACKSPACE")&&(keyDown_StrVal != @"QUIT")&&(keyDown_StrVal != @"SHIFT")&&(keyDown_StrVal != @"NUMBERS")&&(keyDown_StrVal != @"SYMBOLS")&&(keyDown_StrVal != @"LETTERS")&&(keyDown_StrVal != @"NIL")&&(keyDown_StrVal != @"UNDO")&&(keyDown_StrVal != @"REDO"))
        {
            [theTextView keyWasPressed: keyDown_StrVal];
            
            /*if the shift key was down at this point, then it no longer should be:*/
            if(shiftKeyDown == 1)
            {
                shiftKeyDown = 0;
                keyboardState = 0;
                [self shiftStateChanged];
            }
        }
    }
}


- (void)backspaceKeyIsPressed: (NSTimer *)theTimer
{
    if(backspaceCount++ > 4) [theTextView backspace];
}

- (void)doubleTapMaxDurationReached: (NSTimer *)theTimer;
{
    doubleTapInProgress = 0;
    [theTimer invalidate];
}

- (void)isInPortrait
{
    currentOrientation = 0;
    [self setAllSubLayersToCorrectSize];
    
    [self drawKeyboard];
}

- (void)isInLandscape
{
    currentOrientation = 1;
    [self setAllSubLayersToCorrectSize];
    
    [self drawKeyboard];
}

- (void)setAllSubLayersToCorrectSize
{
    [blendSublayer setFrame: [[self layer] bounds]];
    [keyDownLayer setFrame: [[self layer] bounds]];
    [keyDownLayer_blendSublayer setFrame: [[self layer] bounds]];
    [keyDownMaskLayer setFrame: [[self layer] bounds]];
    [keyDownMaskLayer_b setFrame: [[self layer] bounds]];
    
    /*shift layers:*/
    if(currentOrientation == 0)
    {
        [shiftKey_left_layer setFrame: CGRectMake(3, 133, 63, 63)];
        [shiftKey_right_layer setFrame: CGRectMake(682, 133, 83, 63)];
        [shiftKey_left_layer_blendSublayer setFrame: CGRectMake(3, 133, 63, 63)];
        [shiftKey_right_layer_blendSublayer setFrame: CGRectMake(682, 133, 83, 63)];
    }
    
    else
    {
        [shiftKey_left_layer setFrame: CGRectMake(0, 176, 91, 86)];
        [shiftKey_right_layer setFrame: CGRectMake(907, 176, 115, 86)];
        [shiftKey_left_layer_blendSublayer setFrame: CGRectMake(0, 176, 91, 86)];
        [shiftKey_right_layer_blendSublayer setFrame: CGRectMake(907, 176, 115, 86)];
    }
}

/*can only be called when there is a current CGContext:*/
- (void)lazyLoadCGImage: (CGImageRef)theImage toCGLayer: (CGLayerRef *)theLayer fromContext: (CGContextRef)theContext inRect: (CGRect)theRect
{
    *theLayer = CGLayerCreateWithContext(theContext, theRect.size, NULL);
    CGContextRef layerContext = CGLayerGetContext(*theLayer);
    
    CGContextSaveGState(layerContext);
    CGContextScaleCTM(layerContext, 1.0, -1.0);
    CGContextTranslateCTM(layerContext, 0, -1.0 * theRect.size.height);
    CGContextDrawImage(layerContext, theRect, theImage);
    CGContextRestoreGState(layerContext);
}


- (void)appWillResignActive
{
    /*if there are any keys still down, clear them:*/
    if([keysDown count] > 0)
    {
        [keysDown removeAllObjects];
        [keysDown_rowNum removeAllObjects];
        [keysDown_keyCellNum removeAllObjects];
        [keysDown_StrVal removeAllObjects];
        [recordedTouches removeAllObjects];
    }
}
    
- (void)keyboardWillShow: (NSNotification *)theNotification
{
    /*if the keyboard is about to be shown, it must first check that it has the correct global brightness value. if not, then it needs to correct the value and redraw itself:*/
    if(globalBrightness != [parentCallbackObject getGlobalBrightness])  [self setGlobalBrightness: [parentCallbackObject getGlobalBrightness]];
}




- (void)dealloc
{
    /*release the various keyboard images:*/
    for(int orient = 0; orient <= 1; orient++)
    {
        for(int mode = 0; mode <= 2; mode++)
        {
            for(int pressed = 0; pressed <= 1; pressed++)
            {
                for(int light = 0; light <= 2; light++)
                {
                    CGImageRelease(keyboardImages[orient][mode][pressed][light]);
                }
            }
        }
    }
    
    /*release the various shift key images:*/
    for(int orient = 0; orient <= 1; orient++)
    {
        for(int side = 0; side <= 1; side++)
        {
            for(int light = 0; light <= 1; light++)
            {
                for(int mode = 0; mode <= 1; mode++)
                {
                    CGImageRelease(shiftKeyImage[orient][side][light][mode]);
                }
            }
        }
    }
    
    /*release the various core animation layers:*/
    [blendSublayer removeFromSuperlayer];
    
    [keyDownLayer removeFromSuperlayer];
    [keyDownLayer_blendSublayer removeFromSuperlayer];
    
    [keyDownMaskLayer release];
    [keyDownMaskLayer_b release];
    
    
    [keyDownMaskLayers removeAllObjects];
    [keyDownMaskLayers release];
    [keyDownMaskLayers_b removeAllObjects];
    [keyDownMaskLayers_b release];
    
    
    /*Shift Key Layers:*/
    [shiftKey_left_layer removeFromSuperlayer];
    [shiftKey_right_layer removeFromSuperlayer];
    
    [shiftKey_left_layer_blendSublayer removeFromSuperlayer]; 
    [shiftKey_right_layer_blendSublayer removeFromSuperlayer];
    
    
    
    
    [shiftKeyRects release];
    
    free(keyCells_numberOfKeyBoundariesInRow);
    free(keyCells_boundaries);
    free(keyCells_boundaries_l);
    
    [keyCellValues release];
    
    [recordedTouches release];
    
    [keysDown_rowNum release];
    [keysDown_keyCellNum release];
    [keysDown_StrVal release];
    
    [keysDown release];
    
    [super dealloc];
}

@end
    
