//
//  DHSGlyphTypesetterLine.m
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

#import "DHSGlyphTypesetter+Private.h"
#import "DHSGlyphTypesetterLine.h"

#define DHSGLYPHTYPESETTER_LINE_DELIMITER         @"\n"

@implementation DHSGlyphTypesetterLine

#pragma mark -
#pragma mark Class methods

+ (CGSize)sizeNoSpaceForText:(NSString *)text
                    withFont:(DHSGlyphFont *)font
               andLayoutInfo:(NSDictionary *)layoutInfo
           constrainedToSize:(CGSize)size
          makeFirstIndexList:(NSMutableArray *)firstList
           makeLastIndexList:(NSMutableArray *)lastList {
    
	debugLog(@"NoS Label Text = %@ (length = %lu)", text, (unsigned long)text.length);

    if (firstList == nil) firstList = [NSMutableArray arrayWithCapacity:5];
    if (lastList == nil) lastList = [NSMutableArray arrayWithCapacity:5];

	//
	// Layout the text with this font
	//
    
	NSMutableArray *charSizes = [[NSMutableArray alloc] initWithCapacity:text.length];
	for (NSInteger i = 0; i < text.length; ++i) {
        unichar letter = [text characterAtIndex:i];
        [charSizes addObject:@([font sizeForUnichar:letter].width)];
	}
	
	// Make each line of characters
	NSInteger firstLetter = 0;
	NSInteger lastLetter = 0;
	NSInteger lineFirstGlyph = 0;
    CGFloat maxLineWidth = 0.0f;
	do {
		CGFloat width = 0.0;
		NSInteger glyphCount = 0;
		
		// Make a line
		while (lastLetter < [text length]) {
			// Add the next word
			width += [[charSizes objectAtIndex:lastLetter] floatValue];
			glyphCount++;
			
			// Check if the string is too long
			if ((lastLetter > firstLetter) && (width > size.width)) {
				// If it is, remove the last character
                maxLineWidth = MAX(maxLineWidth, width - [[charSizes objectAtIndex:lastLetter] floatValue]);
				glyphCount--;
				break;
			}
            
            // Get ready for the next letter
			lastLetter++;
		}
		
		// Make the entry for the line
		// first == first index, last == last index + 1
		[firstList addObject:[NSNumber numberWithLong:lineFirstGlyph]];
		[lastList addObject:[NSNumber numberWithLong:lineFirstGlyph + glyphCount + 1]];
		lineFirstGlyph = lineFirstGlyph + glyphCount;
		firstLetter = lastLetter;
        if (maxLineWidth == 0.0f) maxLineWidth = width;
	} while (firstLetter < text.length);
    
	// Get minimum size
	NSInteger numLines = [firstList count];
	debugLog(@"Number of label lines = %ld", (long)numLines);
    
	CGSize spaceSize = [font spaceSize];
	CGFloat spaceHeight = spaceSize.height;
    CGFloat lineLayoutStyleMultiplier = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier)] floatValue];
    CGFloat lineHeight = lineLayoutStyleMultiplier * spaceHeight;
    CGFloat useHeight = numLines == 1 ? spaceHeight : (numLines - 1) * lineHeight + spaceHeight;
    
    return CGSizeMake(size.width, MIN(size.height, useHeight));
}

