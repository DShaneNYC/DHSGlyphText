//
//  DHSGlyphLabelRandomShift.m
//  DHS
//
//  Created by David Shane on 12/2/13. (DShaneNYC@gmail.com)
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

#import "DHSGlyphLabelBase+Private.h"
#import "DHSGlyphLabelRandomShift.h"
#import "DHSGlyphTypesetterBase+Private.h"
#import "DHSGlyphTypesetterRandomShift.h"


@implementation DHSGlyphLabelRandomShift

#pragma mark -
#pragma mark Subclassing methods

- (void)setDefaults {
    [super setDefaults];
    
    NSDictionary *layoutInfo = [DHSGlyphTypesetterRandomShift defaultLayoutInfo];
    
    self.horizontalRatioMin = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMin)] floatValue];
    self.horizontalRatioMax = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMax)] floatValue];
    self.verticalRatioMin = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMin)] floatValue];
    self.verticalRatioMax = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMax)] floatValue];
    self.rotationMin = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMin)] floatValue];
    self.rotationMax = [layoutInfo[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMax)] floatValue];
    
    self.typesetter = [DHSGlyphTypesetterRandomShift new];
}

- (NSDictionary *)layoutInfo {
    // A subclass must overwrite this method to support the typesetters it uses
    // This method will be called every time just before layout
    if (self.typesetter == nil) return [NSDictionary dictionary];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:self.typesetter.layoutInfo];
    
    // Must be typesetter specific
    if ([self.typesetter isKindOfClass:[DHSGlyphTypesetterRandomShift class]]) {
        [info addEntriesFromDictionary:[super layoutInfo]];
        
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMin)] = @(self.horizontalRatioMin);
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoHorizontalRatioMax)] = @(self.horizontalRatioMax);
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMin)] = @(self.verticalRatioMin);
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoVerticalRatioMax)] = @(self.verticalRatioMax);
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMin)] = @(self.rotationMin);
        info[@(DHSGlyphTypesetterRandomShiftLayoutInfoRotationMax)] = @(self.rotationMax);
    }
    
    return [NSDictionary dictionaryWithDictionary:info];
}


#pragma mark -
#pragma mark Object methods

- (void)setHorizontalRatioMin:(CGFloat)horizontalRatioMin {
    if (_horizontalRatioMin == horizontalRatioMin) return;
    _horizontalRatioMin = horizontalRatioMin;
    
    [self resetPoints];
}

- (void)setHorizontalRatioMax:(CGFloat)horizontalRatioMax {
    if (_horizontalRatioMax == horizontalRatioMax) return;
    _horizontalRatioMax = horizontalRatioMax;
    
    [self resetPoints];
}

- (void)setVerticalRatioMin:(CGFloat)verticalRatioMin {
    if (_verticalRatioMin == verticalRatioMin) return;
    _verticalRatioMin = verticalRatioMin;
    
    [self resetPoints];
}

- (void)setVerticalRatioMax:(CGFloat)verticalRatioMax {
    if (_verticalRatioMax == verticalRatioMax) return;
    _verticalRatioMax = verticalRatioMax;
    
    [self resetPoints];
}

- (void)setRotationMin:(CGFloat)rotationMin {
    if (_rotationMin == rotationMin) return;
    _rotationMin = rotationMin;
    
    [self resetPoints];
}

- (void)setRotationMax:(CGFloat)rotationMax {
    if (_rotationMax == rotationMax) return;
    _rotationMax = rotationMax;
    
    [self resetPoints];
}

@end
