//
//  DHSGlyphButtonBase.h
//  DHS
//
//  Created by David Shane on 9/18/10. (DShaneNYC@gmail.com)
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

#import <UIKit/UIKit.h>

#import "DHSGlyphTextCommon.h"
#import "DHSGlyphLabelBase.h"

@interface DHSGlyphButtonBase : UIButton

#pragma mark -
#pragma mark Class Initialization methods

//
// Class Initialization methods
//

/**
 * Create a button instance
 *
 * @return Returns a new, empty button instance
 */
+ (id)button;

/**
 * Create a button instance by overloading the \b UIButton version of this method
 *
 * @param buttonType This parameter is ignored
 *
 * @return Returns a new, empty button instance by calling \b + \b (id)button
 */
+ (id)buttonWithType:(UIButtonType)buttonType;


#pragma mark -
#pragma mark Subclassing methods

//
// Subclassing methods
//

/**
 * Initialize a new button instance with initial parameter and font settings
 *
 */
- (void)setDefaults;

/**
 * Set any parameter value just before the text is rendered. This is not usually necessary.
 *
 */
- (void)prerenderCalculate;


#pragma mark -
#pragma mark UIButton methods

//
// UIButton methods
//

/**
 * Set the text retained in the labels for all button states
 *
 * @param title the text to show
 */
- (void)setTitle:(NSString *)title;

/**
 * Set the color of the fill of the text retained in the labels for all button states
 *
 * @param color the color of the text fill
 */
- (void)setTitleColor:(UIColor *)color;

/**
 * Set the color of the shadow of the text retained in the labels for all button states
 *
 * @param color the color of the text shadow
 */
- (void)setTitleShadowColor:(UIColor *)color;

#pragma mark -
#pragma mark Label Access methods

//
// Label Access methods
//

/**
 * Access to the \b DHSGlyphLabelBase associated with a specific \b UIControlState
 *
 * @param state The \b UIControlState that a button could be in
 *
 * @return Returns the retained \b DHSGlyphLabelBase instance requested
 */
- (DHSGlyphLabelBase *)glyphLabelForState:(UIControlState)state;


#pragma mark -
#pragma mark Efficiency Optimization methods

//
// Efficiency Optimization methods
//

/**
 * Whether the button labels should save rendered images for a particular set of parameters in a cache
 *
 * @return Returns \b YES if the images will be cached or \b NO if not
 */
- (BOOL)shouldCache;

/**
 * Sets whether the button labels should save rendered images for a particular set of parameters in a cache
 *
 * @param shouldCache the state of caching
 */
- (void)setShouldCache:(BOOL)shouldCache;

/**
 * Button label images are lazy rendered at the last possible moment after all parameters have been set.
 * This method will force the rendering of the image when desired, but only if their parameters have changed.
 *
 */
- (void)setImagesIfNeedsUpdate;


#pragma mark -
#pragma mark Label Font Handling methods

//
// Label Font Handling methods
//

/**
 * Create and set a \b DHSGlyphFont instance based on a \b UIFont for the system identifier key for all button states
 *
 * @param font The \b UIFont instance to convert into a \b DHSGlyphFont. The \b UIFont instance is not retained.
 */
- (void)setSystemFont:(UIFont *)font;

/**
 * Create a \b DHSGlyphFont instance and set it for a provided identifier and retain it in the labels for all button states
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 *
 * @return Whether or not the font could be created and set
 */
- (void)setFontName:(NSString *)fontName forKey:(NSString *)key;

/**
 * Create a \b DHSGlyphFont instance and set it for a provided identifier and retain it in the label for only one button state
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 * @param state The \b UIControlState that will be affected
 *
 * @return Whether or not the font could be created and set
 */
- (void)setFontName:(NSString *)fontName forKey:(NSString *)key forState:(UIControlState)state;

/**
 * Create a \b DHSGlyphFont instance and set it for the default font key ( \b kDHSGlyphDefaultKey ) and retain it in the labels
 *          for all button states
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 *
 * @return Whether or not the font could be created and set
 */
