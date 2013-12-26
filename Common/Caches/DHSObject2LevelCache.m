//
//  DHSObject2LevelCache.m
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

#import "DHSObject2LevelCache.h"

#define DHSObject2LevelCacheDefaultLevel1MaxItems       200
#define DHSObject2LevelCacheDefaultTotalMaxItems        500

#define DHSObject2LevelCacheIndexFileName               @"indexFile.arch"

@interface DHSObject2LevelCache () {
    NSMutableDictionary *_cacheItems;
    NSMutableArray *_orderedKeyList;        // New at the end, old at the beginning

    NSInteger _cacheLevel1Size;
    NSInteger _cacheMaxItemsSize;
    BOOL _saved;
}

@end

@implementation DHSObject2LevelCache

@synthesize delegate = _delegate;
@synthesize cacheLevel1Size = _cacheLevel1Size;
@synthesize cacheMaxItemsSize = _cacheMaxItemsSize;


#pragma mark -
#pragma mark Initialization methods

// Stop everything when the app is shutting down
- (void)handleWillTerminate:(NSNotification *)note {
	debugLog(@"Save everything");
	[self save];
}

- (id)init {
	if (self = [super init]) {
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        // Set the initial cache size
        _cacheLevel1Size = [self defaultNumLevel1Items];    // DHSObject2LevelCacheDefaultLevel1MaxItems;
        _cacheMaxItemsSize = [self defaultNumMaxItems];     // DHSObject2LevelCacheDefaultTotalMaxItems;
        _saved = NO;
        
        _cacheItems = [[NSMutableDictionary alloc] initWithCapacity:_cacheMaxItemsSize];
        _orderedKeyList = [[NSMutableArray alloc] initWithCapacity:_cacheMaxItemsSize];
    }
	
	return self;
}


#pragma mark -
#pragma mark Description methods

- (NSString *)objectCachePath {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
	// Image cache is in the path (Cache) directory
	if (!path) {
		debugLog(@"Object Level 2 cache directory not found!");
		return nil;
	}
	
    path = [path stringByAppendingPathComponent:[self pathComponentName]];
    
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
	
	return path;
}

- (NSString *)pathWithkey:(id<NSCoding, NSCopying>)key {
    return [[self objectCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", key]];
}

- (NSArray *)keyFilesInObjectCachePath {
    NSString *path = [self objectCachePath];
    
    NSError *error;
    NSMutableArray *files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error]];
    [files removeObject:DHSObject2LevelCacheIndexFileName];

    return [NSArray arrayWithArray:files];
}

- (BOOL)isCorrupt {
    __block BOOL lastIsNull = YES;
    __block NSInteger switchCount = 0;
    
    [_orderedKeyList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL currentIsNull = [[_cacheItems objectForKey:obj] isKindOfClass:[NSNull class]] ? YES : NO;
        if (lastIsNull != currentIsNull) ++switchCount;
        lastIsNull = currentIsNull;
    }];
    
    return (switchCount <= 1) ? NO : YES;
}

- (NSInteger)countOfL1Keys {
    return [[_cacheItems allKeys] count] - [self countOfL2Keys];
}

- (NSInteger)countOfL2Keys {
    NSArray *files = [self keyFilesInObjectCachePath];
    
    __block NSInteger count = 0;
    
    NSArray *keys = [_cacheItems allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]] &&
            [files indexOfObject:key] != NSNotFound) {
            ++count;
        }
    }];
    
    return count;
}

- (NSInteger)countOfL1Items {
    __block NSInteger count = 0;
    
    NSArray *keys = [_cacheItems allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]] == NO) {
            ++count;
        }
    }];
    
    return count;
}

- (NSInteger)countOfL2Items {
    NSArray *files = [self keyFilesInObjectCachePath];
    
    __block NSInteger count = 0;
    
    [files enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        ++count;
    }];
    
    return count;
}

- (NSString *)description {
    /*
     return [NSString stringWithFormat:@"Corrupt?: %@\nTotal: %d of %d, L1: %d of %d, L2:%d of %d\nKeys:\n%@\nItems:\n%@",
     [self isCorrupt] ? @"YES" : @"No",
     [_orderedKeyList count], _cacheMaxItemsSize,
     [self level1Size], _cacheLevel1Size,
     [self level2Size], _cacheMaxItemsSize - _cacheLevel1Size,
     _orderedKeyList, _cacheItems
     ];
     */
    
    return [NSString stringWithFormat:@"Corrupt?: %@\nTotal: %lu of %ld, L1: %ld keys and %ld items of %ld, L2:%ldkeys and %ld items of %ld",
            [self isCorrupt] ? @"YES" : @"No",
            (unsigned long)[_orderedKeyList count], (long)_cacheMaxItemsSize,
            (long)[self countOfL1Keys], (long)[self countOfL1Items], (long)_cacheLevel1Size,
            (long)[self countOfL2Keys], (long)[self countOfL2Items], (long)_cacheMaxItemsSize - (long)_cacheLevel1Size
            ];
}


