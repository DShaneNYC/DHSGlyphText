//
//  DHSImageCacheL2.m
//  DHS
//
//  Created by David Shane on 12/19/09. (DShaneNYC@gmail.com)
//  Copyright 2009-2013 David H. Shane. All rights reserved.
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

#import "DHSImageCacheL2.h"

#define DHSImageCacheL2DefaultLevel1MaxItems 300
#define DHSImageCacheL2DefaultMaxItems 500

@implementation DHSImageCacheL2

#pragma mark -
#pragma mark Action methods

- (void)removeImages:(NSInteger)numItems {
  [self removeObjects:numItems];
}

- (void)removeAllImages {
  [self removeAllObjects];
}

#pragma mark -
#pragma mark Object methods

- (NSInteger)defaultNumLevel1Items {
  return DHSImageCacheL2DefaultLevel1MaxItems;
}

- (NSInteger)defaultNumMaxItems {
  return DHSImageCacheL2DefaultMaxItems;
}

- (void)removeImageForHash:(NSString *)hashKey {
  [self removeObjectForKey:hashKey];
}

- (void)removeImageForKey:(NSString *)key {
  [self removeObjectForKey:key];
}

- (UIImage *)imageForHash:(NSString *)hashKey {
  return (UIImage *)[self objectForKey:hashKey];
}

- (UIImage *)imageForKey:(NSString *)key {
  return (UIImage *)[self objectForKey:key];
}

- (void)setImage:(UIImage *)image forHash:(NSString *)hashKey {
  [self setObject:image forKey:hashKey];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
  [self setObject:image forKey:key];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
  // Nothing but images
  if ([(id)object isKindOfClass:[UIImage class]]) {
    // [self setImage:(UIImage *)object forHash:key];
    [super setObject:(UIImage *)object forKey:key];
  }
}

@end