- (void)setDefaultFontName:(NSString *)fontName;

/**
 * Create a \b DHSGlyphFont instance and set it for the system font key ( \b kDHSGlyphSystemKey ) and retain it in the labels
 *          for all button states
 *
 * @param fontName The name of the font in the main bundle used to create the \b DHSGlyphFont instance to retain
 *
 * @return Whether or not the font could be created and set
 */
- (void)setSystemFontName:(NSString *)fontName;

/**
 * Set the font size in all fonts retained in the labels for all button states
 *
 * @param fontSize The size for the glyphs of all the fonts in points
 */
- (void)setFontSize:(CGFloat)fontSize;

/**
 * Set the font size in the font stored for a provided identifier that is retained in the labels for all button states
 *
 * @param fontSize The size for the glyphs of the font in points
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key;

/**
 * Set the font size in the font stored for a provided identifier that is retained in the label for only one button state
 *
 * @param fontSize The size for the glyphs of the font in points
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 * @param state The \b UIControlState that will be affected
 */
- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key forState:(UIControlState)state;

/**
 * Set the font scale factor in all fonts retained in the labels for all button states
 *
 * @param fontScaleFactor The scale for the width (x) and height (y) for the glyphs of the fonts, relative to the default.
 *          This does not change the relative spacing between the glyphs.
 */
- (void)setFontScaleFactor:(CGPoint)fontScaleFactor;

/**
 * Set the font scale factor in the font stored for a provided identifier that is retained in the labels for all button states
 *
 * @param fontScaleFactor The scale for the width (x) and height (y) for the glyphs of the font, relative to the default.
 *          This does not change the relative spacing between the glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key;

/**
 * Set the font scale factor in the font stored for a provided identifier that is retained in the label for only one button state
 *
 * @param fontScaleFactor The scale for the width (x) and height (y) for the glyphs of the font, relative to the default.
 *          This does not change the relative spacing between the glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 * @param state The \b UIControlState that will be affected
 */
- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key forState:(UIControlState)state;

/**
 * Set, and override the default, font descender ratio in all fonts retained in the labels for all button states
 *
 * @param fontDescenderRatio The descender ratio for the glyphs of the font in points.
 *          The default is defined as the font descent in points divided by the font size in points.
 */
- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio;

/**
 * Set, and override the default, font descender ratio in the font stored for a provided identifier that is retained in the labels
 *          for all button states
 *
 * @param fontDescenderRatio The descender ratio for the glyphs of the font in points.
 *          The default is defined as the font descent in points divided by the font size in points.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key;

/**
 * Set, and override the default, font descender ratio in the font stored for a provided identifier that is retained in the label
 *          for only one button state
 *
 * @param fontDescenderRatio The descender ratio for the glyphs of the font in points.
 *          The default is defined as the font descent in points divided by the font size in points.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 * @param state The \b UIControlState that will be affected
 */
- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key forState:(UIControlState)state;

/**
 * Set the font glyph expansion multiplier in all fonts retained in the labels for all button states
 *
 * @param fontGlyphExpansionMultiplier The amount the space in between glyphs will be expanded or compressed,
 *          relative to the default of the font. This does not change the width or height of individual glyphs.
 */
- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier;

/**
 * Set the font glyph expansion multiplier in the font stored for a provided identifier that is retained in the labels
 *           for all button states
 *
 * @param fontGlyphExpansionMultiplier The amount the space in between glyphs will be expanded or compressed,
 *          relative to the default of the font. This does not change the width or height of individual glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 */
- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key;

/**
 * Set the font glyph expansion multiplier in the font stored for a provided identifier that is retained in the label
 *           for only one button state
 *
 * @param fontGlyphExpansionMultiplier The amount the space in between glyphs will be expanded or compressed,
 *          relative to the default of the font. This does not change the width or height of individual glyphs.
 * @param key The identifier, usually a localized language or one of \b kDHSGlyphDefaultKey or \b kDHSGlyphDefaultKey
 * @param state The \b UIControlState that will be affected
 */
- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key forState:(UIControlState)state;


#pragma mark -
#pragma mark Label Glyph Rendering Parameter methods

//
// Label Glyph Rendering Parameter methods
//

/**
 * Set the color of the stroke outline of the text retained in the labels for all button states
 *
 * @param strokeColor the color of the stroke outline
 */
- (void)setStrokeColor:(UIColor *)strokeColor;

/**
 * Set the color of the stroke outline of the text retained in the label for only one button state
 *
 * @param strokeColor the color of the stroke outline
 * @param state The \b UIControlState that will be affected
 */
- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state;

/**
 * Set the width of the stroke outline of the text stored in the labels for all button states
 *
 * @param strokeWidth the width of the stroke outline in points
 */
- (void)setStrokeWidth:(CGFloat)strokeWidth;

/**
 * Set the width of the stroke outline of the text stored in the label for only one button state
 *
 * @param strokeWidth the width of the stroke outline in points
 * @param state The \b UIControlState that will be affected
 */
- (void)setStrokeWidth:(CGFloat)strokeWidth forState:(UIControlState)state;

/**
 * Set the shadow offset of the text stored in the labels for all button states
 *
 * @param shadowOffset the width and height of the offset in points
 */
- (void)setShadowOffset:(CGSize)shadowOffset;

/**
 * Set the shadow offset of the text stored in the label for only one button state
 *
 * @param shadowOffset the width and height of the offset in points
 * @param state The \b UIControlState that will be affected
 */
- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)state;

/**
 * Set the blur fade multiplier of the text drop shadow stored in the labels for all button states
 *
 * @param shadowBlur the blur fade strength
 */
- (void)setShadowBlur:(CGFloat)shadowBlur;

/**
 * Set the blur fade multiplier of the text drop shadow stored in the label for only one button state
 *
 * @param shadowBlur the blur fade strength
 * @param state The \b UIControlState that will be affected
 */
- (void)setShadowBlur:(CGFloat)shadowBlur forState:(UIControlState)state;

/**
 * Set whether the shadow, if used, should be applied to the stroke outline of the text stored in the labels
 *          for all button states
 *
 * @param strokeHasShadow whether or not the shadow should be applied to the stroke
 */
- (void)setStrokeHasShadow:(BOOL)strokeHasShadow;

/**
 * Set whether the shadow, if used, should be applied to the stroke outline of the text stored in the label
 *          for only one button state
 *
 * @param strokeHasShadow whether or not the shadow should be applied to the stroke
 * @param state The \b UIControlState that will be affected
 */
- (void)setStrokeHasShadow:(BOOL)strokeHasShadow forState:(UIControlState)state;

/**
 * Whether the text should shift to the button's drop shadow offset ( as defined by \b shadowOffset ) so
 *          it can be used for a button press in the labels for all button states
 *
 * @param shifts whether the text should shift or not
 */
- (void)setShiftsToShadowOffset:(BOOL)shifts;

/**
 * Whether the text should shift to the button's drop shadow offset ( as defined by \b shadowOffset ) so
 *          it can be used for a button press in the label for only one button state
 *
 * @param shifts whether the text should shift or not
 * @param state The \b UIControlState that will be affected
 */
- (void)setShiftsToShadowOffset:(BOOL)shifts forState:(UIControlState)state;

/**
 * Set the color of the glow halo blur around the text retained in the labels for all button states
 *
 * @param glowColor the color of the glow halo blur
 */
- (void)setGlowColor:(UIColor *)glowColor;

/**
 * Set the color of the glow halo blur around the text retained in the label for only one button state
 *
 * @param glowColor the color of the glow halo blur
 * @param state The \b UIControlState that will be affected
 */
- (void)setGlowColor:(UIColor *)glowColor forState:(UIControlState)state;

/**
 * Set the blur fade multiplier for text glow halo around the text stored in the labels for all button states
 *
 * @param glowBlur the blur fade strength
 */
