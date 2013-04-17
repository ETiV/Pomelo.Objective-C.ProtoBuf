//
//  PBDecoder.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _PBHead_ {
  int type;
  int tag;
} PBHead;

@interface PBDecoder : NSObject

+ (void)loadProtos:(NSDictionary *)protos;
+ (void)decodeMsgWithRoute:(NSString *)route andData:(NSMutableData *)data toMsg:(NSMutableDictionary *)msg;

@end

