//
//  DHSGlyphLabelBase.m
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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "DHSGlyphCache.h"
#import "DHSGlyphSizeCache.h"

#import "DHSGlyphLabel+Private.h"
#import "DHSGlyphTypesetter+Private.h"
#import "DHSGlyphTypesetter.h"


#define DHSGLYPH_DEFAULT_SHOULD_CACHE   YES
#define DHSGLYPH_DEFAULT_FONT_SIZE      12.0f


@interface DHSGlyphLabel () {
    NSMutableDictionary *_fonts;
}

// Properties
@property (nonatomic, readwrite)    CGGlyph *glyphs;
@property (nonatomic, readwrite)    CGPoint *points;
@property (nonatomic, readwrite)    CGSize *sizes;
@property (nonatomic, readwrite)    CGFloat *rotations;

@end

@implementation DHSGlyphLabel

#pragma mark -
#pragma mark Class methods

+ (void)initialize {    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [[DHSGlyphCache cache] load];
        [[DHSGlyphSizeCache cache] load];
    });
}


#pragma mark -
#pragma mark Subclassing methods

- (void)setDefaults {
    // Subclasses must call super
    [self.layer setDrawsAsynchronously:YES];
	[self setBackgroundColor:[UIColor clearColor]];
    [self setNumberOfLines:0]; // Layout will decide this
    
    _shouldCache = DHSGLYPH_DEFAULT_SHOULD_CACHE;
    
	_strokeColor = [UIColor blackColor];
	_strokeWidth = 0.25f;
	
	_shadowBlur = 2.0f;
	_strokeHasShadow = NO;
    _shiftsToShadowOffset = NO;

	_glowColor = nil;
	_glowBlur = 5.0f;
    _showIndividualGlyphGlow = NO;
	
	_gradient = NULL;
    _radialGradient = NO;
	
    _showIndividualGlyphStroke = NO;
    _glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderForwards;
    
    _typesetter = [DHSGlyphTypesetter new];
    
    _fonts = [[NSMutableDictionary alloc] initWithCapacity:3];
    _currentFont = nil;
    if (_glyphs) free(_glyphs);
    _glyphs = NULL;
    if (_points) free(_points);
    _points = NULL;
    if (_sizes) free(_sizes);
    _sizes = NULL;
    if (_rotations) free(_rotations);
    _rotations = NULL;
    
    if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    if ([self.layer respondsToSelector:@selector(setContentsScale:)]) {
        self.layer.contentsScale = [[UIScreen mainScreen] scale];
    }
    
    _preferDefaultFont = YES;
	[self setFontName:self.font.fontName forKey:kDHSGlyphSystemKey];
    [self setFontSize:self.font.pointSize forKey:kDHSGlyphSystemKey];
    
	// Choose the font
    [self selectCurrentFont];
}

- (NSDictionary *)layoutInfo {
    // A subclass must overwrite this method to support the typesetters it uses
    // This method will be called every time just before layout
    if (self.typesetter == nil) return [NSDictionary dictionary];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:self.typesetter.layoutInfo];
    
    // Must be typesetter specific
    if ([self.typesetter isKindOfClass:[DHSGlyphTypesetter class]]) {
        // For subclasses that need to call super (but not this one since it has no super)
        // [info addEntriesFromDictionary:[super layoutInfo]];

        // Do nothing
    }
    
    return [NSDictionary dictionaryWithDictionary:info];
}

- (void)prerenderCalculate {
    // Subclasses must overload this and call super
}


#pragma mark -
#pragma mark Initialization methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		[self setDefaults];
	}
	return self;
}

- (id)init {
    if (self = [super init]) {
		[self setDefaults];
    }
    return self;
}


#pragma mark -
#pragma mark UILabel methods

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    [super setNumberOfLines:0];     // layout will handle this
}


#pragma mark -
#pragma mark Object methods

- (void)setShouldCache:(BOOL)shouldCache {
    if (_shouldCache != shouldCache && shouldCache == NO) {
        // This would wipe for all instances so it's probably bad
        // [[DHSGlyphCache cache] wipe];
        // [[DHSGlyphSizeCache cache] wipe];
    }
    
    _shouldCache = shouldCache;
    
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        [obj setShouldCache:_shouldCache];
    }];
    _typesetter.shouldCache = _shouldCache;
}