- (void)setGlowBlur:(CGFloat)glowBlur;

/**
 * Set the blur fade multiplier for text glow halo around the text stored in the label for only one button state
 *
 * @param glowBlur the blur fade strength
 * @param state The \b UIControlState that will be affected
 */
- (void)setGlowBlur:(CGFloat)glowBlur forState:(UIControlState)state;

/**
 * Set the gradient used to fill the text retained in the labels for all button states.
 *          The gradient can be either linear or radial depending on how \b (BOOL) \b radialGradient is set.
 *
 * @param gradient the gradient
 */
- (void)setGradient:(CGGradientRef)gradient;

/**
 * Set the gradient used to fill the text retained in the label for only one button state.
 *          The gradient can be either linear or radial depending on how \b (BOOL) \b radialGradient is set.
 *
 * @param gradient the gradient
 * @param state The \b UIControlState that will be affected
 */
- (void)setGradient:(CGGradientRef)gradient forState:(UIControlState)state;

/**
 * Whether the gradient set by \b setGradient is radial or not in the labels for all button states
 *
 * @param radialGradient the gradient is radial if \b YES or linear if \b NO
 */
- (void)setRadialGradient:(BOOL)radialGradient;

/**
 * Whether the gradient set by \b setGradient is radial or not in the label for only one button state
 *
 * @param radialGradient the gradient is radial if \b YES or linear if \b NO
 * @param state The \b UIControlState that will be affected
 */
- (void)setRadialGradient:(BOOL)radialGradient forState:(UIControlState)state;

/**
 * Whether the stroke that is displayed outlines all glyphs or each glyph individually in the labels for all button states
 *
 * @param showIndividualGlyphStroke the strokes are displayed individually if \b YES or around all glyphs if \b NO
 */
- (void)setShowIndividualGlyphStroke:(BOOL)showIndividualGlyphStroke;

/**
 * Whether the stroke that is displayed outlines all glyphs or each glyph individually in the label for only one button state
 *
 * @param showIndividualGlyphStroke the strokes are displayed individually if \b YES or around all glyphs if \b NO
 * @param state The \b UIControlState that will be affected
 */
- (void)setShowIndividualGlyphStroke:(BOOL)showIndividualGlyphStroke forState:(UIControlState)state;

/**
 * Whether the glow that is displayed outlines all glyphs or each glyph individually in the labels for all button states
 *
 * @param showIndividualGlyphGlow the glows are displayed individually if \b YES or around all glyphs if \b NO
 */
- (void)setShowIndividualGlyphGlow:(BOOL)showIndividualGlyphGlow;

/**
 * Whether the glow that is displayed outlines all glyphs or each glyph individually in the label for only one button state
 *
 * @param showIndividualGlyphGlow the strokes are displayed individually if \b YES or around all glyphs if \b NO
 * @param state The \b UIControlState that will be affected
 */
- (void)setShowIndividualGlyphGlow:(BOOL)showIndividualGlyphGlow forState:(UIControlState)state;

/**
 * The order that the glyphs will be displayed and handle overlaps after the typesetter lays them out in the labels for all button states
 *
 * @param glyphRenderOrder the render order to set
 */
- (void)setGlyphRenderOrder:(DHSGlyphLabelGlyphRenderOrder)glyphRenderOrder;

/**
 * The order that the glyphs will be displayed and handle overlaps after the typesetter lays them out in the label for only one button state
 *
 * @param glyphRenderOrder the render order to set
 * @param state The \b UIControlState that will be affected
 */
- (void)setGlyphRenderOrder:(DHSGlyphLabelGlyphRenderOrder)glyphRenderOrder forState:(UIControlState)state;


#pragma mark -
#pragma mark Label Display Rendering Parameter methods

//
// Label Display Rendering Parameter methods
//

/**
 * Set the transparency multiplier for image generated from the label for only one button state
 *
 * @param alpha the transparency
 * @param state The \b UIControlState that will be affected
 */
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;

@end
