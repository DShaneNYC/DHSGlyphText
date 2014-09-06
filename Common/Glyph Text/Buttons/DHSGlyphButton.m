//
//  DHSGlyphButtonBase.m
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

#import <UIKit/UIKit.h>

#import "DHSGlyphButton+Private.h"
#import "DHSGlyphLabel.h"

@interface DHSGlyphButton ()

// Properties
@property (nonatomic, readwrite)    NSDictionary *states;
@property (nonatomic, readwrite)    BOOL needsUpdate;

@end

@implementation DHSGlyphButton

#pragma mark -
#pragma mark Class Initialization methods

+ (instancetype)button {
    return [[self alloc] initWithFrame:CGRectZero];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    return [self button];
}


#pragma mark -
#pragma mark Subclassing methods

- (void)setDefaults {
    // Subclasses should overload this and call super
}

- (void)prerenderCalculate {
    // Subclasses should overload this and call super
}


#pragma mark -
#pragma mark Initialization methods

- (DHSGlyphLabel *)setupLabelForState:(UIControlState)state {
    // Subclasses can specify a different DHSGlyphLabelBase for any state
    return [[DHSGlyphLabel alloc] initWithFrame:self.frame];
}

- (void)setupStates {
	_needsUpdate = YES;
    
	DHSGlyphLabel *normal = [self setupLabelForState:UIControlStateNormal];
	DHSGlyphLabel *highlighted = [self setupLabelForState:UIControlStateHighlighted];
	DHSGlyphLabel *disabled = [self setupLabelForState:UIControlStateDisabled];
	DHSGlyphLabel *selected = [self setupLabelForState:UIControlStateSelected];

    [normal setNumberOfLines:0];
    [highlighted setNumberOfLines:0];
    [disabled setNumberOfLines:0];
    [selected setNumberOfLines:0];

	// Create the object
	_states = @{@(UIControlStateNormal): normal,

			  // UIControlStateHighlighted
			  @(UIControlStateHighlighted): highlighted,

			  // UIControlStateDisabled
			  @(UIControlStateDisabled): disabled,

			  // UIControlStateSelected
			  @(UIControlStateSelected): selected};
			   
	
	//
	// Set properties for all states
	//
	
	// Set from nib or coder
	for (NSNumber *key in _states) {
		[self setTitle:[self titleForState:[key intValue]] forState:[key intValue]];
		[self setTitleColor:[self titleColorForState:[key intValue]] forState:[key intValue]];
		[self setTitleShadowColor:[self titleShadowColorForState:[key intValue]] forState:[key intValue]];
		
		DHSGlyphLabel *label = _states[key];
		[label setTextAlignment:NSTextAlignmentCenter];
	}

	[self setSystemFont:self.titleLabel.font];
	[self setFontSize:[self.titleLabel.font pointSize]];
	[self setShadowBlur:2.0];
    [self setShadowOffset:self.titleLabel.shadowOffset];
	
	//
	// Set specific properties for each state
	//
	
	// UIControlStateNormal
    [self setShiftsToShadowOffset:NO forState:UIControlStateNormal];

	// UIControlStateHighlighted
	[self setShiftsToShadowOffset:YES forState:UIControlStateHighlighted];

	// UIControlStateDisabled
	[self setAlpha:0.5 forState:UIControlStateDisabled];
	
	// UIControlStateSelected
	[self setShiftsToShadowOffset:YES forState:UIControlStateSelected];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setupStates];
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		[self setupStates];
        [self setDefaults];
	}
	return self;
}

- (instancetype)init {
    if (self = [super init]) {
		[self setupStates];
        [self setDefaults];
	}
	return self;
}


#pragma mark -
#pragma mark UIButton methods

/*
- (NSString *)titleForState:(UIControlState)state {
    NSString *title = [[_states objectForKey:[NSNumber numberWithUnsignedLong:(NSUInteger)state]] text];
    
    if ([title length] > 0) return title;
    else return [[_states objectForKey:[NSNumber numberWithUnsignedLong:UIControlStateNormal]] text];
}
*/

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
	
    // Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setText:title];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:nil forState:state];
	
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setText:title];
	[self setImage:[label getImage] forState:state];

	if (state == UIControlStateNormal) {
		// Set title for all other blank states when normal is set
		for (NSNumber *key in _states) {
			DHSGlyphLabel *label = _states[key];
            [label setText:title];
            [self setImage:[label getImage] forState:[key intValue]];
		}
        self.titleLabel.text = title;
	} else {
		// Set state's title to normal title if it is nil (but not empty)
		if (label.text == nil) {
			DHSGlyphLabel *normalLabel = _states[@(UIControlStateNormal)];
			[label setText:normalLabel.text];
			[self setImage:[label getImage] forState:state];
		}
	}
}

