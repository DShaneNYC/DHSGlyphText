//
//  DHSTest1Cache.m
//  DHSCache
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

#import "DHSTest1Cache.h"

#define DHSTest1CacheDefaultMaxItems        3


@implementation DHSTest1Cache


#pragma mark -
#pragma mark Singleton methods

DHS_SYNTHESIZE_SINGLETON_FOR_CLASS(DHSTest1Cache);

+ (DHSTest1Cache *)cache {
    return [self sharedInstance];
}


#pragma mark -
#pragma mark Object methods

- (NSInteger)defaultNumLevel1Items {
    return DHSTest1CacheDefaultMaxItems;
}

- (NSInteger)defaultNumMaxItems {
    return DHSTest1CacheDefaultMaxItems;
}

@end
