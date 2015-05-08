//
//  DHSObject1LevelCache.h
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

@interface DHSObject1LevelCache : DHSObject2LevelCache

// Action methods

/**
 * Set the total cache size so that there is no L2 component. If the old size of
 *the
 *          cache is larger than the new size then the cache contents will be
 *pruned.
 *
 * @param newCacheSize The new size of the cache
 */
- (void)setCacheSize:(NSInteger)newCacheSize;

@end