- (void)setPreferDefaultFont:(BOOL)preferDefaultFont {
    if (_preferDefaultFont == preferDefaultFont) return;
    _preferDefaultFont = preferDefaultFont;
    
    [self selectCurrentFont];
}

- (void)setShiftsToShadowOffset:(BOOL)shiftsToShadowOffset {
    if (_shiftsToShadowOffset == shiftsToShadowOffset) return;
    _shiftsToShadowOffset = shiftsToShadowOffset;
    
    [self resetPoints];
}

- (void)setGradient:(CGGradientRef)gradient {
	if (_gradient == gradient) return;
	
	CGGradientRelease(_gradient);
	_gradient = CGGradientRetain(gradient);
    
    // Keep points
	[super setNeedsDisplay];
}

- (void)setShowIndividualGlyphStroke:(BOOL)showIndividualGlyphStroke {
    if (_showIndividualGlyphStroke == showIndividualGlyphStroke) return;
    _showIndividualGlyphStroke = showIndividualGlyphStroke;
    
    // Keep points
	[super setNeedsDisplay];
}

- (void)setShowIndividualGlyphGlow:(BOOL)showIndividualGlyphGlow {
    if (_showIndividualGlyphGlow == showIndividualGlyphGlow) return;
    _showIndividualGlyphGlow = showIndividualGlyphGlow;
    
    // Keep points
	[super setNeedsDisplay];
}

- (void)setGlyphRenderOrder:(DHSGlyphLabelGlyphRenderOrder)glyphRenderOrder {
    if (_glyphRenderOrder == glyphRenderOrder || glyphRenderOrder >= DHSGlyphLabelGlyphRenderOrderCount) return;
    _glyphRenderOrder = glyphRenderOrder;
    
    // Keep points
	[super setNeedsDisplay];
}

- (void)setTypesetter:(DHSGlyphTypesetter *)typesetter {
    if (_typesetter == typesetter) return;
    _typesetter = typesetter;
    
    // Setup typesetter with current values
    self.typesetter.shouldCache = _shouldCache;
    self.typesetter.layoutInfo = self.layoutInfo;
    
    [self resetPoints];
}


#pragma mark -
#pragma mark Font handling methods

- (DHSGlyphFont *)fontForKey:(NSString *)key {
    if (key == nil) return nil;
    
    return _fonts[key];
}

- (void)resetPoints {
    // Only call this if a state change will affect the layout.
    // Call setNeedsDisplay if a state change will not change the layout but the rendering is affected.
    if (_points) free(_points);
    _points = NULL;
    if (_sizes) free(_sizes);
    _sizes = NULL;
    if (_rotations) free(_rotations);
    _rotations = NULL;
    
    [self setNeedsDisplay];
}

- (DHSGlyphFont *)bestFontWithGlyphs:(BOOL)getGlyphs {
    __block DHSGlyphFont *retval = nil;
    
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        if ([key isEqualToString:kDHSGlyphDefaultKey] == NO && [key isEqualToString:kDHSGlyphSystemKey] == NO) {
            if (getGlyphs) {
                if ([obj getGlyphs:_glyphs forText:self.text]) {
                    retval = obj;
                    *stop = YES;
                }
            } else {
                if ([obj canRenderText:self.text]) {
                    retval = obj;
                    *stop = YES;
                }
            }
        }
    }];
    
    return retval;
}

- (void)selectCurrentFont {
    // Prep space for layout
    if (_glyphs) free(_glyphs);
    _glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * self.text.length);
    [self resetPoints];

    if (_preferDefaultFont) {
        // Use default font if possible
        DHSGlyphFont *font = [self fontForKey:kDHSGlyphDefaultKey];
        if ([font getGlyphs:_glyphs forText:self.text]) {
            _currentFont = font;
        } else {
            // Check the preferred language
            font = [self fontForPreferredLanguage];
            if ([font getGlyphs:_glyphs forText:self.text]) {
                _currentFont = font;
            } else {
                // Check all non-default and non-system fonts
                font = [self bestFontWithGlyphs:YES];
                if (font) {
                    _currentFont = font;
                } else {
                    // Finally, use the system font as a last resort
                    font = [self fontForKey:kDHSGlyphSystemKey];
                    [font getGlyphs:_glyphs forText:self.text];
                    _currentFont = font;
                }
            }
        }
    } else {
        // Use the font of the preferred language if possible
        DHSGlyphFont *font = [self fontForPreferredLanguage];
        if ([font getGlyphs:_glyphs forText:self.text]) {
            _currentFont = font;
        } else {
            // Check the default language
            font = [self fontForKey:kDHSGlyphDefaultKey];
            if ([font getGlyphs:_glyphs forText:self.text]) {
                _currentFont = font;
            } else {
                // Check all non-default and non-system fonts
                font = [self bestFontWithGlyphs:YES];
                if (font) {
                    _currentFont = font;
                } else {
                    // Finally, use the system font as a last resort
                    font = [self fontForKey:kDHSGlyphSystemKey];
                    [font getGlyphs:_glyphs forText:self.text];
                    _currentFont = font;
                }
            }
        }
    }
}

