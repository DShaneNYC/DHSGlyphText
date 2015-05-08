//
//  DHSGlyphLabelBase+Private.h
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

#import "DHSGlyphLabel.h"

@interface DHSGlyphLabel (Private)

#pragma mark -
#pragma mark Properties

//
// Properties
//

/// Access to the text glyphs. The container can't be changed, but its contents
/// can (but shouldn't) be modified.
@property(nonatomic, readonly) CGGlyph *glyphs;
/// Access to the text points. The container can't be changed, but its contents
/// can (but shouldn't) be modified.
@property(nonatomic, readonly) CGPoint *points;
/// Access to the text sizes. The container can't be changed, but its contents
/// can (but shouldn't) be modified.
@property(nonatomic, readonly) CGSize *sizes;
/// Access to the text rotations. The container can't be changed, but its
/// contents can (but shouldn't) be modified.
@property(nonatomic, readonly) CGFloat *rotations;

#pragma mark -
#pragma mark Private methods

//
// Private methods
//

/**
 * The typesetter specific parameters that can be used to influence the text
 *layout
 *
 * @return The dictionary of parameter keys and values that the typesetter is
 *set to use for layout
 */
- (NSDictionary *)layoutInfo;

/**
 * Only call this if a state change will affect the layout.
 * Call setNeedsDisplay if a state change will not change the layout but the
 * rendering is affected.
 */
- (void)resetPoints;

/**
 * Change the render order of the glyphs that were processed by the layout
 *manager. Subclasses can customize
 * the render order by overwriting this method.
 *
 * @param renderOrder The type of render order to implement. Subclasses must
 *extend the enum \b DHSGlyphLabelGlyphRenderOrder to use new render order
 *choices.
 * @param indexes The location to store the indexes of the new order of the \b
 *glyphs, \b points and \b rotations based on the typesetter layout order, which
 *is usually the default order of the retained text. This is pre-allocated.
 * @param length The size of the index array. This should be same as the length
 *of the retained text.
 */
- (void)processRenderOrder:(DHSGlyphLabelGlyphRenderOrder)renderOrder
             forNewIndexes:(NSInteger *)indexes
                withLength:(NSInteger)length;

@end
