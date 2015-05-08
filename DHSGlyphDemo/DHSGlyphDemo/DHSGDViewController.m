//
//  DHSGDViewController.m
//  DHSGlyphDemo
//
//  Created by David Shane on 10/26/13. (DShaneNYC@gmail.com)
//  Copyright 2013 David H. Shane. All rights reserved.
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

#import "DHSGDViewController.h"

// Uncomment the following #define to use the DHSGlyphLabelRandomShift
// label subclass

// #define DHSGD_USE_RANDOMSHIFTLABEL

#ifdef DHSGD_USE_RANDOMSHIFTLABEL

#import "DHSGlyphLabelRandomShift.h"

#endif  // DHSGD_USE_RANDOMSHIFTLABEL

typedef enum {
  DHSGlyphDemoButtonLableControlTypeButton = 0,
  DHSGlyphDemoButtonLableControlTypeLabel
} DHSGlyphDemoButtonLableControlType;

typedef enum {
  DHSGlyphDemoGradientFillControlTypeNone = 0,
  DHSGlyphDemoGradientFillControlTypeLinear,
  DHSGlyphDemoGradientFillControlTypeRadial
} DHSGlyphDemoGradientFillType;

typedef enum {
  DHSGlyphDemoComponentControlTypeFill = 0,
  DHSGlyphDemoComponentControlTypeStroke,
  DHSGlyphDemoComponentControlTypeGlow,
  DHSGlyphDemoComponentControlTypeShadow
} DHSGlyphDemoComponentType;

#define DHSGLYPHDEMO_DEFAULT_FONT_NAME @"giant_head_regular_tt.ttf"
#define DHSGLYPHDEMO_CHINESE_FONT_NAME @"STXINGKA.TTF"
#define DHSGLYPHDEMO_JAPANESE_FONT_NAME @"naguri.ttf"
#define DHSGLYPHDEMO_SYSTEM_FONT_NAME @"HiraKakuProN-W6"

@interface DHSGDViewController ()

@end

@implementation DHSGDViewController

- (void)setupButton {
  // Default Font
  [_glyphButton setDefaultFontName:DHSGLYPHDEMO_DEFAULT_FONT_NAME];

  // Chinese Font
  [_glyphButton setFontName:DHSGLYPHDEMO_CHINESE_FONT_NAME forKey:@"zh-Hans"];

  // Japanese Font
  [_glyphButton setFontName:DHSGLYPHDEMO_JAPANESE_FONT_NAME forKey:@"jp"];

  // System Font
  [_glyphButton
      setSystemFont:[UIFont fontWithName:DHSGLYPHDEMO_SYSTEM_FONT_NAME
                                    size:[_glyphButton glyphLabelForState:
                                                           UIControlStateNormal]
                                             .currentFont.fontSize]];

  _glyphButton.shouldCache = NO;
  [_glyphButton setFontSize:45.0f];
  [_glyphButton setTitle:@"Button"];
}

