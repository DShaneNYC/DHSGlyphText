#import <Foundation/Foundation.h>
#import "UIImage+NSCoding.h"
#import <objc/runtime.h>

#define kEncodingKeyData                @"UIImageData"
#define kEncodingKeyScale               @"UIImageScale"
#define kEncodingKeyOrientation         @"UIImageOrientation"

@implementation UIImage (NSCoding)

+ (void)load {
    @autoreleasepool {
        if (![UIImage conformsToProtocol:@protocol(NSCoding)]) {
            Class class = [UIImage class];
            if (!class_addMethod(
                                 class,
                                 @selector(initWithCoder:),
                                 class_getMethodImplementation(class, @selector(initWithCoderForArchiver:)),
                                 protocol_getMethodDescription(@protocol(NSCoding), @selector(initWithCoder:), YES, YES).types
                                 )) {
                debugLog(@"Critical Error - [UIImage initWithCoder:] not defined.");
            }
            
            if (!class_addMethod(
                                 class,
                                 @selector(encodeWithCoder:),
                                 class_getMethodImplementation(class, @selector(encodeWithCoderForArchiver:)),
                                 protocol_getMethodDescription(@protocol(NSCoding), @selector(encodeWithCoder:), YES, YES).types
                                 )) {
                debugLog(@"Critical Error - [UIImage encodeWithCoder:] not defined.");
            }
            
        }
    }
}

- (id)initWithCoderForArchiver:(NSCoder *)decoder {
    CGFloat scale = [decoder decodeFloatForKey:kEncodingKeyScale];
    if (scale <= 0.0f) scale = 1.0f;
    
    UIImageOrientation imageOrientation = [decoder decodeIntForKey:kEncodingKeyOrientation];
    
    NSData *assetData = [decoder decodeObjectForKey:kEncodingKeyData];
    if (assetData) {
        CFDataRef imgData = (__bridge CFDataRef)assetData;
        CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData(imgData);
        CGImageRef cgimage = CGImageCreateWithJPEGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
        self = [self initWithCGImage:cgimage scale:scale orientation:imageOrientation];
        CGImageRelease(cgimage);
        CGDataProviderRelease(imgDataProvider);
    } else {
        self = [super init];
    }
    
    return self;
}

- (void)encodeWithCoderForArchiver:(NSCoder *)encoder {
    NSData *data = UIImagePNGRepresentation(self);
    [encoder encodeObject:data forKey:kEncodingKeyData];
    [encoder encodeObject:[NSNumber numberWithFloat:self.scale] forKey:kEncodingKeyScale];
    [encoder encodeObject:[NSNumber numberWithInt:self.imageOrientation] forKey:kEncodingKeyOrientation];
}

@end