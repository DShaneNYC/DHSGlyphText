//
//  DHSGlyphSizeCache.m
//  DHS
//
//  Created by David Shane on 11/15/10. (DShaneNYC@gmail.com)
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

#import "DHSSynthesizeSingleton.h"

#import "DHSGlyphSizeCache.h"

#define DHSGlyphSizeCacheDefaultLevel1Items 500
#define DHSGlyphSizeCacheDefaultMaxItems 1000

@implementation DHSGlyphSizeCache

#pragma mark -
#pragma mark Singleton methods

DHS_SYNTHESIZE_SINGLETON_FOR_CLASS(DHSGlyphSizeCache);

+ (DHSGlyphSizeCache *)cache {
  return [self sharedInstance];
}

#pragma mark -
#pragma mark Object methods

- (NSInteger)defaultNumLevel1Items {
  return DHSGlyphSizeCacheDefaultLevel1Items;
}

- (NSInteger)defaultNumMaxItems {
  return DHSGlyphSizeCacheDefaultMaxItems;
}

- (void)removeSizeForHash:(NSString *)hashKey {
  [self removeObjectForKey:hashKey];
}

- (CGSize)sizeForHash:(NSString *)hashKey {
  return [(NSValue *)[self objectForKey:hashKey] CGSizeValue];
}

- (void)setSize:(CGSize)size forHash:(NSString *)hashKey {
  [self setObject:[NSValue valueWithCGSize:size] forKey:hashKey];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
  // Nothing but sizes (NSValues)
  if ([(id)object isKindOfClass:[NSValue class]]) {
    [super setObject:(NSValue *)object forKey:key];
  }
}

@end