- (DHSGlyphFont *)fontForText:(NSString *)text {
    DHSGlyphFont *font = nil;
    
    if (_preferDefaultFont) {
        // Use default font if possible
        font = [self fontForKey:kDHSGlyphDefaultKey];
        if ([font canRenderText:self.text]) {
            return font;
        } else {
            // Check the preferred language
            font = [self fontForPreferredLanguage];
            if ([font canRenderText:self.text]) {
                return font;
            } else {
                // Check all non-default and non-system fonts
                font = [self bestFontWithGlyphs:NO];
                if (font) {
                    return font;
                } else {
                    // Finally, use the system font as a last resort
                    return [self fontForKey:kDHSGlyphSystemKey];
                }
            }
        }
    } else {
        // Use the font of the preferred language if possible
        font = [self fontForPreferredLanguage];
        if ([font canRenderText:self.text]) {
            return font;
        } else {
            // Check the default language
            font = [self fontForKey:kDHSGlyphDefaultKey];
            if ([font canRenderText:self.text]) {
                return font;
            } else {
                // Check all non-default and non-system fonts
                font = [self bestFontWithGlyphs:NO];
                if (font) {
                    return font;
                } else {
                    // Finally, use the system font as a last resort
                    return [self fontForKey:kDHSGlyphSystemKey];
                }
            }
        }
    }
    
    return font;
}

- (void)setFont:(DHSGlyphFont *)font forKey:(NSString *)key {
    if (font == nil || key == nil) return;
    
    _fonts[key] = font;
    [self selectCurrentFont];
}

- (void)setFont:(UIFont *)font {
	[self setFontName:font.fontName forKey:kDHSGlyphSystemKey];
}

- (void)setSystemFont:(UIFont *)font {
    [self setFont:font];
}

- (DHSGlyphFont *)fontForPreferredLanguage {
    return [self fontForKey:[self keyForPreferredLanguage]];
}

- (NSString *)keyForPreferredLanguage {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (BOOL)setFontName:(NSString *)fontName forKey:(NSString *)key {
    DHSGlyphFont *font = [self fontForKey:key];
    if (font) {
        [font setFontName:fontName];
    } else {
        font = [[DHSGlyphFont alloc] initWithFontName:fontName andSize:self.font.pointSize > 0.0f ? self.font.pointSize : DHSGLYPH_DEFAULT_FONT_SIZE];
        [font setShouldCache:_shouldCache];
    }
    
    if ([font ctFont]) {
        _fonts[key] = font;
        [self selectCurrentFont];
        return YES;
    } else {
        [self selectCurrentFont];
        return NO;
    }
}

- (BOOL)setDefaultFontName:(NSString *)fontName {
    return [self setFontName:fontName forKey:kDHSGlyphDefaultKey];
}

- (BOOL)setSystemFontName:(NSString *)fontName {
    return [self setFontName:fontName forKey:kDHSGlyphSystemKey];
}

- (void)setFontSize:(CGFloat)fontSize {
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        obj.fontSize = fontSize;
    }];
    
    [self resetPoints];
}

- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key {
    DHSGlyphFont *font = [self fontForKey:key];
    font.fontSize = fontSize;
    
    [self resetPoints];
}

- (void)setFontScaleFactor:(CGPoint)fontScaleFactor {
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        obj.scaleFactor = fontScaleFactor;
    }];
    
    [self resetPoints];
}

- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key {
    DHSGlyphFont *font = [self fontForKey:key];
    font.scaleFactor = fontScaleFactor;
    
    [self resetPoints];
}

- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio {
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        obj.descenderRatio = fontDescenderRatio;
    }];
    
    [self resetPoints];
}

- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key {
    DHSGlyphFont *font = [self fontForKey:key];
    font.descenderRatio = fontDescenderRatio;
    
    [self resetPoints];
}

- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier {
    [_fonts enumerateKeysAndObjectsUsingBlock:^(NSString *key, DHSGlyphFont *obj, BOOL *stop) {
        obj.glyphExpansionMultiplier = fontGlyphExpansionMultiplier;
    }];
    
    [self resetPoints];
}

- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key {
    DHSGlyphFont *font = [self fontForKey:key];
    font.glyphExpansionMultiplier = fontGlyphExpansionMultiplier;
    
    [self resetPoints];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
	// Choose the font
    [self selectCurrentFont];
}


#pragma mark -
#pragma mark Text drawing methods

- (void)processRenderOrder:(DHSGlyphLabelGlyphRenderOrder)renderOrder
             forNewIndexes:(NSInteger *)indexes
                withLength:(NSInteger)length {
    
    if (indexes == NULL || length == 0) return;

    // indexes array must already be allocated with size length

    // Subclasses can extend DHSGlyphLabelGlyphRenderOrder to add new rendering orders
    // and may or may not call this super
    
    //
    // Reorder indexes
    //
    
    switch (renderOrder) {
        default:
        case DHSGlyphLabelGlyphRenderOrderForwards:
            for (NSInteger i = 0; i < length; ++i) {
                indexes[i] = i;
            }
            break;
            
        case DHSGlyphLabelGlyphRenderOrderBackwards:
            for (NSInteger i = 0; i < length; ++i) {
                indexes[i] = length - i - 1;
            }
            break;
            
        case DHSGlyphLabelGlyphRenderOrderOutsideIn:
            for (NSInteger i = 0; i < (length >> 1); ++i) {
                NSInteger index = i << 1;
                debugLog(@"OI index order: %ld=%ld, %ld=%ld", (long)index, (long)i, (long)index + 1, (long)length - i - 1);
                
                indexes[index] = i;
                indexes[index + 1] = length - i - 1;
            }
            if (length & 1) {
                NSInteger i = (length >> 1);
                debugLog(@"OI index order center: %ld=%ld", (long)length - 1, (long)i);
                
                indexes[length - 1] = i;
            }
            break;
            
        case DHSGlyphLabelGlyphRenderOrderInsideOut:
            for (NSInteger i = 0; i < (length >> 1); ++i) {
                NSInteger index = (length - 2) - (i << 1);
                debugLog(@"OI index order: %ld=%ld, %ld=%ld", (long)index, (long)i, (long)index + 1, (long)length - i - 1);
                
                indexes[index] = i;
                indexes[index + 1] = length - i - 1;
            }
            if (length & 1) {
                NSInteger i = (length >> 1);
                debugLog(@"OI index order center: %d=%ld", 0, (long)i);
                
                indexes[0] = i;
            }
            break;
            
        case DHSGlyphLabelGlyphRenderOrderEven:
        {
            NSInteger index = 0;
            for (NSInteger i = 0; i < length; ++index, i += 2) {
                indexes[index] = i;
            }
            for (NSInteger i = 1; i < length; ++index, i += 2) {
                indexes[index] = i;
            }
        }
            break;
            
        case DHSGlyphLabelGlyphRenderOrderOdd:
        {
            NSInteger index = 0;
            for (NSInteger i = 1; i < length; ++index, i += 2) {
                indexes[index] = i;
            }
            for (NSInteger i = 0; i < length; ++index, i += 2) {
                indexes[index] = i;
            }
        }
            break;
    }
}

- (void)reorderRenderValuesForIndexes:(NSInteger *)indexes
                            forGlyphs:(CGGlyph *)glyphs
                             atPoints:(CGPoint *)points
                             andSizes:(CGSize *)sizes
                        withRotations:(CGFloat *)rotations
                            andLength:(NSInteger)length {
    
    if (glyphs == NULL || points == NULL || sizes == NULL || rotations == NULL || length == 0) return;

    // glyhps, points and rotations arrays must already be allocated with size length
    
    for (NSInteger i = 0; i < length; ++i) {
        glyphs[i] = _glyphs[indexes[i]];
        points[i] = _points[indexes[i]];
        sizes[i] = _sizes[indexes[i]];
        rotations[i] = _rotations[indexes[i]];
    }
    
    if (_rotations[0] == DHSGLYPH_NO_ROTATION) rotations[0] = DHSGLYPH_NO_ROTATION;
}

