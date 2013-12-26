//
//  DHSGlyphButtonLine.h
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

#import "DHSGlyphButtonBase.h"
#import "DHSGlyphLabelLine.h"

@interface DHSGlyphButtonLine : DHSGlyphButtonBase

#pragma mark -
#pragma mark Label Line Rendering Parameter methods

//
// Label Line Rendering Parameter methods
//

/**
 * Set the type of multi-line layout used, based on \b DHSGlyphLabelBaseLineLayoutStyle, to lay out each line
 *          of text stored in the labels for all button states
 *
 * @param lineLayoutStyle the style of layout
 */
- (void)setLineLayoutStyle:(DHSGlyphTypesetterLineLayoutStyle)lineLayoutStyle;

/**
 * Set the type of multi-line layout used, based on \b DHSGlyphLabelBaseLineLayoutStyle, to lay out each line
 *          of text stored in the label for only one button state
 *
 * @param lineLayoutStyle the style of layout
 * @param state The \b UIControlState that will be affected
 */
- (void)setLineLayoutStyle:(DHSGlyphTypesetterLineLayoutStyle)lineLayoutStyle forState:(UIControlState)state;

/**
 * Set the ratio with respect to the default line spacing, based on the \b lineLayoutStyle, if appropriate,
 *          to lay out each line of text stored in the labels for all button states
 *
 * @param lineLayoutStyleMultiplier the multiplier use to affect the line spacing
 */
- (void)setLineLayoutStyleMultiplier:(CGFloat)lineLayoutStyleMultiplier;

/**
 * Set the ratio with respect to the default line spacing, based on the \b lineLayoutStyle, if appropriate,
 *          to lay out each line of text stored in the label for only one button state
 *
 * @param lineLayoutStyleMultiplier the multiplier use to affect the line spacing
 * @param state The \b UIControlState that will be affected
 */
- (void)setLineLayoutStyleMultiplier:(CGFloat)lineLayoutStyleMultiplier forState:(UIControlState)state;

@end
