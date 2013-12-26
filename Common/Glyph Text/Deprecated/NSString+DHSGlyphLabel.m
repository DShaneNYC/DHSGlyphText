//
//  NSString+DHSGlyphLabel.m
//  Treasure
//
//  Created by David Shane on 9/27/10.
//  Copyright 2010 David H. Shane. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSString+DHSGlyphLabel.h"
#import "DHSGlyphSizeCache.h"
#import "GlyphDrawing.h"

#define DHSGLYPH_STRING_LINE_MULTIPLIER     1.0f
#define DHSGLYPH_STRING_LINE_DELIMITER      @"<<|||||>>"

@implementation NSString (DHSGlyphLabel)

- (NSString *)DHSGlyphMD5:(NSString *)source {
    if (source == nil) return @"0";
    
    // MD5
    const char *cStr = [source UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)hashWith:(NSString *)fontName
               andSize:(CGFloat)fontSize
     constrainedToSize:(CGSize)size
andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier {
	NSString *preHash =
    [NSString stringWithFormat:@"%@%@%g%g%g%g%g",
     self,
     fontName,
     fontSize,
     size.width,
     size.height,
     lineMultiplier,
     glyphMultiplier
     ];
    
    // MD5
    return [self DHSGlyphMD5:preHash];
}

- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
        andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
           andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier {
	// Instant fail
	if (self == nil || self.length == 0) return CGSizeZero;
	if (fontName == nil || fontSize <= 0.0) return CGSizeZero;
    if (lineMultiplier <= 0.0f) lineMultiplier = DHSGLYPH_STRING_LINE_MULTIPLIER;
    
    // Cache
    NSString *hash = [self hashWith:fontName andSize:fontSize constrainedToSize:CGSizeZero andLineSpaceModeMultiplier:lineMultiplier andGlyphSpaceMultiplier:glyphMultiplier];
    CGSize retval = [[DHSGlyphSizeCache cache] sizeForHash:hash];
    
    if (CGSizeEqualToSize(retval, CGSizeZero) == NO) return retval;
    
    // No Cache Hit
	CGFontRef customFont = NULL;

	//
    // Get the font
    //
    
	NSString *fontPath = [[NSBundle mainBundle] pathForResource:fontName ofType:nil];
	if (fontPath) {
		debugLog(@"Rendering font at path: %@", fontPath);
		CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
		
		// Create the font with the data provider, then release the data provider
		customFont = CGFontCreateWithDataProvider(fontDataProvider);
		CGDataProviderRelease(fontDataProvider);
	} else {
		// Fail
		return CGSizeZero;
	}

	// Get the glyphs
	UniChar unichars[self.length];
	CGGlyph textToPrint[self.length];
	
	// Loop through the entire length of the text
	for (int i = 0; i < self.length; ++i) {
		// Store each letter in a unichar
		debugLog(@"%c", [self characterAtIndex:i]);
		unichars[i] = [self characterAtIndex:i];
	}
    CTFontRef useFont = CTFontCreateWithGraphicsFont(customFont, fontSize, NULL, 0);
    CTFontGetGlyphsForCharacters(useFont, unichars, textToPrint, self.length);

	//
	// Get the size
	//
	
	UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// The text is upside down so change it
	CGAffineTransform textTransform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
	CGContextSetTextMatrix(context, textTransform);

	// Don't want to see the text while measuring
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	   
    // Get offsets for individual glyphs
    CGRect *rects = (CGRect *)malloc(sizeof(CGRect) * self.length); // rects[length];
    CGPoint *points = (CGPoint *)malloc(sizeof(CGPoint) * self.length); // points[length];
    
    // CGRect fullBoundingRect = CTFontGetBoundingRectsForGlyphs(useFont, kCTFontHorizontalOrientation, textToPrint, rects, length);
    CGRect fullBoundingRect = CTFontGetOpticalBoundsForGlyphs(useFont,textToPrint, rects, self.length, 0);
    debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    
    CGFloat xOffset = 0.0f;
    for (NSInteger i = 0; i < self.length; ++i) {
        points[i] = CGPointMake(xOffset, -rects[i].origin.y);
        debugLog(@"Point %@", [NSValue valueWithCGPoint:points[i]]);
        xOffset += (glyphMultiplier * rects[i].size.width);
    }
    xOffset += (rects[self.length - 1].size.width - (glyphMultiplier * rects[self.length - 1].size.width)); // Adjust width for last character
    fullBoundingRect = CGRectMake(fullBoundingRect.origin.x, fullBoundingRect.origin.y, xOffset, fullBoundingRect.size.height);
    debugLog(@"Full Rect %@", [NSValue valueWithCGRect:fullBoundingRect]);
    CFRelease(useFont);
    free(rects);
    free(points);

	// See how far in the text will fall
    CGFloat textEnd = fullBoundingRect.origin.x + fullBoundingRect.size.width;
	debugLog(@"text size = %g, %g", textEnd, multiplier * fontSize);
	debugLog(@"text = %@ (%d)", self, self.length);
    CGFloat numLines = 1.0f;
    CGFloat useHeight = numLines == 1 ? fontSize : (numLines - 1) * (lineMultiplier * fontSize) + fontSize;
	retval = CGSizeMake(textEnd, useHeight);
	
	// Clean up
	// UIGraphicsPopContext();
	UIGraphicsEndImageContext();
	CGFontRelease(customFont);

    // Cache
    [[DHSGlyphSizeCache cache] setSize:retval forHash:hash];
    
	return retval;
}

- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize {
    return [self DHSGlyphSizeWithFontName:fontName andSize:fontSize andLineSpaceModeMultiplier:1.0f andGlyphSpaceMultiplier:1.0f];
}

- (CGSize)DHSGlyphSizeNoSpaceWithFontName:(NSString *)fontName
                                  andSize:(CGFloat)fontSize
                        constrainedToSize:(CGSize)size
               andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
                  andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier {
	// Instant fail
	if (self == nil || self.length == 0) return CGSizeZero;
	if (fontName == nil || fontSize <= 0.0) return CGSizeZero;
    if (lineMultiplier <= 0.0f) lineMultiplier = DHSGLYPH_STRING_LINE_MULTIPLIER;

    // Cache
    NSString *hash = [self hashWith:fontName andSize:fontSize constrainedToSize:size andLineSpaceModeMultiplier:lineMultiplier andGlyphSpaceMultiplier:glyphMultiplier];
    CGSize retval = [[DHSGlyphSizeCache cache] sizeForHash:hash];
    
    if (CGSizeEqualToSize(retval, CGSizeZero) == NO) return retval;

    // No Cache Hit

	//
	// Get the size with this font
	//
	
	// Make sure the text fits
	// Unlike the standard UILabel, the text will be split into as many lines as necessary to fill the rect
	// The break will be at the character level
	NSString *fontNameToUse = fontName;
	CGFloat fontSizeToUse = fontSize;
    
	// Go through each word and get its length
	CGSize spaceSize = [@" " DHSGlyphSizeWithFontName:fontNameToUse
                                              andSize:fontSizeToUse
                           andLineSpaceModeMultiplier:lineMultiplier
                              andGlyphSpaceMultiplier:glyphMultiplier];
	// CGFloat spaceWidth = spaceSize.width;
	CGFloat spaceHeight = spaceSize.height;
	NSMutableArray *charSizes = [[NSMutableArray alloc] initWithCapacity:self.length];
	for (NSInteger i = 0; i < self.length; ++i) {
        NSString *letter = [self substringWithRange:NSMakeRange(i, 1)];
		[charSizes addObject:[NSNumber numberWithFloat:[letter DHSGlyphSizeWithFontName:fontNameToUse
                                                                                andSize:fontSizeToUse
                                                             andLineSpaceModeMultiplier:lineMultiplier
                                                                andGlyphSpaceMultiplier:glyphMultiplier].width]];
	}
	
	// Make each line of characters
	NSInteger firstLetter = 0;
	NSMutableArray *firstList = [[NSMutableArray alloc] initWithCapacity:2];
	NSInteger lastLetter = 0;
	NSMutableArray *lastList = [[NSMutableArray alloc] initWithCapacity:2];
	NSInteger glyphShift = 0;
	do {
		CGFloat width = 0.0;
		NSInteger glyphCount = 0;
		
		// Make a line
		while (lastLetter < [self length]) {
			// Add the next word
			width += [[charSizes objectAtIndex:lastLetter] floatValue];
			glyphCount++;
			
			// Check if the string is too long
			if ((lastLetter > firstLetter) && (width > size.width)) {
				// If it is, remove the last character
				glyphCount--;
				break;
			}

            // Get ready for the next letter
			lastLetter++;
        }
		
		// Make the entry for the line
		// first == first index, last == last index + 1
		[firstList addObject:[NSNumber numberWithInt:glyphShift]];
		[lastList addObject:[NSNumber numberWithInt:glyphShift + glyphCount + 1]];
		glyphShift = glyphShift + glyphCount;
		firstLetter = lastLetter;
	} while (firstLetter < [self length]);
    
	// Draw each line
	NSInteger numLines = [firstList count];
	debugLog(@"Number of label lines = %d", numLines);
    
    CGFloat lineWidth = size.width;
    CGFloat lineHeight = lineMultiplier * spaceHeight;
    CGFloat useHeight = numLines == 1 ? spaceHeight : (numLines - 1) * lineHeight + spaceHeight;

    retval = CGSizeMake(lineWidth, useHeight);
    
    // Cache
    [[DHSGlyphSizeCache cache] setSize:retval forHash:hash];

    return retval;
}

- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
        andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
           andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier
                 constrainedToSize:(CGSize)size {
	// Instant fail
	if (self == nil || self.length == 0) return CGSizeZero;
	if (fontName == nil || fontSize <= 0.0) return CGSizeZero;
    if (lineMultiplier <= 0.0f) lineMultiplier = DHSGLYPH_STRING_LINE_MULTIPLIER;

    // Cache
    NSString *hash = [self hashWith:fontName andSize:fontSize constrainedToSize:size andLineSpaceModeMultiplier:lineMultiplier andGlyphSpaceMultiplier:glyphMultiplier];
    CGSize retval = [[DHSGlyphSizeCache cache] sizeForHash:hash];
    
    if (CGSizeEqualToSize(retval, CGSizeZero) == NO) return retval;

    // No Cache Hit
	NSArray *words = [[self stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@" %@ ", DHSGLYPH_STRING_LINE_DELIMITER]] componentsSeparatedByString:@" "];
	
	// Degenerate case
	if ([words count] <= 1 || [self spaceRatio] < 0.1f) {
		CGSize retSize = [self DHSGlyphSizeNoSpaceWithFontName:fontName
                                                       andSize:fontSize
                                             constrainedToSize:size
                                    andLineSpaceModeMultiplier:lineMultiplier
                                       andGlyphSpaceMultiplier:glyphMultiplier];
        return CGSizeMake(MIN(retSize.width, size.width), MIN(retSize.height, size.height));
	}
	    
	//
	// Get the size with this font
	//
	
	// Make sure the text fits
	// Unlike the standard UILabel, the text will be split into as many lines as necessary to fill the rect
	// The break will be at the word level
	NSString *fontNameToUse = fontName;
	CGFloat fontSizeToUse = fontSize;
    
	// Go through each word and get its length
	CGSize spaceSize = [@" " DHSGlyphSizeWithFontName:fontNameToUse
                                              andSize:fontSizeToUse
                           andLineSpaceModeMultiplier:lineMultiplier
                              andGlyphSpaceMultiplier:glyphMultiplier];
	CGFloat spaceWidth = spaceSize.width;
	CGFloat spaceHeight = spaceSize.height;
	NSMutableArray *wordSizes = [[NSMutableArray alloc] initWithCapacity:[words count]];
	NSInteger i = 0;
	for (NSString *word in words) {
		[wordSizes addObject:[NSNumber numberWithFloat:[[words objectAtIndex:i] DHSGlyphSizeWithFontName:fontNameToUse
                                                                                                 andSize:fontSizeToUse
                                                                              andLineSpaceModeMultiplier:lineMultiplier
                                                                                 andGlyphSpaceMultiplier:glyphMultiplier].width]];
		++i;
	}
	
	// Make each line of words
	NSInteger firstWord = 0;
	NSMutableArray *firstList = [[NSMutableArray alloc] initWithCapacity:2];
	NSInteger lastWord = 0;
	NSMutableArray *lastList = [[NSMutableArray alloc] initWithCapacity:2];
	NSInteger glyphShift = 0;
	do {
		CGFloat width = 0.0;
		NSInteger glyphCount = 0;
		
		// Make a line
		while (lastWord < [words count]) {
			// Add the next word
			width += [[wordSizes objectAtIndex:lastWord] floatValue];
			glyphCount += [[words objectAtIndex:lastWord] length];
			
            // New line
            if ([[words objectAtIndex:lastWord] isEqualToString:DHSGLYPH_STRING_LINE_DELIMITER]) {
				glyphCount -= [[words objectAtIndex:lastWord] length];
                lastWord++;
                break;
            }
            
			// Check if the string is too long
			if ((lastWord > firstWord) && (width > size.width)) {
				// If it is, remove the last word
				// width -= [[wordSizes objectAtIndex:lastWord] floatValue];
				glyphCount -= [[words objectAtIndex:lastWord] length];
				break;
			}
			
			// Get ready for the next word
			width += spaceWidth;
			++glyphCount;
			lastWord++;
		}
        // Allow for removing space at end of line
		// width -= spaceWidth;
		--glyphCount;
		
		// Make the entry for the line
		// first == first index, last == last index + 1
		[firstList addObject:[NSNumber numberWithInt:glyphShift]];
		[lastList addObject:[NSNumber numberWithInt:glyphShift + glyphCount + 1]];
		glyphShift = glyphShift + glyphCount + 1;
		firstWord = lastWord;
	} while (firstWord < [words count]);
    
	// Draw each line
	NSInteger numLines = [firstList count];
	debugLog(@"Number of label lines = %d", numLines);
    
    CGFloat lineWidth = size.width;
    CGFloat lineHeight = lineMultiplier * spaceHeight;
    CGFloat useHeight = numLines == 1 ? spaceHeight : (numLines - 1) * lineHeight + spaceHeight;
    
    retval = CGSizeMake(MIN(size.width, lineWidth), MIN(size.height, useHeight));
    
    // Cache
    [[DHSGlyphSizeCache cache] setSize:retval forHash:hash];

    return retval;
}

- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
                 constrainedToSize:(CGSize)size {
    return [self DHSGlyphSizeWithFontName:fontName
                                  andSize:fontSize
               andLineSpaceModeMultiplier:1.0f
                  andGlyphSpaceMultiplier:1.0f
                        constrainedToSize:size];
}

- (BOOL)DHSGlyphCanRenderWithFontName:(NSString *)fontName {
	BOOL retval = YES;
	CGFontRef customFont = NULL;
	
	// Instant fail
	if (self == nil || self.length == 0) return NO;
	if (fontName == nil) return NO;
    
	//
    // Get the font
    //
    
	NSString *fontPath = [[NSBundle mainBundle] pathForResource:fontName ofType:nil];
	if (fontPath) {
		debugLog(@"Rendering font at path: %@", fontPath);
		CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
		
		// Create the font with the data provider, then release the data provider
		customFont = CGFontCreateWithDataProvider(fontDataProvider);
		CGDataProviderRelease(fontDataProvider);
	} else {
		// Fail
		return NO;
	}
    
	// Get the glyphs
	UniChar unichars[self.length];
	CGGlyph textToPrint[self.length];
	
	// Loop through the entire length of the text
	for (int i = 0; i < self.length; ++i) {
		// Store each letter in a unichar
        UniChar textChar = [self characterAtIndex:i];
        if (textChar == L'\n') {
            debugLog(@"|<newline>|");
            unichars[i] = L' ';
        } else {
            debugLog(@"%c", textChar);
            unichars[i] = textChar;
        }
	}
    CTFontRef useFont = CTFontCreateWithGraphicsFont(customFont, 50.0f, NULL, 0);
    CTFontGetGlyphsForCharacters(useFont, unichars, textToPrint, self.length);
    CFRelease(useFont);
	// CMFontGetGlyphsForUnichars(customFont, unichars, textToPrint, self.length);
    
	//
	// See if all the characters are there
	//
	
    for (int i = 0; i < self.length; ++i) {
		// Fail?
		if (textToPrint[i] == 0) {
            retval = NO;
            break;
        }
    }

	CGFontRelease(customFont);
    
	return retval;
}

- (CGFloat)spaceRatio {
	CGFloat retval = 0.0f;
	
	// Instant fail
	if (self == nil || self.length == 0) return 0.0f;

	// Loop through the entire length of the text
    
	for (int i = 0; i < self.length; ++i) {
		// count each space
        UniChar textChar = [self characterAtIndex:i];
        if (textChar == L' ') {
            retval += 1.0f;
        } else if (textChar == L'\n') {
            retval = (CGFloat)self.length;
        } else if (textChar == L'\t') {
            retval += 1.0f;
        }
	}
    
    return MIN(retval / (CGFloat)self.length, 1.0f);
}


@end
