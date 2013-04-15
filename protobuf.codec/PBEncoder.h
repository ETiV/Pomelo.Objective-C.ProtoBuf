//
//  PBEncoder.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBEncoder : NSObject

+ (void)loadProtos:(NSDictionary *)protos; // map to MsgEncoder.init
+ (void)encodeMsg:(NSDictionary *)msg withRoute:(NSString *)route toBuffer:(NSMutableData *)destBuffer; // map to MsgEncoder.encode

@end
