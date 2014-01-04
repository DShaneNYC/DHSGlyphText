//
//  DHSGlyphTypesetter.h
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

#import <Foundation/Foundation.h>

#import "DHSGlyphTextCommon.h"
#import "DHSGlyphFont.h"

typedef enum {
    /// Subclasses should have their own enum types for layout info
    DHSGlyphTypesetterLayoutInfoCount
} DHSGlyphTypesetterLayoutInfo;

@interface DHSGlyphTypesetter : NSObject

#pragma mark -
#pragma mark Properties

//
// Properties
//

/// Whether the typesetter should save layout sizes for a particular set of parameters in a cache
@property (nonatomic, readwrite)    BOOL shouldCache;
/// The string of text that the typesetter will lay out
@property (nonatomic, readonly)     NSString *text;
/// The font that the typesetter will use to calculate glyph sizes and bounding box positions
@property (nonatomic, readonly)     DHSGlyphFont *font;
/// The typesetter specific parameters that can be used to influence the text layout
@property (nonatomic, readonly)     NSDictionary *layoutInfo;


#pragma mark -
#pragma mark Class methods

//
// Class methods
//

/**
 * The optimal length and width of the bounding box that can be used to render a particular multi-line
 * string of text with a specific layout parameters with a limit on the maximum width and height of
 * the text permitted
 *
 * @param text The string of text that the typesetter will lay out
 * @param font The font that the typesetter will use to calculate glyph sizes and bounding box positions
 * @param layoutInfo The typesetter specific parameters that are used to influence the text layout
 * @param size The maximum \b width and \b height that the return value may have
 *
 * @return The optimal \b width and \b height of the bounding box for the given text and parameters
 */
+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
        andLayoutInfo:(NSDictionary *)layoutInfo
    constrainedToSize:(CGSize)size;

/**
 * The optimal length and width of the bounding box that can be used to render a particular multi-line
 * text string based on constraints and default layout info
 *
 * @param text The string of text that the typesetter will lay out
 * @param font The font that the typesetter will use to calculate glyph sizes and bounding box positions
 * @param size The maximum \b width and \b height that the return value may have
 *
 * @return The optimal \b width and \b height of the bounding box for the given text and parameters
 */
+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
    constrainedToSize:(CGSize)size;


#pragma mark -
#pragma mark Data methods

//
// Data methods
//

/**
 * The default parameters that can be used to lay out text with the typesetter
 *
 * @return The dictionary of parameter keys and values that the typesetter will use by default
 */
+ (NSDictionary *)defaultLayoutInfo;


#pragma mark -
#pragma mark Layout methods

//
// Layout methods
//

/**
 * The \b width and \b height of the bounding box that the typesetter will use when laying out the current text
 * with the current font and layoutInfo
 *
 * @param The maximum \b width and \b height constraint
 *
 * @return The optimap \b width and \b height that can be used to render the text set in the typsetter
 */
- (CGSize)sizeOfLayoutConstrainedToSize:(CGSize)size;

/**
 * Layout the the current text in a specific bounding box
 *
 *  @param rect The bounding box in which to layout the text
 *
 *  @return Whether the text was correctly laid out given the current settings
 */
- (BOOL)layoutInRect:(CGRect)rect;

@end
