//
//  DHSGlyphFont.m
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

#import "DHSGlyphFont.h"
#import "DHSGlyphSizeCache.h"

@implementation DHSGlyphFont

#define DHSGLYPH_FONT_GLYPH_EXPANSION_MULTIPLIER    1.0f


#pragma mark -
#pragma mark Initialization methods

- (id)initWithFontName:(NSString *)fontName andSize:(CGFloat)fontSize {
    self = [super init];
    if (self) {
        _shouldCache = YES;
        _fontName = fontName;
        _fontSize = fontSize;
        _scaleFactor = CGPointMake(1.0, 1.0);
        _descenderRatio = MAXFLOAT;
        _glyphExpansionMultiplier = DHSGLYPH_FONT_GLYPH_EXPANSION_MULTIPLIER;
        
        [self processFontInfo];
    }
    
    return self;
}


#pragma mark -
#pragma mark Object methods

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Size: %f, Scale: (%f, %f), DescRatio: %f, GlyphSpaceMult: %f",
            _fontName, _fontSize, _scaleFactor.x, _scaleFactor.y, _descenderRatio, _glyphExpansionMultiplier];
}

- (void)processFontInfo {
    if (_cgFont) { CGFontRelease(_cgFont), _cgFont = NULL; }
    if (_ctFont) { CFRelease(_ctFont), _ctFont = NULL; }
    
    if (_fontName == nil || _fontSize == 0.0f) return;
    
    // Get the path to the custom font and create a data provider
	NSString *fontPath = [[NSBundle mainBundle] pathForResource:_fontName ofType:nil];
    
	if (fontPath) {
		debugLog(@"Using font at path: %@", fontPath);
        
		// Create the font with the data provider, then release the data provider
		CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
		_cgFont = CGFontCreateWithDataProvider(fontDataProvider);
		CGDataProviderRelease(fontDataProvider);

        // Core Text
        if (_cgFont) _ctFont = CTFontCreateWithGraphicsFont(_cgFont, _fontSize, NULL, 0);
    } else {
        // Core Graphics
        _cgFont = CGFontCreateWithFontName((__bridge CFStringRef)(_fontName));
        
        // Core Text
        if (_cgFont) _ctFont = CTFontCreateWithGraphicsFont(_cgFont, _fontSize, NULL, 0);
    }

}

- (void)setFontName:(NSString *)fontName {
    if (_fontName == fontName || [_fontName isEqualToString:fontName] || fontName == nil) return;
    _fontName = fontName;
    
    [self processFontInfo];
}

- (void)setFontSize:(CGFloat)fontSize {
    if (_fontSize == fontSize || fontSize < 0.0f) return;
    _fontSize = fontSize;
    
    [self processFontInfo];
}

- (void)setDescenderRatio:(CGFloat)descenderRatio {
    if (_descenderRatio == descenderRatio || descenderRatio < 0.0f) return;
    _descenderRatio = descenderRatio;
}

- (void)setGlyphExpansionMultiplier:(CGFloat)glyphExpansionMultiplier {
    if (_glyphExpansionMultiplier == glyphExpansionMultiplier || glyphExpansionMultiplier < 0.0f) return;
    _glyphExpansionMultiplier = glyphExpansionMultiplier;
}


#pragma mark -
#pragma mark Caching methods

- (NSString *)hashForText:(NSString *)text {
    if (_shouldCache == NO) return nil;
    
    return [NSString stringWithFormat:@"%lX",
            (unsigned long)text.hash ^
            (unsigned long)self.hash ^
            (unsigned long)[[NSValue valueWithCGSize:CGSizeZero] hash] ^
            (unsigned long)[@1.0f hash]
            ];
}

- (CGSize)sizeForHash:(NSString *)hash {
    if (_shouldCache == NO) return CGSizeZero;

    return [[DHSGlyphSizeCache cache] sizeForHash:hash];
}

- (void)setSize:(CGSize)size forHash:(NSString *)hash {
    if (_shouldCache == NO) return;
    
    [[DHSGlyphSizeCache cache] setSize:size forHash:hash];
}


#pragma mark -
#pragma mark Size methods

- (CGFloat)spaceRatioForText:(NSString *)text {
	CGFloat retval = 0.0f;
	
	// Instant fail
	if (text == nil || text.length == 0) return 0.0f;
    
	// Loop through the entire length of the text
    
	for (int i = 0; i < text.length; ++i) {
		// count each space
        UniChar textChar = [text characterAtIndex:i];
        if (textChar == L' ') {
            retval += 1.0f;
        } else if (textChar == L'\n') {
            retval = (CGFloat)text.length;
        } else if (textChar == L'\t') {
            retval += 1.0f;
        }
	}
    
    return MIN(retval / (CGFloat)text.length, 1.0f);
}

- (CGSize)sizeForUnichar:(unichar)letter {
    CGGlyph glyph = [self getGlyphForUnichar:letter];
    CGRect rect;
    CTFontGetOpticalBoundsForGlyphs(_ctFont, &glyph, &rect, 1, 0);
    
    return CGSizeMake(rect.size.width * _glyphExpansionMultiplier * _scaleFactor.x, rect.size.height * _scaleFactor.y);
}

