//
//  DHSGlyphLabelBase.h
//  DHS
//
//  Created by David Shane on 9/17/10. (DShaneNYC@gmail.com)
//  Copyright 2010-2013 David H. Shane. All rights reserved.
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

#import "DHSGlyphTextCommon.h"
#import "DHSGlyphTypesetter.h"
#import "DHSGlyphFont.h"

typedef enum {
    /// Render glyphs from the left on the bottom to the right on top
    DHSGlyphLabelGlyphRenderOrderForwards = 0,
    /// Render glyphs from the right on the bottom to the left on top
    DHSGlyphLabelGlyphRenderOrderBackwards,
    /// Render glyphs from the outside on the bottom to the center on top
    DHSGlyphLabelGlyphRenderOrderOutsideIn,
    /// Render glyphs from the center on the bottmo to the outside on top
    DHSGlyphLabelGlyphRenderOrderInsideOut,
    /// Render glyphs with the even indexes on the bottom and odd indexes on top
    DHSGlyphLabelGlyphRenderOrderEven,
    /// Render glyphs with the odd indexed on the bottom and even indexes on top
    DHSGlyphLabelGlyphRenderOrderOdd,
    DHSGlyphLabelGlyphRenderOrderCount
} DHSGlyphLabelGlyphRenderOrder;

#define kDHSGlyphDefaultKey         @"default"
#define kDHSGlyphSystemKey          @"sytem"


@interface DHSGlyphLabel : UILabel

#pragma mark -
#pragma mark Properties

//
// Properties
//

/// Whether the label should save rendered images for a particular set of parameters in a cache
@property (nonatomic, readwrite)                                        BOOL shouldCache;
/// The typesetter that the label will use to layout the text glyphs from the current font
@property (nonatomic, readwrite)                                        DHSGlyphTypesetter *typesetter;
/// The current font based on the the preferred selection method and glyph availability
@property (nonatomic, readonly)                                         DHSGlyphFont *currentFont;
/// Whether the label should always prefer the default font or the system preferred language key
@property (nonatomic, readwrite)                                        BOOL preferDefaultFont;
/// The color of the stroke outline of the text
@property (nonatomic, readwrite, strong)                                UIColor *strokeColor;
/// The width of the stroke outline of the text in points
@property (nonatomic, readwrite)                                        CGFloat strokeWidth;
/// The blur fade multiplier of the text drop shadow
@property (nonatomic, readwrite)                                        CGFloat shadowBlur;
/// Whether the shadow, if used, should be applied to the stroke outline of the text or not
@property (nonatomic, readwrite)                                        BOOL strokeHasShadow;
/// Whether the text should shift to the label's drop shadow offset ( as defined by \b shadowOffset ) so it can be used for a button press
@property (nonatomic, readwrite)                                        BOOL shiftsToShadowOffset;
/// The color of the glow halo blur around the text
@property (nonatomic, readwrite, strong)                                UIColor *glowColor;
/// The blur fade multiplier for text glow halo
@property (nonatomic, readwrite)                                        CGFloat glowBlur;
/// The gradient used to fill the text
@property (nonatomic, readwrite)                                        CGGradientRef gradient;
/// Whether the gradient fill is radial or linear
@property (nonatomic, readwrite, getter = isRadialGradient)             BOOL radialGradient;
/// Whether the stroke that is displayed outlines all glyphs or each glyph individually
@property (nonatomic, readwrite)                                        BOOL showIndividualGlyphStroke;
/// Whether the glow that is displayed outlines all glyphs or each glyph individually
@property (nonatomic, readwrite)                                        BOOL showIndividualGlyphGlow;
/// The order that the glyphs will be displayed and handle overlaps after the typesetter lays them out
@property (nonatomic, readwrite)                                        DHSGlyphLabelGlyphRenderOrder glyphRenderOrder;


#pragma mark -
#pragma mark Subclassing methods

//
// Subclassing methods
//

/**
 * Initialize a new label instance with initial parameter and font settings
 *
 */
- (void)setDefaults;

/**
 * Set any parameter value just before the text is rendered. This is not usually necessary.
 *
 */
- (void)prerenderCalculate;


#pragma mark -
#pragma mark Font Handling methods

//
// Font Handling methods
//