+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
        andLayoutInfo:(NSDictionary *)layoutInfo
    constrainedToSize:(CGSize)size
   makeFirstIndexList:(NSMutableArray *)firstList
    makeLastIndexList:(NSMutableArray *)lastList {
    
	debugLog(@"Label Text = %@ (length = %lu)", text, (unsigned long)text.length);
    
    if (firstList == nil) firstList = [NSMutableArray arrayWithCapacity:5];
    if (lastList == nil) lastList = [NSMutableArray arrayWithCapacity:5];

	// Go through each word and get its length
	NSArray *words = [[text stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@" %@ ", DHSGLYPHTYPESETTER_LINE_DELIMITER]] componentsSeparatedByString:@" "];
    
	// Degenerate case
	if ([words count] <= 1 || [[self class] spaceRatioForText:text] < 0.1f) {
        return [[self class] sizeNoSpaceForText:text
                                       withFont:font
                                  andLayoutInfo:layoutInfo
                              constrainedToSize:size
                             makeFirstIndexList:firstList
                              makeLastIndexList:lastList];
	}
	
	// Make sure the text fits
    // Get the size of a space character in the font
    CGSize spaceSize = [font spaceSize];
	CGFloat spaceWidth = spaceSize.width;
	CGFloat spaceHeight = spaceSize.height;
    
	//
	// Layout the text with this font
	//
	
	NSMutableArray *wordSizes = [[NSMutableArray alloc] initWithCapacity:[words count]];
	NSInteger i = 0;
	for (NSString *word in words) {
        [wordSizes addObject:@([font sizeForText:word].width)];
		++i;
	}
	
	// Make each line of words
	NSInteger firstWord = 0;
	NSInteger lastWord = 0;
	NSInteger lineFirstGlyph = 0;
    CGFloat maxLineWidth = 0.0;
	do {
		CGFloat width = 0.0;
		NSInteger glyphCount = 0;
		
		// Make a line
		while (lastWord < [words count]) {
			// Add the next word
			width += [[wordSizes objectAtIndex:lastWord] floatValue];
			glyphCount += [[words objectAtIndex:lastWord] length];
			
            // New line
            if ([[words objectAtIndex:lastWord] isEqualToString:DHSGLYPHTYPESETTER_LINE_DELIMITER]) {
                maxLineWidth = MAX(maxLineWidth, width - [[wordSizes objectAtIndex:lastWord] floatValue]);
				glyphCount -= [[words objectAtIndex:lastWord] length];
                lastWord++;
                break;
            }
            
			// Check if the line is too long
			if ((lastWord > firstWord) && (width > size.width)) {
				// If it is, remove the last word
                maxLineWidth = MAX(maxLineWidth, width - [[wordSizes objectAtIndex:lastWord] floatValue]);
				glyphCount -= [[words objectAtIndex:lastWord] length];
				break;
			}
			
			// Get ready for the next word by adding a space
			width += spaceWidth;
			++glyphCount;
			lastWord++;
		}
        // Allow for removing space at end of line
		--glyphCount;
		
		// Make the entry for the line
		// first == first index, last == last index + 1
		[firstList addObject:[NSNumber numberWithLong:lineFirstGlyph]];
		[lastList addObject:[NSNumber numberWithLong:lineFirstGlyph + glyphCount + 1]];
		lineFirstGlyph = lineFirstGlyph + glyphCount + 1;
		firstWord = lastWord;
        if (maxLineWidth == 0.0f) maxLineWidth = width;
	} while (firstWord < [words count]);
    
	// Get minimum size
	NSInteger numLines = [firstList count];
	debugLog(@"Number of label lines = %ld", (long)numLines);
    
    CGFloat lineLayoutStyleMultiplier = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier)] floatValue];
    CGFloat lineHeight = lineLayoutStyleMultiplier * spaceHeight;
    CGFloat useHeight = numLines == 1 ? spaceHeight : (numLines - 1) * lineHeight + spaceHeight;
    
    return CGSizeMake(size.width, MIN(size.height, useHeight));
}

+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
        andLayoutInfo:(NSDictionary *)layoutInfo
    constrainedToSize:(CGSize)size {
    
    return [self sizeForText:text
                    withFont:font
               andLayoutInfo:layoutInfo
           constrainedToSize:size
          makeFirstIndexList:nil
           makeLastIndexList:nil];
}


#pragma mark -
#pragma mark Data methods

+ (NSDictionary *)defaultLayoutInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:super.defaultLayoutInfo];
    
    [info addEntriesFromDictionary:
     @{@(DHSGlyphTypesetterLineLayoutInfoMaxNumberOfLines) : @0,
       @(DHSGlyphTypesetterLineLayoutInfoTextAlignment) : @(NSTextAlignmentLeft),
       @(DHSGlyphTypesetterLineLayoutInfoShadowOffset) : [NSValue valueWithCGSize:CGSizeZero],
       @(DHSGlyphTypesetterLineLayoutInfoStrokeWidth) : @0.0f,
       @(DHSGlyphTypesetterLineLayoutInfoShiftsToShadowOffset) : @(NO),
       @(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle) : @(DHSGlyphTypesetterLineLayoutStyleCenter),
       @(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier) : @1.0f
       }];
    
    return [NSDictionary dictionaryWithDictionary:info];
}


