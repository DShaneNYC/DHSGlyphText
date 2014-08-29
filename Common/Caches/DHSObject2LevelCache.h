//
//  DHSObject2LevelCache.h
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

@class DHSObject2LevelCache;

@protocol DHSObject2LevelCacheDelegate <NSObject>

/**
 * Called on a delegate object just before an item stored in a cache will be removed
 *
 * @param cache The cache the item will be removed from
 * @param obj The object being removed
 * @param key The key for the object being removed
 */
- (void)DHScache:(DHSObject2LevelCache *)cache willEvictObject:(id<NSCoding>)obj forKey:(id<NSCoding>)key;

@end

@interface DHSObject2LevelCache : NSObject

/// The delegate of the cache that will implement the \b DHSObject2LevelCacheDelegate protocol
@property (nonatomic, weak)         id<DHSObject2LevelCacheDelegate> delegate;
/// The size of the level 1 (in memory) portion of the cache
@property (nonatomic, readwrite)    NSInteger cacheLevel1Size;
/// The total size of the cache including the L1 (in memory) and L2 (disk) portions of the cache
@property (nonatomic, readwrite)    NSInteger cacheMaxItemsSize;

// Class methods

#ifdef DEBUG
// For debugging only
- (void)setUnsaved;             // metadata is unsaved
- (NSInteger)countOfL1Keys;
- (NSInteger)countOfL2Keys;
- (NSInteger)countOfL1Items;
- (NSInteger)countOfL2Items;
#endif // DEBUG

// Subclassing methods

/**
 * The unique private name of the cache directory to be used for storing the L2 portion of the cache.
 * It is a single component and not a full path. The default is the class name of the cache.
 *
 * @return The name of the single component subdirectory to use
 */
- (NSString *)pathComponentName;

/**
 * The default number of items to store in the L1 (in memory) portion of the cache
 *
 * @return The number of L1 items
 */
- (NSInteger)defaultNumLevel1Items;

/**
 * The default total number of all items to store in the cache
 *
 * @return The number of all (L1 + L2) items
 */
- (NSInteger)defaultNumMaxItems;

// Action methods

/**
 * Remove all items from the cache, in memory and on disk, including any evidence of saved metadata.
 * This does not change the size of the cache.
 *
 */
- (void)wipe;           // Delete everything

/**
 * Make sure all items in the cache and on disk are accounted for in the cache metadata.
 * Remove any keys or items that can not be reconciled.
 *
 */
- (void)clean;          // Delete disk objects that should not be there in the first place

/**
 * Save the cache index metadata for restoration later.
 *
 * Mutating a cache after a save operation may result in the cache not loading
 * exactly to the same state as before the save. The clean operation will fix
 * inconsitencies, but not correct the mutation.
 *
 * @return Whether or not the save operation succeeded
 */
- (BOOL)save;

/**
 * Load the cache index metadata from a restoration file.
 *
 * Mutating a cache after a save operation may result in the cache not loading
 * exactly to the same state as before the save. The clean operation will fix
 * inconsitencies, but not correct the mutation.
 *
 * @return Whether or not the load operation succeeded
 */
- (BOOL)load;

/**
 * Delete some (or all) of the low priority items in the cache, in memory or on disk.
 * This does not change the size of the cache.
 *
 * @param numItems Number of low priority items to remove. Use 0 to clear all.
 */
- (void)removeObjects:(NSInteger)numItems;

/**
 * Delete all the items in the cache without changing the cache size
 *
 */
- (void)removeAllObjects;

// Object methods

/**
 * The total number of items in the cache, regardless of the max size
 *
 * @return The number of items
 */
- (NSInteger)count;

/**
 * Delete an item from the cache, in memory or on disk.
 * This does not change the size of the cache.
 *
 * @param key The identifier specifying the item in the cache
 */
- (void)removeObjectForKey:(id<NSCoding, NSCopying>)key;

/**
 * Return an item from the cache, from memory or on disk.
 * This does not change the size of the cache.
 *
 * @param key The identifier specifying the item in the cache
 *
 * @return The item associated with the specified key
 */
- (id<NSCoding>)objectForKey:(id<NSCoding, NSCopying>)key;

/**
 * Add or replace an item in the cache, in memory or on disk.
 * This does not change the size of the cache.
 *
 * @param object The item to add to the cache
 * @param key The identifier specifying the item in the cache
 */
- (void)setObject:(id<NSCoding>)object forKey:(id<NSCoding, NSCopying>)key;

/// Method used for object subscripting syntactic sugar equivalent to \b objectForKey:
- (id<NSCoding>)objectForKeyedSubscript:(id<NSCoding, NSCopying>)key;

/// Method used for object subscripting syntactic sugar equivalent to \b setObject:ForKey:
- (void)setObject:(id<NSCoding>)obj forKeyedSubscript:(id<NSCoding, NSCopying>)key;


@end