/**
 * Get a \b DHSGlyphFont instance that is stored in the label
 *
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 *
 * @return Returns the retained \b DHSGlyphFont instance or nil if it is not available for the given key
 */
- (DHSGlyphFont *)fontForKey:(NSString *)key;

/**
 * Set a \b DHSGlyphFont instance for a provided identifier and retain it in the label
 *
 * @param font The \b DHSGlyphFont instance to retain
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFont:(DHSGlyphFont *)font forKey:(NSString *)key;

/**
 * Create and set a \b DHSGlyphFont instance based on a \b UIFont for the system identifier key
 *
 * @param font The \b UIFont instance to convert into a \b DHSGlyphFont. The \b UIFont instance is not retained.
 */
- (void)setSystemFont:(UIFont *)font;

/**
 * Get a \b DHSGlyphFont instance that is stored in the label for the current system preferred language
 *
 * @return Returns the retained \b DHSGlyphFont instance or nil if it is not available for preferred language
 */
- (DHSGlyphFont *)fontForPreferredLanguage;

/**
 * Get the identifier key for the current system preferred language
 *
 * @return Returns the localized language identifier as defined by the system
 */
- (NSString *)keyForPreferredLanguage;

/**
 * Create a \b DHSGlyphFont instance and set it for a provided identifier and retain it in the label
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 *
 * @return Whether or not the font could be created and set
 */
- (BOOL)setFontName:(NSString *)fontName forKey:(NSString *)key;

/**
 * Create a \b DHSGlyphFont instance and set it for the default font key ( \b kDHSGlyphDefaultKey ) and retain it in the label
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 *
 * @return Whether or not the font could be created and set
 */
- (BOOL)setDefaultFontName:(NSString *)fontName;

/**
 * Create a \b DHSGlyphFont instance and set it for the system font key ( \b kDHSGlyphSystemKey ) and retain it in the label
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 *
 * @return Whether or not the font could be created and set
 */
- (BOOL)setSystemFontName:(NSString *)fontName;

/**
 * Set the font size in all fonts retained in the label
 *
 * @param fontSize The size for the glyphs of all the fonts in points
 */
- (void)setFontSize:(CGFloat)fontSize;

/**
 * Set the font size in the font stored for a provided identifier that is retained in the label
 *
 * @param fontSize The size for the glyphs of the font in points
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key;

/**
 * Set the font scale factor in all fonts retained in the label
 *
 * @param fontScaleFactor The scale for the width (x) and height (y) for the glyphs of the fonts, relative to the default.
 *          This does not change the relative spacing between the glyphs.
 */
- (void)setFontScaleFactor:(CGPoint)fontScaleFactor;

/**
 * Set the font scale factor in the font stored for a provided identifier that is retained in the label
 *
 * @param fontScaleFactor The scale for the width (x) and height (y) for the glyphs of the font, relative to the default.
 *          This does not change the relative spacing between the glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key;

/**
 * Set, and override the default, font descender ratio in all fonts retained in the label
 *
 * @param fontDescenderRatio The descender ratio for the glyphs of the font in points.
 *          The default is defined as the font descent in points divided by the font size in points.
 */
- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio;

/**
 * Set, and override the default, font descender ratio in the font stored for a provided identifier that is retained in the label
 *
 * @param fontDescenderRatio The descender ratio for the glyphs of the font in points.
 *          The default is defined as the font descent in points divided by the font size in points.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key;

/**
 * Set the font glyph expansion multiplier in all fonts retained in the label
 *
 * @param fontGlyphExpansionMultiplier The amount the space in between glyphs will be expanded or compressed,
 *          relative to the default of the font. This does not change the width or height of individual glyphs.
 */
- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier;

/**
 * Set the font glyph expansion multiplier in the font stored for a provided identifier that is retained in the label
 *
 * @param fontGlyphExpansionMultiplier The amount the space in between glyphs will be expanded or compressed,
 *          relative to the default of the font. This does not change the width or height of individual glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key;


#pragma mark -
#pragma mark View Drawing methods

//
// View Drawing methods
//

/**
 * Create an image of the label offscreen rendering with the current settings
 *
 * @return Returns the rendered image or a cached version if it is available
 */
- (UIImage *)getImage;

@end