#pragma mark -
#pragma mark Debug methods

- (void)setUnsaved {
    _saved = NO;
}


#pragma mark -
#pragma mark Subclassing methods

- (NSString *)pathComponentName {
    // Unique directory for the cache
    // Subclasses must overload this if the class name shouldn't be used
    
    return NSStringFromClass([self class]);
}

- (NSInteger)defaultNumLevel1Items {
    // Subclasses must overload this in order to change the default L1 cache size
    return DHSObject2LevelCacheDefaultLevel1MaxItems;
}

- (NSInteger)defaultNumMaxItems {
    // Subclasses must overload this in order to change the default total cache size
    return DHSObject2LevelCacheDefaultTotalMaxItems;
}


#pragma mark -
#pragma mark Action methods

- (void)removeFiles {
    [[NSFileManager defaultManager] removeItemAtPath:[self objectCachePath] error:NULL];
}

- (void)wipe {
    [self removeFiles];
    [self removeAllObjects];
    
    _saved = YES;
}

- (void)clean {
    // Remove keys that have no cache items
    NSArray *keyListRef = [_orderedKeyList copy];
    [keyListRef enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([_cacheItems objectForKey:key] == nil) {
            [_orderedKeyList removeObject:key];
        }
    }];
    
    // Remove files that are not in the cache
    NSArray *files = [self keyFilesInObjectCachePath];
    [files enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSError *error;
        if ([_cacheItems objectForKey:key] == nil ||
            [_orderedKeyList indexOfObject:key] == NSNotFound) {
            
            [[NSFileManager defaultManager] removeItemAtPath:[self pathWithkey:key] error:&error];
            [_orderedKeyList removeObject:key];
            [_cacheItems removeObjectForKey:key];
        }
    }];
    
    // Remove L2 files whose objects are in the L1 cache
    [files enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSError *error;
        if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]] == NO) {
            [[NSFileManager defaultManager] removeItemAtPath:[self pathWithkey:key] error:&error];
        }
    }];
    
    // Remove cache items that are NULL but have no files
    NSArray *keys = [_cacheItems allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]] &&
            [files indexOfObject:key] == NSNotFound) {
            
            [_orderedKeyList removeObject:key];
            [_cacheItems removeObjectForKey:key];
        }
    }];
}

- (BOOL)removeFromLevel2ObjectForKey:(id<NSCoding, NSCopying>)key {
    if (_delegate) {
        id<NSCoding> obj = [self retrieveFromLevel2ObjectForKey:key];
        if (obj) [_delegate cache:self willEvictObject:obj forKey:key];
    }
    
    // Delete object on disk
    NSString *saveFile = [self pathWithkey:key];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:saveFile error:&error];
    
    return error ? NO : YES;
}

- (id<NSCoding>)retrieveFromLevel2ObjectForKey:(id<NSCoding, NSCopying>)key {
    id obj = nil;
    
    // Retrieve object from disk
    NSString *saveFile = [self pathWithkey:key];
    obj = [NSKeyedUnarchiver unarchiveObjectWithFile:saveFile];
    
    return obj;
}

- (BOOL)sendToLevel2Object:(id<NSCoding>)obj forKey:(id<NSCoding, NSCopying>)key {
    // Write object to disk
	NSString *saveFile = [self pathWithkey:key];
	BOOL result = [NSKeyedArchiver archiveRootObject:obj toFile:saveFile];
    
    return result;
}

- (BOOL)save {
    if (_saved == YES) return YES;
    
    @synchronized(self) {
        debugLog(@"Saving Object Level 2 Cache");
        
        // Save each object
        __block BOOL success = YES;
        
        [_orderedKeyList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            id obj = [_cacheItems objectForKey:key];
            if ([obj isKindOfClass:[NSNull class]] == NO &&
                [self sendToLevel2Object:obj forKey:key] == NO) {
                // Failure
                [self wipe];
                success = NO;
                *stop = YES;
            }
        }];
        
        if (success == NO) return NO;
        
        // Overwrite existing saved cache index
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              _orderedKeyList, @"_orderedKeyList",
                              [NSNumber numberWithLong:_cacheMaxItemsSize], @"_cacheMaxItemsSize",
                              [NSNumber numberWithLong:_cacheLevel1Size], @"_cacheLevel1Size",
                              nil];
        NSString *saveFile = [self pathWithkey:DHSObject2LevelCacheIndexFileName];
        BOOL result = [NSKeyedArchiver archiveRootObject:dict toFile:saveFile];
        if (result) {
            _saved = YES;
        } else {
            // Failure
            [self wipe];
        }
        
        return result;
    }
}