#pragma mark -
#pragma mark Layout methods

- (void)layoutGlyphs:(CGGlyph *)glyphs
            atPoints:(CGPoint *)points
            andSizes:(CGSize *)sizes
        andRotations:(CGFloat *)rotations
          withLength:(NSInteger)length
              inRect:(CGRect)rect {
    DHSGlyphFont *font = self.font;
	debugLog(@"Attempting to layout glyphs text: %@ (%@)", self.text, font.fontName);
    
	CGPoint myScaleFactor = font.scaleFactor;
	CGFloat myGlyphBodyRatio = font.descenderRatio;
    
    NSDictionary *layoutInfo = self.layoutInfo;
    
    // Get offsets for individual glyphs
    CGRect *rects = (CGRect *)malloc(sizeof(CGRect) * length);
    
    if (myGlyphBodyRatio == MAXFLOAT) myGlyphBodyRatio = (CTFontGetDescent(font.ctFont) / (font.fontSize * font.scaleFactor.y));
    myGlyphBodyRatio = 1.0f - myGlyphBodyRatio;
    
    // CGRect fullBoundingRect = CTFontGetBoundingRectsForGlyphs(_currentFont.ctFont, kCTFontHorizontalOrientation, glyphs, rects, length);
    CGRect fullBoundingRect = CTFontGetOpticalBoundsForGlyphs(font.ctFont, glyphs, rects, length, 0);
	// debugLog(@"Point Size = %g", font.fontSize);
	// debugLog(@"Glyph Body = %g", myGlyphBodyRatio);
    // debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    
    CGFloat xOffset = 0.0f;
    for (NSInteger i = 0; i < length; ++i) {
        points[i] = CGPointMake(xOffset, -rects[i].origin.y);
        sizes[i] = rects[i].size;
        // debugLog(@"Point %@", [NSValue valueWithCGPoint:points[i]]);
        xOffset += (font.glyphExpansionMultiplier * rects[i].size.width);
    }
    // Adjust width for last character
    xOffset += (rects[length - 1].size.width - (font.glyphExpansionMultiplier * rects[length - 1].size.width));
    fullBoundingRect = CGRectMake(fullBoundingRect.origin.x, fullBoundingRect.origin.y, xOffset, fullBoundingRect.size.height);
    // debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    free(rects);
    
	//
	// Measure the text for alignment adjustments
	//
    
    // Horizontal Adjustment
	// See how far in the text will fall
    UITextAlignment textAlignment = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoTextAlignment)] intValue];
    CGFloat strokeWidth = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoStrokeWidth)] floatValue];
    CGSize shadowOffset = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoShadowOffset)] CGSizeValue];

    CGFloat textEnd = fullBoundingRect.origin.x + fullBoundingRect.size.width;
	CGPoint adjustment = rect.origin; // CGPointMake(0.0f, 0.0f);
	if (textAlignment == NSTextAlignmentLeft) {
		adjustment.x = rect.origin.x + strokeWidth; // 0.0f;
	} else if (textAlignment == NSTextAlignmentCenter) {
		adjustment.x = (rect.origin.x + (rect.size.width / myScaleFactor.x) - textEnd) / 2.0f;
	} else if (textAlignment == NSTextAlignmentRight) {
		adjustment.x = rect.origin.x + (rect.size.width / myScaleFactor.x) - textEnd - strokeWidth;
		// Shift for drop shadow
		if (shadowOffset.width > 0.0) adjustment.x -= (shadowOffset.width);
		// Shift in case of cut off
		adjustment.x -= ceil(font.fontSize * font.scaleFactor.y * 0.025);
	}
    
	// Move text to where shadow should be if offset
	if ([layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoShiftsToShadowOffset)] boolValue]) {
		adjustment.x += shadowOffset.width;
		adjustment.y += shadowOffset.height;
	}
    
    // Adjust points
    for (NSInteger i = 0; i < length; ++i) {
        points[i] = CGPointMake(points[i].x + adjustment.x, -(adjustment.y + font.fontSize * font.scaleFactor.y * myGlyphBodyRatio));
        // debugLog(@"PointA %@", [NSValue valueWithCGPoint:points[i]]);
    }
}

