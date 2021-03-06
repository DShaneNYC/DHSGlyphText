//
//  DHSGlyphDemoTests.m
//  DHSGlyphDemoTests
//
//  Created by David Shane on 10/26/13.
//  Copyright (c) 2013 Optiquity, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DHSTest1Cache.h"
#import "DHSTest2Cache.h"

@interface DHSGlyphDemoTests : XCTestCase

@end

@implementation DHSGlyphDemoTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each
  // test method in the class.

  // Clean caches every time
  [[DHSTest1Cache cache] wipe];
  [[DHSTest2Cache cache] wipe];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each
  // test method in the class.
  [super tearDown];
}

- (void)testCache1LevelAdd {
  DHSTest1Cache *cache = [DHSTest1Cache cache];

  // Add too many objects
  [cache setObject:@1 forKey:@"a"];
  [cache setObject:@2 forKey:@"b"];
  [cache setObject:@3 forKey:@"c"];
  [cache setObject:@4 forKey:@"d"];
  [cache setObject:@5 forKey:@"e"];

  XCTAssertTrue([cache countOfL1Items] == 3,
                @"There are %d items in the L1 cache", [cache countOfL1Items]);
  XCTAssertTrue([cache countOfL2Items] == 0,
                @"There are %d items in the L2 cache", [cache countOfL2Items]);
  XCTAssertTrue([cache count] == 3, @"There are %d items in the total cache",
                [cache count]);
}

- (void)testCache2LevelAdd {
  DHSTest2Cache *cache = [DHSTest2Cache cache];

  // Add too many objects
  [cache setObject:@1 forKey:@"a"];
  [cache setObject:@2 forKey:@"b"];
  [cache setObject:@3 forKey:@"c"];
  [cache setObject:@4 forKey:@"d"];
  [cache setObject:@5 forKey:@"e"];

  XCTAssertTrue([cache countOfL1Items] == 2,
                @"There are %d items in the L1 cache", [cache countOfL1Items]);
  XCTAssertTrue([cache countOfL2Items] == 2,
                @"There are %d items in the L2 cache", [cache countOfL2Items]);
  XCTAssertTrue([cache count] == 4, @"There are %d items in the total cache",
                [cache count]);
}

- (void)testCache2LevelAddSaveLoad {
  DHSTest2Cache *cache = [DHSTest2Cache cache];

  // Add too many objects
  [cache setObject:@1 forKey:@"a"];
  [cache setObject:@2 forKey:@"b"];
  [cache setObject:@3 forKey:@"c"];
  [cache setObject:@4 forKey:@"d"];
  [cache setObject:@5 forKey:@"e"];

  XCTAssertTrue([cache count] == 4, @"There are %d items in the total cache",
                [cache count]);
  XCTAssertTrue([cache save], @"Cache saved");
  XCTAssertTrue([cache count] == 4, @"There are %d items in the total cache",
                [cache count]);

  cache[@"e"] = @5;
  cache[@"f"] = @6;

  XCTAssertTrue([cache count] == 4, @"There are %d items in the total cache",
                [cache count]);
  XCTAssertNil([cache objectForKey:@"a"], @"Key 'a' is NOT in the cache");
  XCTAssertNil([cache objectForKey:@"b"], @"Key 'b' is NOT in the cache");
  XCTAssertNotNil([cache objectForKey:@"c"], @"Key 'c' is in the cache");
  XCTAssertNotNil([cache objectForKey:@"d"], @"Key 'd' is in the cache");
  XCTAssertNotNil([cache objectForKey:@"e"], @"Key 'e' is in the cache");
  XCTAssertNotNil([cache objectForKey:@"f"], @"Key 'f' is in the cache");

  [cache clean];
  [cache removeAllObjects];

  XCTAssertTrue([cache count] == 0, @"There are %d items in the total cache",
                [cache count]);
  XCTAssertTrue([cache load], @"Cache loaded");

  XCTAssertTrue([cache count] == 2, @"There are %d items in the total cache",
                [cache count]);
  XCTAssertNil(cache[@"a"], @"Key 'a' is NOT in the cache");
  XCTAssertNil(cache[@"b"], @"Key 'b' is NOT in the cache");
  XCTAssertNotNil([cache objectForKey:@"c"], @"Key 'c' is in the cache");
  XCTAssertNotNil([cache objectForKey:@"d"], @"Key 'd' is in the cache");
  XCTAssertNil([cache objectForKey:@"e"], @"Key 'e' is NOT in the cache");
  XCTAssertNil([cache objectForKey:@"f"], @"Key 'f' is NOT in the cache");
}

@end
