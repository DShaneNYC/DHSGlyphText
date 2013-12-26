//
//  DHSGlyphTypesetterLine.h
//  DHS
//
//  Created by David Shane on 11/2/13. (DShaneNYC@gmail.com)
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

#import "DHSGlyphTypesetterBase.h"

typedef enum {
    /// Line layout style that will center lines in the layout rect based on the default line spacing
    DHSGlyphTypesetterLineLayoutStyleCenter = 0,
    /// Line layout style that will spread lines in the layout rect based on the default line spacing and a line layout style multiplier
    DHSGlyphTypesetterLineLayoutStyleSpread
} DHSGlyphTypesetterLineLayoutStyle;

typedef enum {
    /// The maximum number of lines that will be laid out or zero for no maximum
    DHSGlyphTypesetterLineLayoutInfoMaxNumberOfLines,
    /// The NSTextAlignment of the layout style (e.g. left, center, right)
    DHSGlyphTypesetterLineLayoutInfoTextAlignment,
    /// The shadow offset for rendering used to properly justify against the bounding box edges
    DHSGlyphTypesetterLineLayoutInfoShadowOffset,
    /// The stroke width for rendering used to properly justify against the bounding box edges
    DHSGlyphTypesetterLineLayoutInfoStrokeWidth,
    /// Whether or not the renderer will shift the layout to the shadow offset used to properly justify against the bounding box edges
    DHSGlyphTypesetterLineLayoutInfoShiftsToShadowOffset,
    /// How multi-line text should be laid out vertically
    DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle,
    /// How much the gap between lines in multi-line text should be adjusted
    DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier,
    DHSGlyphTypesetterLineLayoutInfoCount
} DHSGlyphTypesetterLineLayoutInfo;

@interface DHSGlyphTypesetterLine : DHSGlyphTypesetterBase

@end
