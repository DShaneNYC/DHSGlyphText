//
//  DHSGlyphLabelRandomShift.h
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

#import "DHSGlyphLabelRotation.h"

@interface DHSGlyphLabelRandomShift : DHSGlyphLabelRotation

#pragma mark -
#pragma mark Properties

//
// Properties
//

/// The minimum ratio of width a glyph can be randomly shifted horizontally- can
/// be positive or negative
@property(nonatomic, readwrite) CGFloat horizontalRatioMin;
/// The maximum ratio of width a glyph can be randomly shifted horizontally- can
/// be positive or negative
@property(nonatomic, readwrite) CGFloat horizontalRatioMax;
/// The minimum ratio of height a glyph can be randomly shifted vertically- can
/// be positive or negative
@property(nonatomic, readwrite) CGFloat verticalRatioMin;
/// The maximum ratio of height a glyph can be randomly shifted vertically- can
/// be positive or negative
@property(nonatomic, readwrite) CGFloat verticalRatioMax;
/// The minimum angle in radians a glyph can be randomly rotated- can be
/// positive or negative
@property(nonatomic, readwrite) CGFloat rotationMin;
/// The maximum angle in radians a glyph can be randomly rotated- can be
/// positive or negative
@property(nonatomic, readwrite) CGFloat rotationMax;

@end
