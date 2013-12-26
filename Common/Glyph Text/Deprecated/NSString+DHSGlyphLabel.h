//
//  NSString+DHSGlyphLabel.h
//  Treasure
//
//  Created by David Shane on 9/27/10.
//  Copyright 2010 David H. Shane. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (DHSGlyphLabel)

- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
        andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
           andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier;
- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize;
- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
        andLineSpaceModeMultiplier:(CGFloat)lineMultiplier
           andGlyphSpaceMultiplier:(CGFloat)glyphMultiplier
                 constrainedToSize:(CGSize)size;
- (CGSize)DHSGlyphSizeWithFontName:(NSString *)fontName
                           andSize:(CGFloat)fontSize
                 constrainedToSize:(CGSize)size;
- (BOOL)DHSGlyphCanRenderWithFontName:(NSString *)fontName;
- (CGFloat)spaceRatio;

@end