- (void)drawGlyph:(CGGlyph)glyph
      withContext:(CGContextRef)context
          atPoint:(CGPoint)point
         withSize:(CGSize)size
      andRotation:(CGFloat)rotation {

    // Save Context
    // CGContextSaveGState(context);
	CGAffineTransform textMatrixSave = CGContextGetTextMatrix(context);

    // Find glyph center X translation adjustment
    CGFloat centerX = point.x + (size.width / 2.0f);
    
    // Find glyph center Y translation adjustment around baseline
    CGFloat myDescender;
    if (_currentFont.descenderRatio == MAXFLOAT) {
        myDescender = CTFontGetDescent(_currentFont.ctFont);
    } else {
        myDescender = _currentFont.descenderRatio * (_currentFont.fontSize * _currentFont.scaleFactor.y);
    }
    CGFloat centerY = point.y + myDescender;
    
    // Handle rotation
    CGAffineTransform textTransform = CGAffineTransformTranslate(textMatrixSave, centerX, centerY);
    textTransform = CGAffineTransformRotate(textTransform, rotation);
    textTransform = CGAffineTransformTranslate(textTransform, -centerX, -centerY);
	CGContextSetTextMatrix(context, textTransform);
    
    // Handle any other individual glyph specific render settings here
    
    // Render glyph
    CTFontDrawGlyphs(_currentFont.ctFont, &glyph, &point, 1, context);
    
    // Restore Context
	CGContextSetTextMatrix(context, textMatrixSave);
    // CGContextRestoreGState(context);
}

- (void)drawGlyphs:(CGGlyph *)glyphs
       withContext:(CGContextRef)context
          atPoints:(CGPoint *)points
          andSizes:(CGSize *)sizes
     withRotations:(CGFloat *)rotations
         andLength:(NSInteger)length {

    // Decide whether text can be rendered in blocks or only as individual glyphs
    // e.g. If glyphs had individual fill colors, that would be decided here, but set and rendered in
    // drawGlyph:withContext:atPoint:withSize:andRotation:
    
    if (rotations[0] == DHSGLYPH_NO_ROTATION) {
        // No rotation or other individual glyph effect, so render all at once
        CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
    } else {
        // Rotation or other individual glyph effects require glyphs be rendered individually
        for (NSInteger i = 0; i < length; ++i) {
            [self drawGlyph:glyphs[i]
                withContext:context
                    atPoint:points[i]
                   withSize:sizes[i]
                andRotation:rotations[i]];
        }
    }
}

