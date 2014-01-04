//
//  DHSGDViewController.h
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

#import <UIKit/UIKit.h>

#import "DHSGlyphLabel.h"
#import "DHSGlyphButton.h"

@interface DHSGDViewController : UIViewController <UITextFieldDelegate> {
    // Test DHSGlyph items
    IBOutlet UILabel *_titleLabel;
    
    // This is the base class, but the nib is set to the DHSGlyph---Line version
    IBOutlet DHSGlyphLabel *_glyphLabel;
    IBOutlet DHSGlyphButton *_glyphButton;
    
    IBOutlet UISegmentedControl *_choiceButtonLabelControl;
    IBOutlet UISegmentedControl *_choiceRenderOrderControl;
    IBOutlet UITextField *_displayTextField;
    
    IBOutlet UILabel *_fontSizeAmtLabel;
    IBOutlet UIStepper *_fontSizeStepper;

    IBOutlet UILabel *_fontStrokeWidthAmtLabel;
    IBOutlet UIStepper *_fontStrokeWidthStepper;
    
    IBOutlet UILabel *_strokeEffectLabel;
    IBOutlet UISwitch *_strokeEffectSwitch;
    
    IBOutlet UILabel *_fontShadowOffsetAmtLabel;
    IBOutlet UIStepper *_fontShadowOffsetStepper;
    
    IBOutlet UISegmentedControl *_choiceGradientFillControl;
    
    IBOutlet UISegmentedControl *_choiceComponentControl;
    
    IBOutlet UILabel *_eitherExpansionBlurDescLabel;
    IBOutlet UILabel *_eitherExpansionBlurAmtLabel;
    IBOutlet UIStepper *_eitherExpansionBlurStepper;

    IBOutlet UIButton *_colorButton1;
    IBOutlet UIButton *_colorButton2;
    IBOutlet UIButton *_colorButton3;
    IBOutlet UIButton *_colorButton4;
    IBOutlet UIButton *_colorButton5;
}

- (IBAction)choiceButtonLabelControlTap:(id)sender;
- (IBAction)choiceRenderOrderControlTap:(id)sender;
- (IBAction)fontSizeStepperTap:(id)sender;
- (IBAction)fontStrokeWidthStepperTap:(id)sender;
- (IBAction)strokeEffectSwitchTap:(id)sender;
- (IBAction)fontShadowOffsetStepperTap:(id)sender;
- (IBAction)choiceGradientFillControlTap:(id)sender;
- (IBAction)choiceComponentControlTap:(id)sender;
- (IBAction)expansionBlurStepperTap:(id)sender;
- (IBAction)colorButtonTap:(UIButton *)sender;

@end