- (void)setTitleColor:(UIColor *)color {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setTextColor:color];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
	[super setTitleColor:color forState:state];
	
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setTextColor:color];

	[self setImage:[label getImage] forState:state];
}

- (void)setTitleShadowColor:(UIColor *)color {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setShadowColor:color];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state {
	[super setTitleShadowColor:color forState:state];
	
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setShadowColor:color];

	[self setImage:[label getImage] forState:state];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];

	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setNeedsDisplay];
	}
	
	[self setImages];
}


#pragma mark -
#pragma mark Label Access methods

- (DHSGlyphLabel *)glyphLabelForState:(UIControlState)state {
	return _states[@((NSUInteger)state)];
}

- (BOOL)shouldCache {
    DHSGlyphLabel *label = [self glyphLabelForState:UIControlStateNormal];
    return [label shouldCache];
}

- (void)setShouldCache:(BOOL)shouldCache {
    // Set for all states
    for (NSNumber *key in _states) {
        DHSGlyphLabel *label = _states[key];
        [label setShouldCache:shouldCache];
    }
}

- (void)setImagesIfNeedsUpdate {
    // Only render images if they are changed
    if (_needsUpdate) {
        // Set for all states
        for (NSNumber *key in _states) {
            DHSGlyphLabel *label = _states[key];
            [self setImage:[label getImage] forState:[key intValue]];
        }
        _needsUpdate = NO;
    }
}

- (void)setImages {
    _needsUpdate = YES;
    [super setNeedsDisplay];
}


#pragma mark -
#pragma mark Label Font Handling methods

- (void)setSystemFont:(UIFont *)font {
	[self.titleLabel setFont:font];
	
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setFont:font];
	}
	
	[self setImages];
}

- (void)setFontName:(NSString *)fontName forKey:(NSString *)key {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontName:fontName forKey:key];
	}

	[self setImages];
}

- (void)setFontName:(NSString *)fontName forKey:(NSString *)key forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setFontName:fontName forKey:key];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setDefaultFontName:(NSString *)fontName {
    [self setFontName:fontName forKey:kDHSGlyphDefaultKey];
}

- (void)setSystemFontName:(NSString *)fontName {
    [self setFontName:fontName forKey:kDHSGlyphSystemKey];
}

- (void)setFontSize:(CGFloat)fontSize {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontSize:fontSize];
	}
    
	[self setImages];
}

- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontSize:fontSize forKey:key];
	}

	[self setImages];
}

- (void)setFontSize:(CGFloat)fontSize forKey:(NSString *)key forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setFontSize:fontSize forKey:key];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontScaleFactor:(CGPoint)fontScaleFactor {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontScaleFactor:fontScaleFactor];
	}
	
	[self setImages];
}

- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontScaleFactor:fontScaleFactor forKey:key];
	}
	
	[self setImages];
}

- (void)setFontScaleFactor:(CGPoint)fontScaleFactor forKey:(NSString *)key forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setFontScaleFactor:fontScaleFactor forKey:key];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontDescenderRatio:fontDescenderRatio];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontDescenderRatio:fontDescenderRatio forKey:key];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontDescenderRatio:(CGFloat)fontDescenderRatio forKey:(NSString *)key forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setFontDescenderRatio:fontDescenderRatio forKey:key];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
        [label setFontGlyphExpansionMultiplier:fontGlyphExpansionMultiplier];
	}
    
	[self setImages];
}

- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key {
	// Set for all states
	for (NSNumber *state in _states) {
		DHSGlyphLabel *label = _states[state];
		[label setFontGlyphExpansionMultiplier:fontGlyphExpansionMultiplier forKey:key];
	}
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setFontGlyphExpansionMultiplier:(CGFloat)fontGlyphExpansionMultiplier forKey:(NSString *)key forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setFontGlyphExpansionMultiplier:fontGlyphExpansionMultiplier];
    
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}