- (void)drawLabelWithContext:(CGContextRef)context
                      inRect:(CGRect)rect
                   forGlyphs:(CGGlyph *)glyphs
                    atPoints:(CGPoint *)points
                    andSizes:(CGSize *)sizes
               withRotations:(CGFloat *)rotations
                   andLength:(NSInteger)length {

	debugLog(@"Attempting to draw label text: %@ (%@)", self.text, _currentFont.fontName);
    
	// Bail if there's nothing to draw
	if (self.text == nil || self.text.length == 0 || length == 0) return;
    if (glyphs == NULL || points == NULL || sizes == NULL || rotations == NULL) return;
    if (_currentFont == nil) return;
    
    // Uncomment below to test rotations
    // for (NSInteger i = 0; i < length; ++i) rotations[i] = M_PI_2;
    
    //
    // Render unrotated glyphs (rotation not yet supported)
    //
    
    // Save Context
    CGContextSaveGState(context);
    
	//
	// Set the customFont and other params to be the font used to draw
	//
	
	CGContextSetShouldAntialias(context, YES);  
	CGContextSetShouldSmoothFonts(context, YES);
	CGContextSetAllowsAntialiasing(context, YES);
	
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	
	// The text is upside down so change it
	CGAffineTransform textTransform = CGAffineTransformMakeScale(_currentFont.scaleFactor.x, -_currentFont.scaleFactor.y);
	CGContextSetTextMatrix(context, textTransform);
	
	//
	// Draw glow
	//
	
	if (self.glowColor && self.glowBlur > 0.0f) {
		
        // Save Context
        if (_showIndividualGlyphGlow == NO) CGContextSaveGState(context);

		// Make this render white first
		CGContextSetFillColorWithColor(context, NULL);
		CGContextSetStrokeColorWithColor(context, NULL);
		
		CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), self.glowBlur, self.glowColor.CGColor);
        
		// Set the drawing mode based on if there is an outline
		if (self.strokeWidth > 0.0f) {
			CGContextSetTextDrawingMode(context, kCGTextFillStroke);
		} else {
			CGContextSetTextDrawingMode(context, kCGTextFill);
		}
		
		// draw the glow around a clear rendering of the glyphs for real
        // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
        [self drawGlyphs:glyphs
             withContext:context
                atPoints:points
                andSizes:sizes
           withRotations:rotations
               andLength:length];

        // Restore Context
        if (_showIndividualGlyphGlow == NO) CGContextRestoreGState(context);

    }
	   
	//
	// Color Setup
	//
	
    CGColorRef useStrokeColor = self.strokeColor.CGColor;
    CGColorRef useFillColor = self.gradient ? NULL : self.textColor.CGColor;
    CGColorRef useShadowColor = self.shadowColor.CGColor;
    CGFloat useStrokeWidth = self.strokeWidth;
    
    if (self.showIndividualGlyphStroke) useStrokeWidth = 0.0f;
    if (useStrokeWidth == 0.0f) useStrokeColor = NULL;
    if (CGSizeEqualToSize(self.shadowOffset, CGSizeZero)) useShadowColor = NULL;
    
	CGContextSetLineWidth(context, useStrokeWidth);
    CGContextSetStrokeColorWithColor(context, useStrokeColor);
    CGContextSetFillColorWithColor(context, useFillColor);
    
 	//
	// Draw shadow
	//

    // Save Context
    CGContextSaveGState(context);

    if (self.strokeHasShadow == NO ||
        useStrokeWidth == 0.0f ||
        CGSizeEqualToSize(self.shadowOffset, CGSizeZero) ||
        useShadowColor == NULL) {
        // Without stroke shadow
        
        if (useShadowColor && CGSizeEqualToSize(self.shadowOffset, CGSizeZero) == NO) {
            
            if (self.shiftsToShadowOffset) {
                // Put the text over the shadow and move the whole thing with an adjustment
                CGContextSetShadowWithColor(context, CGSizeZero, self.shadowBlur, useShadowColor);
            } else {
                CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, useShadowColor);
            }
            
            // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
            [self drawGlyphs:glyphs
                 withContext:context
                    atPoints:points
                    andSizes:sizes
               withRotations:rotations
                   andLength:length];
            CGContextSetShadowWithColor(context, CGSizeZero, 0.0f, NULL);
            
        }
        
    } else {
        // With stroke shadow
        
        if (useShadowColor) {
            if (self.shiftsToShadowOffset) {
                // Put the text over the shadow and move the whole thing with an adjustment
                CGContextSetShadowWithColor(context, CGSizeZero, self.shadowBlur, useShadowColor);
            } else {
                CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, useShadowColor);
            }
        }
        
    }
    
    // Restore Context
    CGContextRestoreGState(context);

    //
    // Draw text
    //
    
    // Set properties
    if (useFillColor && useStrokeWidth > 0.0f && useStrokeColor) {
        // Stroke and Fill
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    } else if (self.gradient || (useFillColor && (useStrokeWidth == 0.0f || useStrokeColor == NULL))) {
        // Fill Only
        CGContextSetTextDrawingMode(context, kCGTextFill);
    } else {
        // Stroke only
        CGContextSetTextDrawingMode(context, kCGTextStroke);
    }
    
    // draw the glyphs for real
    // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
    [self drawGlyphs:glyphs
         withContext:context
            atPoints:points
            andSizes:sizes
       withRotations:rotations
           andLength:length];
    CGContextSetShadowWithColor(context, CGSizeZero, 0.0f, NULL);
    
    //
	// Draw gradient
	//
	
	if (self.gradient) {
		
        // Draw bounding stroke
        useStrokeWidth = self.strokeWidth;
        useStrokeColor = self.strokeColor.CGColor;
        if (useStrokeWidth == 0.0f) useStrokeColor = NULL;
        if (useStrokeWidth && useStrokeColor) {
            CGContextSetLineWidth(context, useStrokeWidth);
            CGContextSetStrokeColorWithColor(context, useStrokeColor);
            CGContextSetFillColorWithColor(context, NULL);
            CGContextSetTextDrawingMode(context, kCGTextStroke);
            // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
            [self drawGlyphs:glyphs
                 withContext:context
                    atPoints:points
                    andSizes:sizes
               withRotations:rotations
                   andLength:length];
        }
        
        // Set transform
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextScaleCTM(context, _currentFont.scaleFactor.x, -_currentFont.scaleFactor.y);
		
		// Draw text clipping path
        CGContextSetTextDrawingMode(context, kCGTextClip);
        // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
        [self drawGlyphs:glyphs
             withContext:context
                atPoints:points
                andSizes:sizes
           withRotations:rotations
               andLength:length];
        
		// Fill text clipping path with gradient
        if (_radialGradient) {
            CGPoint start = CGPointMake(CGRectGetMidX(rect) / _currentFont.scaleFactor.x,
                                        -CGRectGetMidY(rect) / _currentFont.scaleFactor.y);
            CGPoint end = start;
            CGContextDrawRadialGradient(context, self.gradient,
                                        start, 0.0f,
                                        end, CGRectGetHeight(rect) / _currentFont.scaleFactor.x / _currentFont.scaleFactor.y,
                                        kCGGradientDrawsAfterEndLocation);
        } else {
            CGPoint start = rect.origin;
            CGPoint end = CGPointMake(rect.origin.x / _currentFont.scaleFactor.x,
                                      (rect.origin.y - rect.size.height) / _currentFont.scaleFactor.y);
            CGContextDrawLinearGradient(context, self.gradient, start, end, 0);
        }
        
    }

    //
    // Individual Stroke
    //
    
    if (self.showIndividualGlyphStroke) {
        useStrokeWidth = self.strokeWidth;
        useStrokeColor = self.strokeColor.CGColor;
        if (useStrokeWidth == 0.0f) useStrokeColor = NULL;
        if (useStrokeWidth && useStrokeColor) {
            CGContextSetLineWidth(context, useStrokeWidth);
            CGContextSetStrokeColorWithColor(context, useStrokeColor);
            CGContextSetFillColorWithColor(context, NULL);
            CGContextSetTextDrawingMode(context, kCGTextStroke);
            // CTFontDrawGlyphs(_currentFont.ctFont, glyphs, points, length, context);
            [self drawGlyphs:glyphs
                 withContext:context
                    atPoints:points
                    andSizes:sizes
               withRotations:rotations
                   andLength:length];
        }
    }

    // Restore Context
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Text layout methods

