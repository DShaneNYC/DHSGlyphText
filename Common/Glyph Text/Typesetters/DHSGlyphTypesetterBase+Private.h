//
//  DHSGlyphTypesetter+Private.h
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

#define DHSGLYPH_NO_ROTATION        MAXFLOAT

@interface DHSGlyphTypesetterBase (Private)

#pragma mark -
#pragma mark Properties

//
// Properties
//

/// The string of text that the typesetter will lay out
@property (nonatomic, readwrite)    NSString *text;
/// The font and its info to use for layout
@property (nonatomic, readwrite)    DHSGlyphFont *font;
/// The location of the glyphs to use for layout
@property (nonatomic, readwrite)    CGGlyph *glyphs;
/// The location to store the point locations of the origins of the glyphs for rendering
@property (nonatomic, readwrite)    CGPoint *points;
/// The location to store the sizes of the bounding boxes of the individual glyphs
@property (nonatomic, readwrite)    CGSize *sizes;
/// The location to store the rotations of the individual glyphs
@property (nonatomic, readwrite)    CGFloat *rotations;
/// The specific parameter settings for the layout
@property (nonatomic, readwrite)    NSDictionary *layoutInfo;


#pragma mark -
#pragma mark Class methods

//
// Class methods
//

/**
 * The ratio of spaces to other characters in the given text. This can help to determine what sort
 * of layout parameters and techniques to use in laying out the text.
 *
 * @param text The text on which to detect the ratio of spaces
 *
 * @return The ratio of spaces to other characters
 */
+ (CGFloat)spaceRatioForText:(NSString *)text;


#pragma mark -
#pragma mark Initialization methods

//
// Initialization methods
//

/**
 * Initialize a new typesetter instance with initial parameter settings
 */
- (void)setDefaults;


#pragma mark -
#pragma mark Data methods

//
// Data methods
//

/**
 * Set an individual layout parameter instead of using \b setLayoutInfo to set them all at once
 *
 * @param infoItem The value of the layout info parameter to set
 * @param key The key of the layout info parameter to set. Must be compatible with the layout info for this class.
 */
- (void)setLayoutInfoValue:(id)infoItem forKey:(DHSGlyphTypesetterLayoutInfo)key;


#pragma mark -
#pragma mark Layout methods

//
// Layout methods
//

/**
 * The ratio of spaces to other characters in the text set in the typesetter. This can help to
 * determine what sort of layout parameters and techniques to use in laying out the text.
 *
 * @return The ratio of spaces to other characters
 */
- (CGFloat)spaceRatio;

/**
 * Called by the typesetter to layout the retained text. Subclasses should implement this method to customize the layout and optionally call super.
 *
 * @param glyphs The glyphs for the retained text in the retained font to be laid out will be in this array
 * @param points The array this method will use to store the glyph point locations
 * @param rotations The array this method will use to store the individual glyph rotations
 * @param length The size of both the \b glyphs and \b points arrays. This should be same as the length of the retained text.
 * @param rect The bounding box that the laid out glyphs must fit in
 */
- (void)layoutGlyphs:(CGGlyph *)glyphs
            atPoints:(CGPoint *)points
            andSizes:(CGSize *)sizes
        andRotations:(CGFloat *)rotations
          withLength:(NSInteger)length
              inRect:(CGRect)rect;

@end
