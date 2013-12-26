//
//  DHSGlyphTypesetterRandomShift.m
//  DHSGlyphDemo
//
//  Created by David Shane on 12/1/13. (DShaneNYC@gmail.com)
//  Copyright (c) 2013 Optiquity, Inc. All rights reserved.
//

/*
 Copyright 2013 David H. Shane
 
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

#import "DHSGlyphTypesetterRandomShift.h"
#import "DHSGlyphTypesetterBase+Private.h"

#define ARC4RANDOM_MAX 0x100000000
CGFloat randomFloat(CGFloat minRange, CGFloat maxRange);

@implementation DHSGlyphTypesetterRandomShift

#pragma mark -
#pragma mark Data methods

+ (NSDictionary *)defaultLayoutInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:super.defaultLayoutInfo];
    
    [info addEntriesFromDictionary:
     @{@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMin) : @(0.0f), // No random shift
       @(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMax) : @(0.0f), // No random shift
       @(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMin) : @(0.0f), // No random shift
       @(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMax) : @(0.0f), // No random shift
       @(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMin) : @(0.0f), // No random shift
       @(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMax) : @(0.0f), // No random shift
       }];
    
    return [NSDictionary dictionaryWithDictionary:info];
}


#pragma mark -
#pragma mark Layout methods

inline CGFloat randomFloat(CGFloat minRange, CGFloat maxRange) {
    return ((CGFloat)arc4random() / (CGFloat)ARC4RANDOM_MAX) * (maxRange - minRange) + minRange;
}

- (void)layoutGlyphs:(CGGlyph *)glyphs
            atPoints:(CGPoint *)points
            andSizes:(CGSize *)sizes
        andRotations:(CGFloat *)rotations
          withLength:(NSInteger)length
              inRect:(CGRect)rect {
    
    [super layoutGlyphs:glyphs
               atPoints:points
               andSizes:sizes
           andRotations:rotations
             withLength:length
                 inRect:rect];
    
    // Get shift limits
    CGFloat horizontalMin = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMin)] floatValue];
    CGFloat horizontalMax = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMax)] floatValue];
    CGFloat verticalMin = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMin)] floatValue];
    CGFloat verticalMax = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMax)] floatValue];
    CGFloat rotationMin = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMin)] floatValue];
    CGFloat rotationMax = [self.layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMax)] floatValue];
    
    // Make sure rotations work if they are desired
    BOOL doRotation = NO;
    if (rotations[0] == DHSGLYPH_NO_ROTATION &&
        (rotationMax - rotationMin != 0.0f) &&
        (rotationMin != 0.0f || rotationMax != 0.0f)) {
        doRotation = YES;
        for (NSInteger i = 0; i < length; ++i) rotations[i] = 0.0f;
    }
    
    // Adjust glyphs by shifting by random ratios
    for (NSInteger i = 0; i < length; ++i) {
        CGFloat adjustX = 0.0f;
        CGFloat adjustY = 0.0f;
        CGFloat adjustRotation = 0.0f;
        
        if (horizontalMin <= horizontalMax) adjustX = randomFloat(horizontalMin, horizontalMax);
        if (verticalMin <= verticalMax) adjustY = randomFloat(verticalMin, verticalMax);
        if (doRotation && rotationMin <= rotationMax) adjustRotation = randomFloat(rotationMin, rotationMax);
        
        points[i] = CGPointMake(points[i].x * (1.0f + adjustX), points[i].y * (1.0f  + adjustY));
        if (doRotation) rotations[i] += adjustRotation;
    }
}

@end
