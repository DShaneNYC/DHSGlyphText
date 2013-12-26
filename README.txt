====================
--- DHSGlyphText ---
====================

Thanks for using DHSGlyphText!

Created: 11/23/2013
Last Edit: 12/2/2013
Version: 0.1.0
Repo: git://???
Requires: iOS 7+

Who I am:
	David Shane (DShaneNYC@gmail.com)
	http://david.shane.com
	Questions, comments, compliments, constructive criticism? Contact me!

What it is:
     	DHSGlyphText is a localized, multi-lingual customizable and extendable
	text layout and rendering engine for iOS UILabel and UIButton based
	on Core Text and Core Graphics using Objective-C.

What it is NOT:
	An Objective-C wrapper around Text Kit or Core Text.
	Another component that simplifies the use of NSAttributedString with Text
	Kit or Core Text.
	A heavy weight component that leverages Web Kit for layout or rendering.

DHSGlyphText uses Core Text to perform the low level aggregation of glyph
positioning information about text, but then uses its own layout engine to
position and rendering engine to display either individual glyphs or blocks of
text with Core Graphics to achieve localization and visual effects not supported
by Text Kit and Core Text layout. The layout and rendering be customized by
subclassing various components.

What is included:

1) DHSGlyphText classes
2) DHSCache classes
3) DHSGlyphDemo demo project (just run this if you want to see it work)

============================
--- DHSGlyphText classes ---
============================

1) DHSGlyphFont
2) DHSGlyphTypesetterBase
3) DHSGlyphLabelBase
4) DHSGlyphButtonBase

1) DHSGlyphFont is a simple object that keeps CGFontRef and CTFontRef
connections, as well as other information useful for layout and rendering

2) DHSGlyphTypesetter is a subclass of DHSGlyphTypesetterLine -->
DHSGlyphTypesetterBase and is used for layout of text in horizontal lines. While
Text Kit and CTTypesetterRef in Core Text do this (and much more),
DHSGlyphTypesetter does not use NSLayoutManager or CTTypesetterRef because it
adjusts layout using some of the special parameters of DHSGlyphFont and
DHSGlyphLabel.

Additionally, it is possible to create a DHSGlyphTypesetterBase subclass that
does non-linear layout by customizing glyph origins (points), bounding boxes
(sizes) and rotations, so Text Kit and CTTypesetterRef would be useless. On the
other hand, DHSGlyphTypesetter does use Core Text to do the heavy lifting to get
bounding boxes for glyph placement.

Special features of glyph handling by the renderer (outlined below in
DHSGlyphLabel), such as shadows, glows, glyph scaling and horizontal glyph
expansion and compression, require custom layout control by the typesetter since
the glyphs will be sized differently than Core Text specifies.

On a positive note, any new subclasses of DHSGlyphTypesetter can use elements of
Text Kit (such as NSLayoutManager or NSTextContainer) and Core Text freely, if
that would be useful for the layout desired.

- Layout of glyphs must be encapsulated in DHSGlyphTypesetters
- Some layout features include:
	responsive to runtime layout info set by labels or other classes
	vertical line spacing
	class methods to help controllers with layout sizing
- Some layout features that are NOT included (but can be added later or by subclassing):
	exclusion paths

Example subclasses provided:
	DHSGlyphTypesetterLine
	 - a simple line based layout
	DHSGlyphTypesetter
	 - a skeleton subclass of DHSGlyphTypesetterLine
	DHSGlyphTypesetterRotation
	 - adds the same individual glyph rotation for all glyphs to DHSGlyphTypesetterLine
	DHSGlyphTypesetterRandomShift
	 - adds min and max shift randomness to horizontal, vertical and rotation placement
	 for each glyph

Subclassing notes:

When augmenting functionality, when appropriate, remember to call super in each
method subclassed.

Adding new layout parameter will require a new custom version of the
DHSGlyphTypesetterLayoutInfo enum that carries over the existing parent class'
values.

Subclasses of DHSGlyphTypesetter for pinning existing functionality should
minimally implement the following methods:

- (void)setDefaults;

Subclasses of DHSGlyphTypesetter for simple new functionality should minimally
implement the following methods:

+ (NSDictionary *)defaultLayoutInfo;
- (void)setDefaults;
- (void)layoutGlyphs:(CGGlyph *)glyphs
            atPoints:(CGPoint *)points
            andSizes:(CGSize *)sizes
        andRotations:(CGFloat *)rotations
          withLength:(NSInteger)length
              inRect:(CGRect)rect;

Subclasses of DHSGlyphTypesetter for advanced new functionality should minimally
implement the following methods:

+ (CGSize)sizeForText:(NSString *)text
             withFont:(DHSGlyphFont *)font
        andLayoutInfo:(NSDictionary *)layoutInfo
    constrainedToSize:(CGSize)size;
- (BOOL)layoutInRect:(CGRect)rect;
              
3) DHSGlyphLabel is a subclass of DHSGlyphLabelLine --> DHSGlyphLabelBase and is
used for rendering text after it has been laid out by its retained
DHSGlyphTypesetter. The DHSGlyphLabel is responsible for setting the
DHSGlyphTypesetter parameters, requesting the layout from the typesetter, then
rendering the result using Core Graphics. It attempts to do these different
parts as efficiently as possible by doing them only when changes to parameters
are set or by using DHSCache classes to optionally store previous renderings.

