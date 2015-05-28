//
//  CustomButtons.m
//  TStats2
//
/*
 Created by toolstatsdev on 4/19/15.
 Copyright (c) 2015 ToolStats All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(15, 7, 240, 60) cornerRadius: 0];
    [color setFill];
    [rectanglePath fill];
    [color2 setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
}
//*/

@end