- (void)setupLabel {
#ifdef DHSGD_USE_RANDOMSHIFTLABEL

  // Make a different label than the one that is in the nib

  [_glyphLabel removeFromSuperview];
  _glyphLabel = (DHSGlyphLabel *)
      [[DHSGlyphLabelRandomShift alloc] initWithFrame:_glyphLabel.frame];
  [self.view addSubview:_glyphLabel];

  _glyphLabel.textAlignment = NSTextAlignmentCenter;
  _glyphLabel.textColor = [UIColor whiteColor];
  _glyphLabel.strokeColor = [UIColor blackColor];

  // Add some randomization
  // This can be better handled by making a subclass of DHSGlyphLabelRandomShift
  // and pinning the values

  [(DHSGlyphLabelRandomShift *)_glyphLabel setVerticalRatioMax:0.1f];
  [(DHSGlyphLabelRandomShift *)_glyphLabel setRotationMin:-0.25f];
  [(DHSGlyphLabelRandomShift *)_glyphLabel setRotationMax:0.25f];

#endif  // DHSGD_USE_RANDOMSHIFTLABEL

  // Default Font
  [_glyphLabel setDefaultFontName:DHSGLYPHDEMO_DEFAULT_FONT_NAME];

  // Chinese Font
  [_glyphLabel setFontName:DHSGLYPHDEMO_CHINESE_FONT_NAME forKey:@"zh-Hans"];

  // Japanese Font
  [_glyphLabel setFontName:DHSGLYPHDEMO_JAPANESE_FONT_NAME forKey:@"jp"];

  // System Font
  [_glyphLabel
      setSystemFont:[UIFont fontWithName:DHSGLYPHDEMO_SYSTEM_FONT_NAME
                                    size:_glyphLabel.currentFont.fontSize]];

  _glyphLabel.shouldCache = NO;
  [_glyphLabel setFontSize:30.0f];
  [_glyphLabel setText:@"Label"];

  // Line showing label bounds
  _glyphLabel.layer.borderWidth = 0.5f;
  _glyphLabel.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view, typically from a nib.
  [_titleLabel
      setText:[NSString stringWithFormat:@"DHSGlyph %@", DHSGlyphTextVersion]];

  [self setupButton];
  [self setupLabel];

  _displayTextField.delegate = self;

  _choiceButtonLabelControl.selectedSegmentIndex =
      DHSGlyphDemoButtonLableControlTypeButton;
  [self choiceButtonLabelControlTap:nil];
  _choiceGradientFillControl.selectedSegmentIndex =
      DHSGlyphDemoGradientFillControlTypeNone;
  [self choiceGradientFillControlTap:nil];
  _choiceComponentControl.selectedSegmentIndex =
      DHSGlyphDemoComponentControlTypeFill;
  [self choiceComponentControlTap:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if ([string isEqualToString:@"\n"]) {
    [_displayTextField resignFirstResponder];
    return NO;
  }

  if ([self isCurrentChoiceButton]) {
    // Button
    [_glyphButton setTitle:[_displayTextField.text
                               stringByReplacingCharactersInRange:range
                                                       withString:string]];
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    [_glyphLabel setText:[_displayTextField.text
                             stringByReplacingCharactersInRange:range
                                                     withString:string]];
    [_glyphLabel setNeedsDisplay];
  }

  return YES;
}

#pragma mark -
#pragma mark IBAction methods

- (BOOL)isCurrentChoiceButton {
  return [_choiceButtonLabelControl selectedSegmentIndex] ==
         DHSGlyphDemoButtonLableControlTypeButton;
}

- (IBAction)choiceButtonLabelControlTap:(id)sender {
  switch (_choiceButtonLabelControl.selectedSegmentIndex) {
    case DHSGlyphDemoButtonLableControlTypeButton:
      _choiceRenderOrderControl.selectedSegmentIndex =
          [_glyphButton glyphLabelForState:UIControlStateNormal]
              .glyphRenderOrder;
      _displayTextField.text = _glyphButton.titleLabel.text;
      _displayTextField.placeholder = @"Button Text";
      _fontSizeStepper.value =
          [_glyphButton glyphLabelForState:UIControlStateNormal]
              .currentFont.fontSize;
      _fontStrokeWidthStepper.value =
          [_glyphButton glyphLabelForState:UIControlStateNormal].strokeWidth;
      _strokeEffectSwitch.on =
          [_glyphButton glyphLabelForState:UIControlStateNormal]
              .strokeHasShadow;
      _fontShadowOffsetStepper.value =
          [_glyphButton glyphLabelForState:UIControlStateNormal]
              .shadowOffset.width;
      break;

    case DHSGlyphDemoButtonLableControlTypeLabel:
      _choiceRenderOrderControl.selectedSegmentIndex =
          _glyphLabel.glyphRenderOrder;
      _displayTextField.text = _glyphLabel.text;
      _displayTextField.placeholder = @"Label Text";
      _fontSizeStepper.value = _glyphLabel.currentFont.fontSize;
      _fontStrokeWidthStepper.value = _glyphLabel.strokeWidth;
      _strokeEffectSwitch.on = _glyphLabel.strokeHasShadow;
      _fontShadowOffsetStepper.value = _glyphLabel.shadowOffset.width;
      break;

    default:
      break;
  }

  [self fontSizeStepperTap:nil];
  [self fontStrokeWidthStepperTap:nil];
  [self strokeEffectSwitchTap:nil];
  [self fontShadowOffsetStepperTap:nil];
  [self choiceComponentControlTap:nil];
}

- (IBAction)choiceRenderOrderControlTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    switch (_choiceRenderOrderControl.selectedSegmentIndex) {
      case 0:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderForwards;
        break;

      case 1:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderBackwards;
        break;

      case 2:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderOutsideIn;
        break;

      case 3:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderInsideOut;
        break;

      case 4:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderEven;
        break;

      case 5:
        _glyphButton.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderOdd;
        break;

      default:
        break;
    }
  } else {
    // Label
    switch (_choiceRenderOrderControl.selectedSegmentIndex) {
      case 0:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderForwards;
        break;

      case 1:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderBackwards;
        break;

      case 2:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderOutsideIn;
        break;

      case 3:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderInsideOut;
        break;

      case 4:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderEven;
        break;

      case 5:
        _glyphLabel.glyphRenderOrder = DHSGlyphLabelGlyphRenderOrderOdd;
        break;

      default:
        break;
    }
  }
}

