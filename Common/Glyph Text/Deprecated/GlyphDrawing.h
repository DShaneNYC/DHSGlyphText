//
//  GlyphDrawing.h
//
//  Created by Masashi Ono on 07/07/10.
//     http://akisute.com
//  Original file created by Jens Egeblad on 11/16/09.
//     http://mexircus.com/blog//blog4.php/2009/11/16/cgfontgetglyphsforunichars-alternatives
//     http://www.mexircus.com/codes/GlyphDrawing.mm
//  
//
//  Purpose: Reimplement CGFontGetGlyphsForUnichars(CGFontRef, unichar[], CGGlyph[], size_t)
//
//  The function that does that: 
//     size_t CMFontGetGlyphsForUnichars(CGFontRef cgFont, const UniChar buffer[], CGGlyph glyphs[], size_t numGlyphs)
//
//     (returns number of glyps put in glyphs)
//
//  Why?: We are not allowed to use it on the iPhone. Apple rejects apps with it.
//
//  Why do we need it?:
//        1. UIString drawing is not thread safe
//        2. PDF drawing doesn't embeded fonts, and is therefore impossible with UIString drawing
// 
//  Another work-around for UIString drawing: Make sure it always occurs in main-thread with e.g. performSelector
// 
//  How does it work?:
//        Fetch cmap (character map) table of font
//        Find the right segment (We only look for platform 0 and 3 and format 4 and 12)
//          Pick a platform+format for all subsequent lookups.
//          Cache selection
// 
//        For each unichar look for character in selected cmap segment (either format 4 or 12)
// 
//  How well does it work?:
//        This files contains testing code. All 65536 unichars are tested with our function
//        and Apples.  Testing generally gives perfect results for all
//        current fonts except:
//         + AppleGothic where there are about 300 character mismatches from char 55424 and up
//         + STHeitiTC-Light and STHeitiTC-Medium  which has one character mismatch
//
//  Why those anomalies?: I don't know... 
//
//  Possible improvements:
//     + cache better: 
//          We cache the fonttables and never release them. Consider release strateies
///    + Search faster: 
//          It may be possible to do binary searching in the tables if they are sorted
//          which I don't know if they are
//     + Add more formats: Only format 4 and 12 supported. That handles all present iPhone fonts.
//     + Fix current minor issues.
//     
// 
//  This code was mainly based on:
//       http://github.com/jamesjhu/CMGlyphDrawing
// 
//  Other reading:
//      Apple document on truetype format:  http://developer.apple.com/textfonts/TTRefMan/RM06/Chap6cmap.html
//      Another code: http://code.google.com/p/cocos2d-iphone/source/browse/trunk/external/FontLabel/FontLabelStringDrawing.m?spec=svn1358&r=1358


#import <Foundation/Foundation.h>

UIKIT_EXTERN void setupGlyphsLock(void);
UIKIT_EXTERN void teardownGlyphsLock(void);

UIKIT_EXTERN size_t CMFontGetGlyphsForUnichars(CGFontRef cgFont, const UniChar buffer[], CGGlyph glyphs[], size_t numGlyphs);

// DHS
UIKIT_EXTERN CGFloat CMFontGetDescenderRatio(CGFontRef cgFont);

// Usage: just import "GlyphDrawing.h" in GlyphDrawing.mm instead of <Foundation/Foundation.h>
