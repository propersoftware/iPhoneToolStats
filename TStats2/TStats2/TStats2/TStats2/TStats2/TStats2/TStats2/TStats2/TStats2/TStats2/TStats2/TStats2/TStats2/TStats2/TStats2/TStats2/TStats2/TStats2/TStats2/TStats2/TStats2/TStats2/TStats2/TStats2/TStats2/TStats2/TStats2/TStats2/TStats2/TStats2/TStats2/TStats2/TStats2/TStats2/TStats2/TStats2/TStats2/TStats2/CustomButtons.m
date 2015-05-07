//
//  CustomButtons.m
//  TStats2
//
//  Created by anwosu on 4/8/15.
//  Copyright (c) 2015 Nwosu, Agu. All rights reserved.
//

#import "CustomButtons.h"

@implementation CustomButtons

//*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.942 green: 0.942 blue: 0.942 alpha: 1];//[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.113 green: 0.344 blue: 0.545 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(15, 7, 240, 50) cornerRadius: 10];
    [color setFill];
    [rectanglePath fill];
    [color2 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
}
//*/

@end