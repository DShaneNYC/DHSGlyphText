//
//  DHSGlyphCache.m
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

#import "DHSGlyphCache.h"

#define DHSGlyphCacheDefaultLevel1Items     350
#define DHSGlyphCacheDefaultMaxItems        1000


@implementation DHSGlyphCache


#pragma mark -
#pragma mark Singleton methods

DHS_SYNTHESIZE_SINGLETON_FOR_CLASS(DHSGlyphCache);

+ (DHSGlyphCache *)cache {
    return [self sharedInstance];
}


#pragma mark -
#pragma mark Memory Management methods

- (void)handleMemoryWarning:(NSNotification *)note {
    // Get rid of half of the cached glyphs
    debugLog(@"Memory warning: Removing %ld elements of the glyph cache", (long)([self count] >> 1));
    [self removeImages:[self count] >> 1];
}

- (instancetype)init {
	if (self = [super init]) {
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}


#pragma mark -
#pragma mark Object methods

- (NSInteger)defaultNumLevel1Items {
    return DHSGlyphCacheDefaultLevel1Items;
}

- (NSInteger)defaultNumMaxItems {
    return DHSGlyphCacheDefaultMaxItems;
}


#pragma mark -
#pragma mark Memory Management methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