#pragma mark -
#pragma mark Label Glyph Rendering Parameter methods

- (void)setStrokeColor:(UIColor *)strokeColor {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setStrokeColor:strokeColor];
	}

	[self setImages];
}

- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setStrokeColor:strokeColor];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setStrokeWidth:strokeWidth];
	}

	[self setImages];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setStrokeWidth:strokeWidth];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setShadowOffset:shadowOffset];
	}

	[self setImages];
}

- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setShadowOffset:shadowOffset];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setShadowBlur:shadowBlur];
	}

	[self setImages];
}

- (void)setShadowBlur:(CGFloat)shadowBlur forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setShadowBlur:shadowBlur];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setStrokeHasShadow:(BOOL)strokeHasShadow {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setStrokeHasShadow:strokeHasShadow];
	}
    
	[self setImages];
}

- (void)setStrokeHasShadow:(BOOL)strokeHasShadow forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
    [label setStrokeHasShadow:strokeHasShadow];
    
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setShiftsToShadowOffset:(BOOL)shifts {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setShiftsToShadowOffset:shifts];
	}
    
	[self setImages];
}

- (void)setShiftsToShadowOffset:(BOOL)shifts forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setShiftsToShadowOffset:shifts];
    
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setGlowColor:(UIColor *)glowColor {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setGlowColor:glowColor];
	}
	
	[self setImages];
}

- (void)setGlowColor:(UIColor *)glowColor forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setGlowColor:glowColor];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setGlowBlur:(CGFloat)glowBlur {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setGlowBlur:glowBlur];
	}
	
	[self setImages];
}

- (void)setGlowBlur:(CGFloat)glowBlur forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setGlowBlur:glowBlur];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setGradient:(CGGradientRef)gradient {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setGradient:gradient];
	}
	
	[self setImages];
}

- (void)setGradient:(CGGradientRef)gradient forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setGradient:gradient];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setRadialGradient:(BOOL)radialGradient {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setRadialGradient:radialGradient];
	}
	
	[self setImages];
}

- (void)setRadialGradient:(BOOL)radialGradient forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
    [label setRadialGradient:radialGradient];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setShowIndividualGlyphStroke:(BOOL)showIndividualGlyphStroke {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setShowIndividualGlyphStroke:showIndividualGlyphStroke];
	}
	
	[self setImages];
}

- (void)setShowIndividualGlyphStroke:(BOOL)showIndividualGlyphStroke forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
    [label setShowIndividualGlyphStroke:showIndividualGlyphStroke];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setShowIndividualGlyphGlow:(BOOL)showIndividualGlyphGlow {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setShowIndividualGlyphGlow:showIndividualGlyphGlow];
	}
	
	[self setImages];
}

- (void)setShowIndividualGlyphGlow:(BOOL)showIndividualGlyphGlow forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
    [label setShowIndividualGlyphGlow:showIndividualGlyphGlow];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}

- (void)setGlyphRenderOrder:(DHSGlyphLabelGlyphRenderOrder)glyphRenderOrder {
	// Set for all states
	for (NSNumber *key in _states) {
		DHSGlyphLabel *label = _states[key];
		[label setGlyphRenderOrder:glyphRenderOrder];
	}
	
	[self setImages];
}

- (void)setGlyphRenderOrder:(DHSGlyphLabelGlyphRenderOrder)glyphRenderOrder forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
    [label setGlyphRenderOrder:glyphRenderOrder];
	
	[self setImages];
	// [self setImage:[label getImage] forState:state];
}


#pragma mark -
#pragma mark Label Display Rendering Parameter methods

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state {
	DHSGlyphLabel *label = _states[@((NSUInteger)state)];
	[label setAlpha:alpha];

	[self setImages];
	// [self setImage:[label getImage] forState:state];
}


#pragma mark -
#pragma mark View drawing methods

- (void)drawRect:(CGRect)rect {
	// Don't call super
	// [super drawRect:rect];

    // Force rendering of images if needed
    [self prerenderCalculate];
    [self setImagesIfNeedsUpdate];
}

@end