- (IBAction)fontSizeStepperTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    _fontSizeAmtLabel.text =
        [NSString stringWithFormat:@"%.00f", _fontSizeStepper.value];
    [_glyphButton setFontSize:_fontSizeStepper.value];
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    _fontSizeAmtLabel.text =
        [NSString stringWithFormat:@"%.00f", _fontSizeStepper.value];
    [_glyphLabel setFontSize:_fontSizeStepper.value];
    [_glyphLabel setNeedsDisplay];
  }
}

- (IBAction)fontStrokeWidthStepperTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    _fontStrokeWidthAmtLabel.text =
        [NSString stringWithFormat:@"%.01f", _fontStrokeWidthStepper.value];
    [_glyphButton setStrokeWidth:_fontStrokeWidthStepper.value];
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    _fontStrokeWidthAmtLabel.text =
        [NSString stringWithFormat:@"%.01f", _fontStrokeWidthStepper.value];
    [_glyphLabel setStrokeWidth:_fontStrokeWidthStepper.value];
    [_glyphLabel setNeedsDisplay];
  }
}

- (IBAction)strokeEffectSwitchTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        _glyphButton.showIndividualGlyphStroke = _strokeEffectSwitch.on;
        break;

      default:
      case DHSGlyphDemoComponentControlTypeStroke:
        _glyphButton.strokeHasShadow = _strokeEffectSwitch.on;
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        _glyphButton.showIndividualGlyphGlow = _strokeEffectSwitch.on;
        break;
    }

    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        _glyphLabel.showIndividualGlyphStroke = _strokeEffectSwitch.on;
        break;

      default:
      case DHSGlyphDemoComponentControlTypeStroke:
        _glyphLabel.strokeHasShadow = _strokeEffectSwitch.on;
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        _glyphLabel.showIndividualGlyphGlow = _strokeEffectSwitch.on;
        break;
    }
    [_glyphLabel setNeedsDisplay];
  }
}

- (IBAction)fontShadowOffsetStepperTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    _fontShadowOffsetAmtLabel.text = [NSString
        stringWithFormat:@"%.00f, %.00f", _fontShadowOffsetStepper.value,
                         _fontShadowOffsetStepper.value];
    [_glyphButton setShadowOffset:CGSizeMake(_fontShadowOffsetStepper.value,
                                             _fontShadowOffsetStepper.value)];
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    _fontShadowOffsetAmtLabel.text = [NSString
        stringWithFormat:@"%.00f, %.00f", _fontShadowOffsetStepper.value,
                         _fontShadowOffsetStepper.value];
    [_glyphLabel setShadowOffset:CGSizeMake(_fontShadowOffsetStepper.value,
                                            _fontShadowOffsetStepper.value)];
    [_glyphLabel setNeedsDisplay];
  }
}