- (void)layoutLabelInRect:(CGRect)rect {
	debugLog(@"Attempting to layout label text: %@ (%@)", self.text, _currentFont.fontName);
    
	// Bail if there's nothing to layout
    if (_points != NULL || _sizes != NULL || _rotations != NULL) return;
	if (self.text == nil || self.text.length == 0) return;
    if (_currentFont == nil) return;

    // Make space for points and sizes
    _points = (CGPoint *)malloc(sizeof(CGPoint) * self.text.length);
    _sizes = (CGSize *)malloc(sizeof(CGSize) * self.text.length);

    // Make space for rotations and set first value with NO ROTATION (for entire string)
    _rotations = (CGFloat *)malloc(sizeof(CGFloat) * self.text.length);
    if (self.text.length > 0) _rotations[0] = DHSGLYPH_NO_ROTATION;
    
    // Layout with typesetter
    self.typesetter.shouldCache = _shouldCache;
    self.typesetter.text = self.text;
    self.typesetter.font = _currentFont;
    self.typesetter.glyphs = _glyphs;
    self.typesetter.points = _points;
    self.typesetter.sizes = _sizes;
    self.typesetter.rotations = _rotations;
    self.typesetter.layoutInfo = self.layoutInfo;
    [self.typesetter layoutInRect:rect];
}


#pragma mark -
#pragma mark Caching methods

