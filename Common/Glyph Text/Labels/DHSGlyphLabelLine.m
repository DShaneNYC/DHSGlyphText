//
//  DHSGlyphLabelLine.m
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

#import "DHSGlyphLabel+Private.h"
#import "DHSGlyphLabelLine.h"
#import "DHSGlyphTypesetter+Private.h"
#import "DHSGlyphTypesetterLine.h"

@implementation DHSGlyphLabelLine

#pragma mark -
#pragma mark Subclassing methods

- (void)setDefaults {
  [super setDefaults];

  NSDictionary *layoutInfo = [DHSGlyphTypesetterLine defaultLayoutInfo];

  self.lineLayoutStyle =
      [layoutInfo[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle)] intValue];
  self.lineLayoutStyleMultiplier = [layoutInfo[
      @(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier)] floatValue];

  self.typesetter = [DHSGlyphTypesetterLine new];
}

- (NSDictionary *)layoutInfo {
  // A subclass must overwrite this method to support the typesetters it uses
  // This method will be called every time just before layout
  if (self.typesetter == nil) return [NSDictionary dictionary];

  NSMutableDictionary *info =
      [NSMutableDictionary dictionaryWithDictionary:self.typesetter.layoutInfo];

  // Must be typesetter specific
  if ([self.typesetter isKindOfClass:[DHSGlyphTypesetterLine class]]) {
    [info addEntriesFromDictionary:[super layoutInfo]];

    info[@(DHSGlyphTypesetterLineLayoutInfoMaxNumberOfLines)] =
        @(self.numberOfLines);
    info[@(DHSGlyphTypesetterLineLayoutInfoTextAlignment)] =
        @(self.textAlignment);
    info[@(DHSGlyphTypesetterLineLayoutInfoShadowOffset)] =
        [NSValue valueWithCGSize:self.shadowOffset];
    info[@(DHSGlyphTypesetterLineLayoutInfoStrokeWidth)] = @(self.strokeWidth);
    info[@(DHSGlyphTypesetterLineLayoutInfoShiftsToShadowOffset)] =
        @(self.shiftsToShadowOffset);
    info[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyle)] =
        @(self.lineLayoutStyle);
    info[@(DHSGlyphTypesetterLineLayoutInfoLineLayoutStyleMultiplier)] =
        @(self.lineLayoutStyleMultiplier);
  }

  return [NSDictionary dictionaryWithDictionary:info];
}

#pragma mark -
#pragma mark Object methods

- (void)setShadowOffset:(CGSize)shadowOffset {
  if (CGSizeEqualToSize(super.shadowOffset, shadowOffset)) return;
  [super setShadowOffset:shadowOffset];

  [self resetPoints];
}

- (void)setLineLayoutStyle:(DHSGlyphTypesetterLineLayoutStyle)lineLayoutStyle {
  if (_lineLayoutStyle == lineLayoutStyle) return;
  _lineLayoutStyle = lineLayoutStyle;

  [self resetPoints];
}

- (void)setLineLayoutStyleMultiplier:(CGFloat)lineLayoutStyleMultiplier {
  if (_lineLayoutStyleMultiplier == lineLayoutStyleMultiplier) return;
  _lineLayoutStyleMultiplier = lineLayoutStyleMultiplier;

  [self resetPoints];
}

@end
