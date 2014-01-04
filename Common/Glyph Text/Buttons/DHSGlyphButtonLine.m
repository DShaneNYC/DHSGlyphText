//
//  DHSGlyphButtonLine.m
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

#import "DHSGlyphButtonLine.h"
#import "DHSGlyphButton+Private.h"
#import "DHSGlyphLabelLine.h"

@implementation DHSGlyphButtonLine

#pragma mark -
#pragma mark Initialization methods

- (DHSGlyphLabel *)setupLabelForState:(UIControlState)state {
    // Subclasses can specify a different DHSGlyphLabelBase for any state
    return (DHSGlyphLabel *)[[DHSGlyphLabelLine alloc] initWithFrame:self.frame];
}


#pragma mark -
#pragma mark Label Line Rendering Parameter methods

- (void)setLineLayoutStyle:(DHSGlyphTypesetterLineLayoutStyle)lineLayoutStyle {
	// Set for all states
	for (NSNumber *key in self.states) {
		DHSGlyphLabel *label = [self.states objectForKey:key];
        [(DHSGlyphLabelLine *)label setLineLayoutStyle:lineLayoutStyle];
	}
    
	[self setImages];
}

- (void)setLineLayoutStyle:(DHSGlyphTypesetterLineLayoutStyle)lineLayoutStyle forState:(UIControlState)state {
	DHSGlyphLabel *label = [self.states objectForKey:[NSNumber numberWithInt:state]];
    [(DHSGlyphLabelLine *)label setLineLayoutStyle:lineLayoutStyle];
    
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setLineLayoutStyleMultiplier:(CGFloat)lineLayoutStyleMultiplier {
	// Set for all states
	for (NSNumber *key in self.states) {
		DHSGlyphLabel *label = [self.states objectForKey:key];
        [(DHSGlyphLabelLine *)label setLineLayoutStyleMultiplier:lineLayoutStyleMultiplier];
	}
    
	[self setImages];
}

- (void)setLineLayoutStyleMultiplier:(CGFloat)lineLayoutStyleMultiplier forState:(UIControlState)state {
	DHSGlyphLabel *label = [self.states objectForKey:[NSNumber numberWithInt:state]];
	[(DHSGlyphLabelLine *)label setLineLayoutStyleMultiplier:lineLayoutStyleMultiplier];
    
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

@end
