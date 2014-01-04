//
//  DHSGlyphTypesetterRotation.m
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

#import "DHSGlyphTypesetterRotation.h"
#import "DHSGlyphTypesetter+Private.h"

@implementation DHSGlyphTypesetterRotation

#pragma mark -
#pragma mark Data methods

+ (NSDictionary *)defaultLayoutInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:super.defaultLayoutInfo];
    
    [info addEntriesFromDictionary:
     @{@(DHSGlyphTypesetterRotationLayoutInfoGlyphRotation) : @(MAXFLOAT), // No rotation
       }];
    
    return [NSDictionary dictionaryWithDictionary:info];
}


#pragma mark -
#pragma mark Layout methods

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
    
    // Set rotation for all glyphs
    CGFloat rotation = [self.layoutInfo[@(DHSGlyphTypesetterRotationLayoutInfoGlyphRotation)] floatValue];
    if (rotation == MAXFLOAT) return;
    for (NSInteger i = 0; i < length; ++i) {
        rotations[i] = rotation;
    }
}

@end