- (IBAction)choiceGradientFillControlTap:(id)sender {
  CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();

  size_t num_locations = 3;
  CGFloat locations[3] = {0.0, 0.5, 0.75};
  CGFloat components[15] = {255.0 / 255.0, 215.0 / 255.0,
                            23.0 / 255.0,  1.0,  // Light Yellow (opaque)
                            190.0 / 255.0, 190.0 / 255.0,
                            190.0 / 255.0, 1.0,  // Dark Gray (opaque)
                            180.0 / 255.0, 140.0 / 255.0,
                            2.0 / 255.0,   1.0};  // Dark Yellow (opaque)

  CGGradientRef myGradient = CGGradientCreateWithColorComponents(
      myColorspace, components, locations, num_locations);

  if ([self isCurrentChoiceButton]) {
    // Button
    switch (_choiceGradientFillControl.selectedSegmentIndex) {
      case DHSGlyphDemoGradientFillControlTypeNone:
        [_glyphButton setGradient:NULL];
        break;

      case DHSGlyphDemoGradientFillControlTypeLinear:
        _glyphButton.radialGradient = NO;
        [_glyphButton setGradient:myGradient];
        break;

      case DHSGlyphDemoGradientFillControlTypeRadial:
        _glyphButton.radialGradient = YES;
        [_glyphButton setGradient:myGradient];
        break;

      default:
        break;
    }
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    switch (_choiceGradientFillControl.selectedSegmentIndex) {
      case DHSGlyphDemoGradientFillControlTypeNone:
        [_glyphLabel setGradient:NULL];
        break;

      case DHSGlyphDemoGradientFillControlTypeLinear:
        _glyphLabel.radialGradient = NO;
        [_glyphLabel setGradient:myGradient];
        break;

      case DHSGlyphDemoGradientFillControlTypeRadial:
        _glyphLabel.radialGradient = YES;
        [_glyphLabel setGradient:myGradient];
        break;

      default:
        break;
    }
    [_glyphLabel setNeedsDisplay];
  }

  CGColorSpaceRelease(myColorspace);
  CGGradientRelease(myGradient);
}

- (IBAction)choiceComponentControlTap:(id)sender {
  // Both
  switch (_choiceComponentControl.selectedSegmentIndex) {
    case DHSGlyphDemoComponentControlTypeFill:
      _eitherExpansionBlurDescLabel.text = @"Expansion";
      // From 0.25 - 2.0 by 0.1
      _eitherExpansionBlurStepper.minimumValue = 0.0f;
      _eitherExpansionBlurStepper.maximumValue = 2.0f;
      _eitherExpansionBlurStepper.stepValue = 0.1f;

      _strokeEffectLabel.text = @"Show Glyph Stroke";
      break;

    case DHSGlyphDemoComponentControlTypeStroke:
      _eitherExpansionBlurDescLabel.text = @"Scale (w)";
      // From 0.25 - 2.0 by 0.1
      _eitherExpansionBlurStepper.minimumValue = 0.0f;
      _eitherExpansionBlurStepper.maximumValue = 2.0f;
      _eitherExpansionBlurStepper.stepValue = 0.1f;

      _strokeEffectLabel.text = @"Stroke Has Shadow";
      break;

    case DHSGlyphDemoComponentControlTypeGlow:
      _eitherExpansionBlurDescLabel.text = @"Glow Blur";
      // From 0.0 - 10.0 by 0.1
      _eitherExpansionBlurStepper.minimumValue = 0.0f;
      _eitherExpansionBlurStepper.maximumValue = 10.0f;
      _eitherExpansionBlurStepper.stepValue = 0.1f;

      _strokeEffectLabel.text = @"Show Glyph Glow";
      break;

    case DHSGlyphDemoComponentControlTypeShadow:
      _eitherExpansionBlurDescLabel.text = @"Shadow Blur";
      // From 0.0 - 10.0 by 0.1
      _eitherExpansionBlurStepper.minimumValue = 0.0f;
      _eitherExpansionBlurStepper.maximumValue = 10.0f;
      _eitherExpansionBlurStepper.stepValue = 0.1f;

      _strokeEffectLabel.text = @"Stroke Has Shadow";
      break;

    default:
      break;
  }

  if ([self isCurrentChoiceButton]) {
    // Button
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        _eitherExpansionBlurStepper.value =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .currentFont.glyphExpansionMultiplier;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .showIndividualGlyphStroke;
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        _eitherExpansionBlurStepper.value =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .currentFont.scaleFactor.x;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .strokeHasShadow;
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        _eitherExpansionBlurStepper.value =
            [_glyphButton glyphLabelForState:UIControlStateNormal].glowBlur;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .showIndividualGlyphGlow;
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        _eitherExpansionBlurStepper.value =
            [_glyphButton glyphLabelForState:UIControlStateNormal].shadowBlur;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on =
            [_glyphButton glyphLabelForState:UIControlStateNormal]
                .strokeHasShadow;
        break;

      default:
        break;
    }
  } else {
    // Label
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        _eitherExpansionBlurStepper.value =
            _glyphLabel.currentFont.glyphExpansionMultiplier;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on = _glyphLabel.showIndividualGlyphStroke;
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        _eitherExpansionBlurStepper.value =
            _glyphLabel.currentFont.scaleFactor.x;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on = _glyphLabel.strokeHasShadow;
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        _eitherExpansionBlurStepper.value = _glyphLabel.glowBlur;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on = _glyphLabel.showIndividualGlyphGlow;
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        _eitherExpansionBlurStepper.value = _glyphLabel.shadowBlur;
        _eitherExpansionBlurAmtLabel.text = [NSString
            stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];

        _strokeEffectSwitch.on = _glyphLabel.strokeHasShadow;
        break;

      default:
        break;
    }
  }
}