- (CGSize)spaceSize {
	return [self sizeForUnichar:[@" " characterAtIndex:0]];
}

- (CGSize)sizeForText:(NSString *)text {
	// Instant fail
	if (text == nil || text.length == 0) return CGSizeZero;
	if (_ctFont == NULL) return CGSizeZero;

    // Cache
    NSString *hash = [self hashForText:text];
    CGSize retval = [self sizeForHash:hash];
    
    if (CGSizeEqualToSize(retval, CGSizeZero) == NO) return retval;
    
	// Get the glyphs
    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * text.length);
    BOOL checkval = [self getGlyphs:glyphs forText:text];
    if (checkval == NO) {
        free(glyphs);
        return CGSizeZero;
    }
    
	//
	// Get the size
	//
	   
    // Get offsets for individual glyphs
    CGRect *rects = (CGRect *)malloc(sizeof(CGRect) * text.length); // rects[length];
    CGPoint *points = (CGPoint *)malloc(sizeof(CGPoint) * text.length); // points[length];
    
    // CGRect fullBoundingRect = CTFontGetBoundingRectsForGlyphs(useFont, kCTFontHorizontalOrientation, textToPrint, rects, length);
    CGRect fullBoundingRect = CTFontGetOpticalBoundsForGlyphs(_ctFont, glyphs, rects, text.length, 0);
    debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    
    CGFloat xOffset = 0.0f;
    for (NSInteger i = 0; i < text.length; ++i) {
        points[i] = CGPointMake(xOffset, -rects[i].origin.y);
        debugLog(@"Point %@", [NSValue valueWithCGPoint:points[i]]);
        xOffset += (_glyphExpansionMultiplier * _scaleFactor.x * rects[i].size.width);
    }
    // Adjust width for last character
    xOffset -= (rects[text.length - 1].size.width - (_glyphExpansionMultiplier * _scaleFactor.x * rects[text.length - 1].size.width));
    fullBoundingRect = CGRectMake(fullBoundingRect.origin.x, fullBoundingRect.origin.y,
                                  xOffset, fullBoundingRect.size.height * _scaleFactor.y);
    debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    free(rects);
    free(points);
    free(glyphs);
    
	// See how far in the text will fall
    CGFloat textEnd = fullBoundingRect.origin.x + fullBoundingRect.size.width;
	debugLog(@"text size = %g, %g", textEnd, _fontSize * _scaleFactor.y);
	debugLog(@"text = %@ (%lu)", self, (unsigned long)text.length);
	retval = CGSizeMake(textEnd, _fontSize * _scaleFactor.y);
	
    // Cache
    [self setSize:retval forHash:hash];
    
	return retval;
}


#pragma mark -
#pragma mark More Object methods

- (BOOL)getGlyphs:(CGGlyph *)glyphs forText:(NSString *)text {
    if (_ctFont == NULL) return NO;
    if (text.length == 0) return YES;
    
    // There must be enough space already allocated in the glyphs buffer
    UniChar *unichars = (UniChar *)malloc(sizeof(UniChar) * text.length);
    
    // Loop through the entire length of the text
	for (int i = 0; i < text.length; ++i) {
		// Store each letter in a unichar
		debugLog(@"%c", [text characterAtIndex:i]);
		*(unichars + i) = [text characterAtIndex:i];
	}
    
    BOOL retval = CTFontGetGlyphsForCharacters(_ctFont, unichars, glyphs, text.length);
    
    free(unichars);
    
    return retval;
}

- (CGGlyph)getGlyphForUnichar:(unichar)letter {
    if (_ctFont == NULL || letter == 0) return 0;
    
    CGGlyph glyph;
    CTFontGetGlyphsForCharacters(_ctFont, &letter, &glyph, 1);
    
    return glyph;
}

- (BOOL)canRenderText:(NSString *)text {
    if (_ctFont == NULL) return NO;
    if (text.length == 0) return YES;
    
    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph) * text.length);
    BOOL retval = [self getGlyphs:glyphs forText:text];
    free(glyphs);
    
    return retval;
}


#pragma mark -
#pragma mark NSObject methods

- (NSUInteger)hash {
    return
    [_fontName hash] ^
    [@(_fontSize) hash] ^
    [@(_scaleFactor.x + _scaleFactor.y * 2000.0f) hash] ^
    [@(_descenderRatio) hash] ^
    [@(_glyphExpansionMultiplier) hash];
}

- (BOOL)isEqualToDHSGlyphFont:(DHSGlyphFont *)font {
    if (!font) return NO;
    if ([_fontName isEqualToString:font.fontName] == NO) return NO;
    if (_fontSize != font.fontSize) return NO;
    if (CGPointEqualToPoint(_scaleFactor, font.scaleFactor) == NO) return NO;
    if (_descenderRatio != font.descenderRatio) return NO;
    if (_glyphExpansionMultiplier != font.glyphExpansionMultiplier) return NO;
    
    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:[DHSGlyphFont class]]) return NO;

    return [self isEqualToDHSGlyphFont:(DHSGlyphFont *)object];
}


#pragma mark -
#pragma mark Memory Management methods

- (void)dealloc {
    CGFontRelease(_cgFont);
    CFRelease(_ctFont);
}

@end
