//
//  DHSGlyphTypesetterRotation.h
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

#import "DHSGlyphTypesetterLine.h"

typedef NS_ENUM(NSInteger, DHSGlyphTypesetterRotationLayoutInfo) {
    /// The maximum number of lines that will be laid out or zero for no maximum
    DHSGlyphTypesetterRotationLayoutInfoMaxNumberOfLines = DHSGlyphTypesetterLineLayoutInfoMaxNumberOfLines,
    /// The NSTextAlignment of the layout style (e.g. left, center, right)
    DHSGlyphTypesetterRotationLayoutInfoTextAlignment = DHSGlyphTypesetterLineLayoutInfoTextAlignment,
    /// The shadow offset for rendering used to properly justify against the bounding box edges
    DHSGlyphTypesetterRotationLayoutInfoShadowOffset = DHSGlyphTypesetterLineLayoutInfoShadowOffset,
    /// The stroke width for rendering used to properly justify against the bounding box edges
    DHSGlyphTypesetterRotationLayoutInfoStrokeWidth = DHSGlyphTypesetterLineLayoutInfoStrokeWidth,
    /// Whether or not the renderer will shift the layout to the shadow offset used to properly justify against the bounding box edges
    DHSGlyphTypesetterRotationLayoutInfoShiftsToShadowOffset = DHSGlyphTypesetterLineLayoutInfoShiftsToShadowOffset,
    /// How multi-line text should be laid out vertically
    DHSGlyphTypesetterRotationLayoutInfoLineLayoutStyle = DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle,
    /// How much the gap between lines in multi-line text should be adjusted
    DHSGlyphTypesetterRotationLayoutInfoLineLayoutStyleMultiplier = DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier,
    /// The angle of rotation in radians for each individual glyph in the text
    DHSGlyphTypesetterRotationLayoutInfoGlyphRotation,
    DHSGlyphTypesetterRotationLayoutInfoCount
} ;

@interface DHSGlyphTypesetterRotation : DHSGlyphTypesetterLine

@end
