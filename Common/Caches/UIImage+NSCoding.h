#import <Foundation/Foundation.h>

@interface UIImage (NSCoding)

- (id)initWithCoderForArchiver:(NSCoder *)decoder;
- (void)encodeWithCoderForArchiver:(NSCoder *)encoder;

@end