//
//  DHSGlyphTypesetter.m
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

#import <CoreText/CoreText.h>

#import "DHSGlyphSizeCache.h"
#import "DHSGlyphTypesetter+Private.h"
#import "DHSGlyphFont.h"

@interface DHSGlyphTypesetter ()

// Properties
@property (nonatomic, readwrite)    NSString *text;
@property (nonatomic, readwrite)    DHSGlyphFont *font;
@property (nonatomic, readwrite)    CGGlyph *glyphs;
@property (nonatomic, readwrite)    CGPoint *points;
@property (nonatomic, readwrite)    CGSize *sizes;
@property (nonatomic, readwrite)    CGFloat *rotations;
@property (nonatomic, readwrite)    NSDictionary *layoutInfo;

@end

@implementation DHSGlyphTypesetter

#pragma mark -
#pragma mark Class methods

+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
        andLayoutInfo:(NSDictionary *)layoutInfo
    constrainedToSize:(CGSize)size {
    
    // Subclasses must overwrite this
    // Subclasses should not cache class method results
    return CGSizeZero;
}

+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
    constrainedToSize:(CGSize)size {
    
    return [self sizeForText:text
                    withFont:font
               andLayoutInfo:[self defaultLayoutInfo]
           constrainedToSize:size];
}

+ (CGFloat)spaceRatioForText:(NSString *)text {
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


#pragma mark -
#pragma mark Initialization methods

- (void)setDefaults {
    // Subclasses may overwrite this AND must call super
    
    _text = nil;
    _font = nil;
    _glyphs = NULL;
    _points = NULL;
    _layoutInfo = [[self class] defaultLayoutInfo];
}

- (id)init {
    if (self = [super init]) {
		[self setDefaults];
    }
    return self;
}


#pragma mark -
#pragma mark Data methods

+ (NSDictionary *)defaultLayoutInfo {
    // Subclasses should not need to overwrite this

    return [NSDictionary dictionary];
}

- (void)setLayoutInfo:(NSDictionary *)layoutInfo {
    // Subclasses should not need to overwrite this

    if (_layoutInfo == layoutInfo) return;
    
    NSMutableDictionary *info = [_layoutInfo count] ?
    [NSMutableDictionary dictionaryWithDictionary:_layoutInfo] :
    [NSMutableDictionary dictionaryWithDictionary:[[self class] defaultLayoutInfo]];
    
    if (layoutInfo) [info addEntriesFromDictionary:layoutInfo];
    
    _layoutInfo = [NSDictionary dictionaryWithDictionary:info];
}

- (void)setLayoutInfoValue:(id)infoValue forKey:(DHSGlyphTypesetterLayoutInfo)key {
    // Subclasses should not need to overwrite this

    NSMutableDictionary *info = [_layoutInfo count] ?
    [NSMutableDictionary dictionaryWithDictionary:_layoutInfo] :
    [NSMutableDictionary dictionaryWithDictionary:[[self class] defaultLayoutInfo]];
    
    info[@(key)] = infoValue;
    
    _layoutInfo = [NSDictionary dictionaryWithDictionary:info];
}


#pragma mark -
#pragma mark Layout methods

- (CGFloat)spaceRatio {
    return [[self class] spaceRatioForText:self.text];
}

- (void)layoutGlyphs:(CGGlyph *)glyphs
            atPoints:(CGPoint *)points
            andSizes:(CGSize *)sizes
        andRotations:(CGFloat *)rotations
          withLength:(NSInteger)length
              inRect:(CGRect)rect {
    // Subclasses must overwrite this without calling super
    // Subclasses must also be able to handle rotations == NULL correctly
    
    // No glyph rotation in default layout
    if (rotations && length > 0) rotations[0] = DHSGLYPH_NO_ROTATION;
        
    // Full (or partial) layout
    CGRect *rects = (CGRect *)malloc(sizeof(CGRect) * length);
    CTFontGetOpticalBoundsForGlyphs(_font.ctFont, glyphs, rects, length, 0);

    // Igores most font info
    CGFloat xOffset = rect.origin.x;
    for (NSInteger i = 0; i < length; ++i) {
        points[i] = CGPointMake(xOffset, rect.origin.y - rects[i].origin.y);
        sizes[i] = rects[i].size;
        // debugLog(@"Point %@", [NSValue valueWithCGPoint:points[i]]);
        // Replaces CGContextSetCharacterSpacing
        xOffset += (_font.glyphExpansionMultiplier * rects[i].size.width);
    }
    free (rects);
}

- (CGSize)sizeOfLayoutConstrainedToSize:(CGSize)size {
    // Subclasses should not need to overwrite this
    
    if (self.text.length == 0) return CGSizeZero;
    if (self.font == nil) return CGSizeZero;
    
    // Cache
    NSString *hash = [self hashForText:self.text
                              withFont:self.font
                         andLayoutInfo:self.layoutInfo
                     constrainedToSize:size];
    CGSize retval = [self sizeForHash:hash];
    
    if (CGSizeEqualToSize(retval, CGSizeZero) == NO) return retval;
    
    retval = [[self class] sizeForText:self.text
                              withFont:self.font
                         andLayoutInfo:self.layoutInfo
                     constrainedToSize:size];
    
    // Cache
    [self setSize:retval forHash:hash];
    
    return retval;
}

- (BOOL)layoutInRect:(CGRect)rect {
    // Subclasses must overwrite this without calling super
    
    // simple line layout with core text
    [self layoutGlyphs:_glyphs
              atPoints:_points
              andSizes:_sizes
          andRotations:_rotations
            withLength:_text.length
                inRect:rect];
    
    return YES;
}


#pragma mark -
#pragma mark Caching methods

- (NSString *)hashForText:(NSString *)text
                 withFont:(DHSGlyphFont *)font
            andLayoutInfo:(NSDictionary *)layoutInfo
        constrainedToSize:(CGSize)size {
    if (self.shouldCache == NO) return nil;
    
    return [NSString stringWithFormat:@"%lX",
            (unsigned long)text.hash ^
            (unsigned long)font.hash ^
            (unsigned long)[[NSValue valueWithCGSize:size] hash] ^
            (unsigned long)layoutInfo.hash
            ];
}

- (CGSize)sizeForHash:(NSString *)hash {
    if (self.shouldCache == NO) return CGSizeZero;
    
    return [[DHSGlyphSizeCache cache] sizeForHash:hash];
}

- (void)setSize:(CGSize)size forHash:(NSString *)hash {
    if (self.shouldCache == NO) return;
    
    [[DHSGlyphSizeCache cache] setSize:size forHash:hash];
}

@end