- (BOOL)load {
    if (_saved == YES) return YES;
    
    // Mutating a cache after a save operation may result in the cache not loading
    // exactly to the same state as before the save. The clean operation will fix
    // inconsitencies, but not correct the mutation.
    
    @synchronized(self) {
        debugLog(@"Restoring Object Level 2 Cache");
        
        NSString *saveFile = [self pathWithkey:DHSObject2LevelCacheIndexFileName];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:saveFile];
        NSMutableArray *newKeyList = [dict objectForKey:@"_orderedKeyList"];
        NSInteger cacheMaxItemsSize = [[dict objectForKey:@"_cacheMaxItemsSize"] intValue];
        NSInteger cacheLevel1Size = [[dict objectForKey:@"_cacheLevel1Size"] intValue];
        if (newKeyList == nil) return NO;
        
        _cacheItems = nil;
        _cacheItems = [[NSMutableDictionary alloc] initWithCapacity:cacheMaxItemsSize];
        _orderedKeyList = nil;
        
        // Don't inform delegate during load
        id<DHSObject2LevelCacheDelegate> delegateHolder = _delegate;
        _delegate = nil;
        
        // Load each object
        __block BOOL success = YES;
        
        [newKeyList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            id obj = [self retrieveFromLevel2ObjectForKey:key];
            if (obj) {
                // Level 1 is at the end
                NSInteger level1StartIndex = cacheMaxItemsSize - cacheLevel1Size;
                if (idx >= level1StartIndex) {
                    // Level 1 object
                    [_cacheItems setObject:obj forKey:key];
                    [self removeFromLevel2ObjectForKey:key];
                } else {
                    // Level 2 object
                    [_cacheItems setObject:[NSNull null] forKey:key];
                }
            }
        }];
        
        if (success == NO) return NO;
        
        // Clean up
        _cacheMaxItemsSize = cacheMaxItemsSize;
        _cacheLevel1Size = cacheLevel1Size;
        _orderedKeyList = newKeyList;
        [self clean];
        _saved = YES;
        
        _delegate = delegateHolder;
        return YES;
    }
}

- (void)removeObjects:(NSInteger)numItems {
    @synchronized(self) {
        if (numItems <= 0 || numItems >= [_orderedKeyList count]) {
            // Get rid of all cache and list items
            [_cacheItems removeAllObjects];
            [_orderedKeyList removeAllObjects];
            
        } else {
            // Get rid of some cache items
            for (NSInteger i = 0; i < numItems; ++i) {
                NSString *key = [_orderedKeyList objectAtIndex:i];
                
                if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]]) {
                    // L2
                    [self removeFromLevel2ObjectForKey:key];
                } else if (_delegate) {
                    // L1
                    id<NSCoding> obj = [_cacheItems objectForKey:key];
                    if (obj) [_delegate cache:self willEvictObject:obj forKey:key];
                }
                
                // Both: if L2 remove NSNull, if L1 remove object
                [_cacheItems removeObjectForKey:key];
            }
            
            // Get rid of some key list items
            [_orderedKeyList removeObjectsInRange:NSMakeRange(0, numItems)];
        }
        
        _saved = NO;
    }
}

- (void)removeAllObjects {
    [self removeObjects:0];
}

- (NSInteger)count {
    return [_orderedKeyList count];
}

- (void)setCacheLevel1Size:(NSInteger)newCacheSize {
    if (newCacheSize <= 0) return;
    
    if (newCacheSize > _cacheMaxItemsSize) {
        _cacheMaxItemsSize = newCacheSize;
        // No need to get the extra items from the L2 area since they will be loaded as needed
        
        _saved = NO;
    }
    
    if (newCacheSize < _cacheLevel1Size) {
        _cacheLevel1Size = newCacheSize;
        
        NSInteger removeCount = MAX(0, [_orderedKeyList count] - newCacheSize);
        
        // Get rid of cache items
        for (NSInteger i = 0; i < removeCount; ++i) {
            NSString *key = [_orderedKeyList objectAtIndex:i];
            id obj = [_cacheItems objectForKey:key];
            
            if ([obj isKindOfClass:[NSNull class]] == NO) {
                [self sendToLevel2Object:obj forKey:key];
                [_cacheItems setObject:[NSNull null] forKey:key];
            }
        }
        
        _saved = NO;
    }
}

