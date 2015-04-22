//
//  DHSGlyphFont.h
//  DHS
//
//  Created by David Shane on 10/13/13. (DShaneNYC@gmail.com)
//  Copyright (c) 2013 David H. Shane. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#import "DHSGlyphTextCommon.h"

/**
 * @class DHSGlyphFont
 *
 * @abstract A font with metadata for use with DHSGlyphTypsetter instances
 *
 * @discussion This class is responsible for holding the information about a display font including its glyphs.
 *
 */

@interface DHSGlyphFont : NSObject

//
// Properties
//

/// Whether the font should cache size information
@property (nonatomic, readwrite)    BOOL shouldCache;
/// A Core Graphics reference to a version of the font
@property (nonatomic, readonly)     CGFontRef cgFont;
/// A Core Text reference to a version of the font
@property (nonatomic, readonly)     CTFontRef ctFont;
/// The name of the font in the bundle
@property (nonatomic, readwrite)    NSString *fontName;
/// The current size that the font will be rendered in
@property (nonatomic, readwrite)    CGFloat fontSize;
/// The scale of the glyphs' width (x) and height (y) with respect to the default glyph sizes in the font file
@property (nonatomic, readwrite)    CGPoint scaleFactor;
/// The ratio of the font descender height (descent) to the font size in points
@property (nonatomic, readwrite)    CGFloat descenderRatio;
/// The amount the glyphs should be shifted together or apart with respect to the default spacing in the font file
///
/// < 1.0 should result in compression while > 1.0 should result in expansion
@property (nonatomic, readwrite)    CGFloat glyphExpansionMultiplier;

//
// Initialization methods
//

/**
 * Initialize a new font instance with an initial font name and size
 *
 * @param fontName The file name of the font in the main bundle
 * @param fontSize The initial size of the font in points
 *
 * @return Returns a newly created font instance
 */
- (id)initWithFontName:(NSString *)fontName andSize:(CGFloat)fontSize;

//
// Size methods
//

/**
 * Find the bounding box size of a single line string of text
 *
 * @return Returns the optical bounding box of the entire string of text
 */
- (CGSize)sizeForText:(NSString *)text;

/**
 * Find the bounding box size of a glyph in the font at the current font size
 *
 * @param letter The unicode character to get the size of
 *
 * @return Returns the optical bounding box of the requested character if it exists in the font
 */
- (CGSize)sizeForUnichar:(unichar)letter;

/**
 * Find the bounding box size of the space glyph in the font at the current font size
 *
 * @return Returns the optical bounding box of the space character if it exists in the font
 */
- (CGSize)spaceSize;

//
// Object methods
//

/**
 * Get the font glyphs that correspond to the characters in the provided string
 *
 * @param glyphs A pointer to previously allocated memory that can hold all the glyphs for the text provided
 * @param text A string of text to retrieve glyphs for. If a glyph does not exist in the font, zero will be placed at that location
 *
 * @return Returns YES if all the glyphs could be retrieved and NO otherwise
 */
- (BOOL)getGlyphs:(CGGlyph *)glyphs forText:(NSString *)text;

/**
 * Determine if all the characters in the provided string can be rendered in the font
 *
 * @param text A string of text to test
 *
 * @return Returns YES if all the glyphs could be rendered and NO otherwise
 */
- (BOOL)canRenderText:(NSString *)text;

//
// NSObject methods
//

/**
 * Determine if another font's properties are the same values as this font's properties by comparing each property individually
 *
 * @param font The other font to compare
 *
 * @return Returns YES if all the properties are the same value, NO if any are not
 */
- (BOOL)isEqualToDHSGlyphFont:(DHSGlyphFont *)font;

@end
