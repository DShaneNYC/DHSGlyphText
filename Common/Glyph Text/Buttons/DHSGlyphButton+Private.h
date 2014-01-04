//
//  DHSGlyphButtonBase+Private.h
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

#import "DHSGlyphButton.h"
#import "DHSGlyphLabel.h"

@interface DHSGlyphButton (Private)

//
// Properties
//

/// The \b DHSGlyphLable elements retained for each of states the button can be in based on \b UIControlState
@property (nonatomic, readwrite)    NSDictionary *states;
/// Whether or not the button parameters have changed and needs to be re-rendered
@property (nonatomic, readwrite)    BOOL needsUpdate;

#pragma mark -
#pragma mark Private methods

//
// Private methods
//

/**
 * Called once for each state when the button is created
 *
 * @param state The \b UIControlState for which to set up the label
 *
 * @return The \b DHSGlyphLabel created to be retained for the given state
 */
- (DHSGlyphLabel *)setupLabelForState:(UIControlState)state;

/**
 * Called when changes to the button state parameters are made to force the button to re-render
 *
 */
- (void)setImages;

@end