- (BOOL)layoutInRect:(CGRect)rect {
    if ([super layoutInRect:rect] == NO) return NO;
    
	// Bail if there's nothing to layout
    NSString *text = self.text;
	if (text == nil || text.length == 0) return NO;
    DHSGlyphFont *font = self.font;
    if (font == nil) return NO;
    CGGlyph *glyphs = self.glyphs;
    if (glyphs == NULL) return NO;
    CGPoint *points = self.points;
    if (points == NULL) return NO;
    CGSize *sizes = self.sizes;
    if (sizes == NULL) return NO;
    NSDictionary *layoutInfo = self.layoutInfo;

    debugLog(@"Attempting to layout label text: %@ (%@)", text, font.fontName);
    
    // Get the size and fill the index lists
    NSMutableArray *firstList = [[NSMutableArray alloc] initWithCapacity:2];
	NSMutableArray *lastList = [[NSMutableArray alloc] initWithCapacity:2];
    [[self class] sizeForText:text
                     withFont:font
                andLayoutInfo:layoutInfo
            constrainedToSize:rect.size
           makeFirstIndexList:firstList
            makeLastIndexList:lastList];
    
	// Layout each line
	NSInteger numLines = [firstList count];
    NSInteger maxNumberOfLines = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoMaxNumberOfLines)] intValue];
    if (maxNumberOfLines > 0) numLines = MIN(numLines, maxNumberOfLines);
	debugLog(@"Number of label lines = %ld", (long)numLines);
    
    CGFloat lineWidth = rect.size.width;
    CGFloat lineHeight = font.fontSize * font.scaleFactor.y;
    CGFloat lineX = rect.origin.x;
    CGFloat lineY = 0.0f; // i * lineHeight
    CGFloat yOffset = 0.0f;
    CGFloat yIncrement = 0.0f;
    
    NSInteger lineLayoutStyle = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle)] intValue];
    CGFloat lineLayoutStyleMultiplier = [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier)] floatValue];
    switch (lineLayoutStyle) {
        default:
        case DHSGlyphTypesetterLineLayoutStyleCenter:
            lineHeight = lineLayoutStyleMultiplier * font.fontSize * font.scaleFactor.y;
            yOffset = (rect.size.height - (((CGFloat)numLines - 1.0f) * lineHeight + font.fontSize * font.scaleFactor.y)) / 2.0f;
            yIncrement = 0.0f;
            break;
            
        case DHSGlyphTypesetterLineLayoutStyleSpread:
            if (numLines == 1) {
                yOffset = (rect.size.height - ((CGFloat)numLines * font.fontSize * font.scaleFactor.y)) / 2.0f;
                yIncrement = 0.0f;
            } else {
                yOffset = 0.0f;
                yIncrement = ((rect.size.height - font.fontSize * font.scaleFactor.y) / ((CGFloat)numLines - 1.0f)) - lineHeight;
            }
            break;
    }
    
	debugLog(@"Text Length: %lu, Last Index: %d", (unsigned long)text.length, [[lastList lastObject] intValue]);
    debugLog(@"numPoints = %lu * %lu (%@)", sizeof(CGPoint), (unsigned long)text.length, text);
    NSInteger i = 0;
	while (i < numLines) {
		NSInteger firstGlyph = [[firstList objectAtIndex:i] intValue];
		NSInteger lastGlyph = [[lastList objectAtIndex:i] intValue];
		NSInteger length = lastGlyph - firstGlyph - 1;
		debugLog(@"Line %ld from %ld to %ld (%@)", (long)i, (long)firstGlyph, (long)lastGlyph - 1, [text substringWithRange:NSMakeRange(firstGlyph, length)]);
        
		// Make the Rect
        lineY = i * lineHeight;
		CGRect lineRect = CGRectMake(lineX, lineY + yOffset, lineWidth, font.fontSize * font.scaleFactor.y);
		
		// Layout the text
        debugLog(@"Location %p = %p + %lu", points + firstGlyph, points, firstGlyph * sizeof(CGPoint));
        [self layoutGlyphs:(glyphs + firstGlyph)
                  atPoints:(points + firstGlyph)
                  andSizes:(sizes + firstGlyph)
              andRotations:(self.rotations + firstGlyph)
                withLength:length
                    inRect:lineRect];
		
        yOffset += yIncrement;
		++i;
	}

    return YES;
}

@end