- (NSUInteger)hash {
    // Subclasses must overload this if new fields are added
    
    return super.hash ^
    [[NSValue valueWithCGSize:self.bounds.size] hash] ^
    [NSStringFromClass(self.class) hash] ^
    // self.text.hash ^         // should be handled by super.hash
    // self.textColor.hash ^    // should be handled by super.hash
    _currentFont.hash ^
    _typesetter.class.hash ^
    _typesetter.layoutInfo.hash ^
    self.strokeColor.hash ^
    [@(self.strokeWidth) hash] ^
    self.shadowColor.hash ^
    self.strokeHasShadow ^
    [@(self.shadowBlur) hash] ^
    [[NSValue valueWithCGSize:self.shadowOffset] hash] ^
    self.glowColor.hash ^
    [@(self.glowBlur) hash] ^
    (_gradient ? 1 : 0) ^
    [@(self.radialGradient) hash] ^
    self.showIndividualGlyphStroke ^
    self.showIndividualGlyphGlow ^
    self.glyphRenderOrder;
}

- (NSString *)imageCacheHash {
    if (_shouldCache == NO) return nil;
    
    return [NSString stringWithFormat:@"%lX", (unsigned long)[self hash]];
}

- (UIImage *)cachedImage {
    if (_shouldCache == NO) return nil;
    
    return [[DHSGlyphCache cache] imageForHash:[self imageCacheHash]];
}

- (void)setCachedImage:(UIImage *)image {
    if (_shouldCache == NO) return;
    
    [[DHSGlyphCache cache] setImage:image forHash:[self imageCacheHash]];
}


#pragma mark -
#pragma mark View drawing methods

- (void)processTextForDrawingWithContext:(CGContextRef)context
                                  inRect:(CGRect)rect {
	// Bail if there's nothing to draw
	if (self.text == nil || self.text.length == 0) return;
    if (_currentFont == nil) return;

    // Setup for processing
    NSInteger length = self.text.length;
    NSInteger *indexes = (NSInteger *)malloc(length * sizeof(NSInteger));
    CGGlyph *glyphs = (CGGlyph *)malloc(length * sizeof(CGGlyph));
    CGPoint *points = (CGPoint *)malloc(length * sizeof(CGPoint));
    CGSize *sizes = (CGSize *)malloc(length * sizeof(CGSize));
    CGFloat *rotations = (CGFloat *)malloc(length * sizeof(CGFloat));
    
    // Setup
    [self prerenderCalculate];
    
    if (_points == NULL) {
        // Layout
        [self layoutLabelInRect:self.bounds];
    }
    
    // Modify render order of glyphs, points and rotations
    [self processRenderOrder:self.glyphRenderOrder
               forNewIndexes:indexes
                  withLength:length];
    [self reorderRenderValuesForIndexes:indexes
                              forGlyphs:glyphs
                               atPoints:points
                               andSizes:sizes
                          withRotations:rotations
                              andLength:length];
    
    // Render
	[self drawLabelWithContext:context
                        inRect:self.bounds
                     forGlyphs:glyphs
                      atPoints:points
                      andSizes:sizes
                 withRotations:rotations
                     andLength:length];

    // Clean up
    free(rotations);
    free(sizes);
    free(points);
    free(glyphs);
    free(indexes);
}

- (UIImage *)getImage {
	// Check the cache
	UIImage *image = [self cachedImage];
	if (image) return image;
	
	// Not in cache
	// Get an image with the contents of the view
    if ([self respondsToSelector:@selector(setContentScaleFactor:)]) { // HighRes
        UIGraphicsBeginImageContextWithOptions (self.bounds.size, false, 0);
    } else {
        UIGraphicsBeginImageContext(self.bounds.size);
    }
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    [self processTextForDrawingWithContext:context inRect:self.bounds];
	
	image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	// Add it to the cache if there's text (or not)
	// if (self.text != nil || self.text.length > 0)
    [self setCachedImage:image];
	
	return image;
}

- (void)drawRect:(CGRect)rect {
	// Don't call super
	// [super drawRect:rect];
	
    if (_shouldCache) {
        // Get the image
        UIImage *image = [self getImage];

        // Draw the view contents
        // CGContextDrawImage(context, rect, image.CGImage);
        [image drawInRect:rect];
    } else {
     	// Get the context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Just draw the image
        [self processTextForDrawingWithContext:context inRect:self.bounds];
    }
}


#pragma mark -
#pragma mark Memory management methods

- (void)dealloc {
	debugLog(@"TTFGlyphView - dealloc");
	
	CGGradientRelease(_gradient);
    if (_glyphs) free(_glyphs);
    if (_points) free(_points);
    if (_sizes) free(_sizes);
    if (_rotations) free(_rotations);
}

@end
