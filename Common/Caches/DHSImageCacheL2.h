//
//  DHSImageCacheL2.h
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

#import <Foundation/Foundation.h>

#import "DHSObject2LevelCache.h"

@interface DHSImageCacheL2 : DHSObject2LevelCache 

// Action methods
- (void)removeImages:(NSInteger)numItems;  // Number of items to remove. Use 0 to clear all
- (void)removeAllImages;

// Object methods
- (void)removeImageForHash:(NSString *)hashKey;
- (UIImage *)imageForHash:(NSString *)hashKey;
- (void)setImage:(UIImage *)image forHash:(NSString *)hashKey;

- (void)removeImageForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

@end
