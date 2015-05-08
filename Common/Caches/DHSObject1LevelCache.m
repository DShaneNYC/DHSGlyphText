//
//  DHSObject1LevelCache.m
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

#import "DHSObject1LevelCache.h"

#define DHSObject1LevelCacheDefaultMaxItems 250

@implementation DHSObject1LevelCache

#pragma mark -
#pragma mark Action methods

- (void)setCacheSize:(NSInteger)newCacheSize {
  [super setCacheMaxItemsSize:newCacheSize];
  [super setCacheLevel1Size:newCacheSize];
}

- (void)setCacheLevel1Size:(NSInteger)newCacheSize {
  [NSException raise:@"unrecognized selector"
              format:@"use setCacheSize: to change the cache capacity in %@",
                     NSStringFromClass([self class])];
}

- (void)setCacheMaxItemsSize:(NSInteger)newCacheSize {
  [NSException raise:@"unrecognized selector"
              format:@"use setCacheSize: to change the cache capacity in %@",
                     NSStringFromClass([self class])];
}

#pragma mark -
#pragma mark Subclassing methods

- (NSInteger)defaultNumLevel1Items {
  return DHSObject1LevelCacheDefaultMaxItems;
}

- (NSInteger)defaultNumMaxItems {
  return DHSObject1LevelCacheDefaultMaxItems;
}

@end