- (void)setCacheMaxItemsSize:(NSInteger)newCacheSize {
    if (newCacheSize <= 0) return;
    
    if (newCacheSize < _cacheMaxItemsSize) {
        [self removeObjects:_cacheMaxItemsSize - newCacheSize];
        
        _saved = NO;
    }
    
    _cacheMaxItemsSize = newCacheSize;
    
    if (newCacheSize < _cacheLevel1Size) {
        [self setCacheLevel1Size:newCacheSize];
        
        _saved = NO;
    }
}


#pragma mark -
#pragma mark Object methods

- (void)pruneLevel1Cache {
    // See if the level 1 cache is full
    if ([_orderedKeyList count] > _cacheLevel1Size) {
        NSInteger max = [_orderedKeyList count] - _cacheLevel1Size;
        for (NSInteger i = 0; i < max; ++i) {
            NSString *killKey = [_orderedKeyList objectAtIndex:i];
            id obj = [_cacheItems objectForKey:killKey];
            
            if ([obj isKindOfClass:[NSNull class]] == NO) {
                [self sendToLevel2Object:obj forKey:killKey];
                [_cacheItems setObject:[NSNull null] forKey:killKey];
            }
            
            _saved = NO;
        }
    }
}

- (void)pruneLevel2Cache {
    // See if the whole cache is full
	while ([_orderedKeyList count] > _cacheMaxItemsSize) {
		// It is, so kill the top one
        NSString *killKey = [_orderedKeyList objectAtIndex:0];
        
        if ([[_cacheItems objectForKey:killKey] isKindOfClass:[NSNull class]]) {
            // L2
            [self removeFromLevel2ObjectForKey:killKey];
        } else if (_delegate) {
            // L1
            id<NSCoding> obj = [_cacheItems objectForKey:killKey];
            if (obj) [_delegate cache:self willEvictObject:obj forKey:killKey];
        }
        
        // Both: if L2 remove NSNull, if L1 remove object
        [_cacheItems removeObjectForKey:killKey];
		[_orderedKeyList removeObjectAtIndex:0];
        
        _saved = NO;
    }
    
    [self pruneLevel1Cache];
}

- (void)removeObjectForKey:(id<NSCoding, NSCopying>)key {
    @synchronized(self) {
        // NSLog(@"del %@: %@", NSStringFromClass([self class]), [self description]);

        if ([[_cacheItems objectForKey:key] isKindOfClass:[NSNull class]]) {
            [self removeFromLevel2ObjectForKey:key];
        }
        [_cacheItems removeObjectForKey:key];
        [_orderedKeyList removeObject:key];
        
        // No need to prune cache (level 1 or 2)
        
        _saved = NO;
    }
}

- (id<NSCoding>)objectForKey:(id<NSCoding, NSCopying>)key {
    @synchronized(self) {
        // NSLog(@"get %@: %@", NSStringFromClass([self class]), [self description]);
        
        id obj = [_cacheItems objectForKey:key];
        if (obj == nil) return nil;
        
        // Move the key to the end so it won't be as likely to be removed
        [_orderedKeyList removeObject:key];
        [_orderedKeyList addObject:key];
        
        // Get the level 2 version if necessary
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = [self retrieveFromLevel2ObjectForKey:key];
            if (obj) {
                // Put it in the level 1 area
                [_cacheItems setObject:obj forKey:key];
                [self removeFromLevel2ObjectForKey:key];
            } else {
                // Doesn't exist so get rit of it
                [_orderedKeyList removeObject:key];
                [_cacheItems removeObjectForKey:key];
            }
        }
        
        [self pruneLevel1Cache];
        
        // Return the object
        return obj;
    }
}

- (void)setObject:(id<NSCoding>)object forKey:(id<NSCoding, NSCopying>)key {
    @synchronized(self) {
        // NSLog(@"set %@: %@", NSStringFromClass([self class]), [self description]);

        // Bail for no object
        if (object == nil) return;
        
        // See if the item exists
        id obj = [_cacheItems objectForKey:key];
        if (obj) [_orderedKeyList removeObject:key];
        
        // Add the new one to the end
        [_cacheItems setObject:object forKey:key];
        [_orderedKeyList addObject:key];
        
        [self pruneLevel2Cache];
        
        _saved = NO;
    }
}

- (id<NSCoding>)objectForKeyedSubscript:(id<NSCoding, NSCopying>)key {
    return [self objectForKey:key];
}

- (void)setObject:(id<NSCoding>)obj forKeyedSubscript:(id<NSCoding, NSCopying>)key {
    [self setObject:obj forKey:key];
}

#pragma mark -
#pragma mark Memory management methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // If the cache isn't saved then get rid of the evidence
    if (_saved == NO) [self removeFiles];
}

@end