Additionally, DHSGlyphLabels help with localization by allowing a different font
to be set for each locale. A default and system font can also be set for backup
in case text can not be rendered with the font set for the current locale or the
font for the current locale has not been set.

- Rendering of text using Core Graphics must be encapsulated in DHSGlyphLabels
- DHSGlyphLabel classes are drop-in compatible with UILabel
- Some rendering features include:
	solid or gradient fill
	stroke around individual glyphs or connected glyphs
	shadows
	glows
	customizable glyph scaling
	horizontal glyph expansion or compression
	customizable glyph rendering order
- Some rendering features that are NOT included (but can be added later):
	support for NSAttributedString and its attributes
	
Example subclasses provided to easily set associated DHSGlyphTypesetter parameters:
	DHSGlyphLabelLine
	DHSGlyphLabel
	DHSGlyphLabelRotation
	DHSGlyphLabelRandomShift

Subclassing notes:

When augmenting functionality, when appropriate, remember to call super in each
method subclassed.

A subclassed DHSGlyphLabel usually matches up with the similarly named
DHSGlyphTypesetter, but it is ok to make factory based labels or subclasses that
use related typesetters.

Subclasses of DHSGlyphLabel for pinning existing functionality should minimally
implement the following methods:

- (void)setDefaults;

Subclasses of DHSGlyphLabel for simple new functionality should minimally
implement the following methods:

- (NSDictionary *)layoutInfo;

4) DHSGlyphButton is a subclass of DHSGlyphButtonLine --> DHSGlyphButtonBase and
it retains a different DHSGlyphLabel for each of its four UIControlStates. It
takes advantage of a parameter of DHSGlyphLabel that shifts text to simulated a
button tap. Subclasses can change this behavior.

- DHSGlyphButton uses DHSGlyphLabel for rendering
- DHSGlyphButton classes are drop-in compatible with UIButton

Example subclasses provided:
	DHSGlyphButtonLine
	DHSGlyphButton

Subclassing notes:

When augmenting functionality, when appropriate, remember to call super in each
method subclassed.

Subclasses of DHSGlyphButton for pinning existing functionality should minimally
implement the following methods:

- (DHSGlyphLabelBase *)setupLabelForState:(UIControlState)state;

NOTES:
- Subclassing of typesetters, labels and buttons for extending functionality or
limiting or pre-setting parameters is encouraged
- Remember to run Analyze in Xcode 5 to take advantage of Doxygen format quick
(option-click) method documentation 

========================
--- DHSCache classes ---
========================

1) DHSObject2LevelCache
2) DHSObject1LevelCache (subclass of DHSObject2LevelCache)
3) DHSImageCacheL2 (subclass of DHSObject2LevelCache)

These classes are simple LRU caches that can be used with NSCoding compliant
keys and objects. Unlike NSCache, keys are copied and there is no benefit in
using objects that implement the NSDiscardableContent protocol.

So why use these classes, you may ask?

1) DHSObject2LevelCache is a 2 level cache. That means that the most recently
used objects are kept in memory while least recently used objects are saved to
disk or kicked out of the cache. There are also methods that load and save the
entire cache from disk, so that it can be re-used between sessions.

2) DHSObject1LevelCache is a subclass of DHSObject2LevelCache that doesn't save
its level 2 objects to disk during normal use, but can still load and save for
re-use between sessions.

3) DHSImageCacheL2 is a subclass of DHSObject2LevelCache with convenience
methods for UIImage.

Note that all keys and objects must be NSCoding compliant and keys are not
hashed internally, so they must be valid file names with no collisions with
other keys.

=================================
--- DHSGlyphDemo demo project ---
=================================

The DHSGlyphDemo project is a simple iOS app that you can use to see how the
DHSGlyph classes are implemented and used. There are a lot of feature methods
that are testable in the demo, but it is not an exhaustive test and nor is it
meant to be. It is just there to get you started.

Actions to try:
- Select Button or Label
- Select the glyph layout order
- Change the text displayed
- Change the font size
- Change the stroke width
- Select whether the stroke is on each glyph or around an entire word
- Change the shadow offset
- Select if there is a gradient fill or not
- Select whether the fill, stroke, glow or shadow is modified
- Change the glyph expansion spacing (fill selected)
- Change the scale width (stroke selected)
- Change the glow blur (glow selected)
- Change the shadow blue (shadow selected)
- Change the color of the selected glyph render parameter

Parameters not represented in the demo:
- Scale height
- Glyph rotation
- Interline spacing adjustments
- Subclassing of DHSGlyphTypesetter, DHSGlyphLabel and DHSGlyphButton classes

Copy and paste the following text into the Label or Button in the demo to see
how they behave:

Boys and girls around the world depend on fundamental opportunities.
Les garçons et les filles à travers le monde dépendent des opportunités fondamentales.
Los niños y las niñas de todo el mundo dependen de las oportunidades fundamentales.
男の子と、世界中の女の子が根本的な機会に依存しています。
男孩和世界各地的女孩依靠基本的机会。
Мальчики и девочки во всем мире зависит от фундаментальных возможностей.

See how subclassing can work by uncommenting the line with:
	#define DHSGD_USE_RANDOMSHIFTLABEL
at the top of DHSGDViewController.m. This is only for demo purposes. Ideally,
labels and buttons should be subclassed when pinning parameters is desired, or a
factory pattern implemented to use different typesetters or label subclasses.