- (IBAction)expansionBlurStepperTap:(id)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    _eitherExpansionBlurAmtLabel.text =
        [NSString stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        [_glyphButton
            setFontGlyphExpansionMultiplier:_eitherExpansionBlurStepper.value];
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        [_glyphButton
            setFontScaleFactor:CGPointMake(_eitherExpansionBlurStepper.value,
                                           1.0f)];
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        [_glyphButton setGlowBlur:_eitherExpansionBlurStepper.value];
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        [_glyphButton setShadowBlur:_eitherExpansionBlurStepper.value];
        break;

      default:
        break;
    }
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    _eitherExpansionBlurAmtLabel.text =
        [NSString stringWithFormat:@"%.01f", _eitherExpansionBlurStepper.value];
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        [_glyphLabel
            setFontGlyphExpansionMultiplier:_eitherExpansionBlurStepper.value];
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        [_glyphLabel
            setFontScaleFactor:CGPointMake(_eitherExpansionBlurStepper.value,
                                           1.0f)];
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        [_glyphLabel setGlowBlur:_eitherExpansionBlurStepper.value];
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        [_glyphLabel setShadowBlur:_eitherExpansionBlurStepper.value];
        break;

      default:
        break;
    }
    [_glyphLabel setNeedsDisplay];
  }
}

- (IBAction)colorButtonTap:(UIButton *)sender {
  if ([self isCurrentChoiceButton]) {
    // Button
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        [_glyphButton setTitleColor:sender.backgroundColor
                           forState:UIControlStateNormal];
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        [_glyphButton setStrokeColor:sender.backgroundColor];
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        [_glyphButton setGlowColor:sender.backgroundColor];
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        [_glyphButton setTitleShadowColor:sender.backgroundColor
                                 forState:UIControlStateNormal];
        break;

      default:
        break;
    }
    [_glyphButton setNeedsDisplay];
  } else {
    // Label
    switch (_choiceComponentControl.selectedSegmentIndex) {
      case DHSGlyphDemoComponentControlTypeFill:
        [_glyphLabel setTextColor:sender.backgroundColor];
        break;

      case DHSGlyphDemoComponentControlTypeStroke:
        [_glyphLabel setStrokeColor:sender.backgroundColor];
        break;

      case DHSGlyphDemoComponentControlTypeGlow:
        [_glyphLabel setGlowColor:sender.backgroundColor];
        break;

      case DHSGlyphDemoComponentControlTypeShadow:
        [_glyphLabel setShadowColor:sender.backgroundColor];
        break;

      default:
        break;
    }
    [_glyphLabel setNeedsDisplay];
  }
}

@end
