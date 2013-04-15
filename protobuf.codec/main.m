//
//  main.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBCodec.h"
#import "PBEncoder.h"

static NSString *const WS_CLIENT_KEY_TYPE = @"type";
static NSString *const WS_CLIENT_VALUE_TYPE = @"ios-websocket";

static NSString *const WS_CLIENT_KEY_VERSION = @"version";
static NSString *const WS_CLIENT_VALUE_VERSION = @"0.0.1";

static NSString *const kHandshakeDataSys = @"sys";
NSString *const kHandshakeDataUser = @"user";

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");

//      NSDictionary *_handShakeData_Sys = [[NSDictionary alloc] initWithObjectsAndKeys:
//          WS_CLIENT_VALUE_TYPE, WS_CLIENT_KEY_TYPE,
//          WS_CLIENT_VALUE_VERSION, WS_CLIENT_KEY_VERSION, nil];
//      NSDictionary *_handShakeData_Usr = [[NSDictionary alloc] initWithObjectsAndKeys:nil];
//
//      NSDictionary *_handShakeData = [[NSDictionary alloc] initWithObjectsAndKeys:
//          _handShakeData_Sys, kHandshakeDataSys,
//          _handShakeData_Usr, kHandshakeDataUser, nil];
//
//      log("%@", JSON_parse(JSON_stringify(_handShakeData)));

//        NSMutableData *dst = [[NSMutableData alloc]initWithCapacity:10];
//
//        unsigned int n = 256;
//        [PBCodec encodeUInt32:n dst:dst]; // <0x8002>
//        [PBCodec decodeUInt32:dst];
//        
//        n = 127;
//        [PBCodec encodeUInt32:n dst:dst]; // <0x7f>
//        [PBCodec decodeUInt32:dst];
//        
//        n = 128;
//        [PBCodec encodeUInt32:n dst:dst]; // <0x8001>
//        [PBCodec decodeUInt32:dst];
//        
//        n = 4294967211;
//        [PBCodec encodeUInt32:n dst:dst]; // <0xffffffff 0f>
//        [PBCodec decodeUInt32:dst];
//        
//        signed int x = -1;
//        [PBCodec encodeSInt32:x dst:dst]; // <0x01>
//        [PBCodec decodeSInt32:dst];
//
//        x = 22;
//        [PBCodec encodeSInt32:x dst:dst]; // <0x2c>
//        [PBCodec decodeSInt32:dst];
//
//        x = -128;
//        [PBCodec encodeSInt32:x dst:dst]; // <0xff01>
//        [PBCodec decodeSInt32:dst];
//
//        x = -2147483648;
//        [PBCodec encodeSInt32:x dst:dst]; // <0xffffffff 0f>
//        [PBCodec decodeSInt32:dst];
//
//        x = 2147483647;
//        [PBCodec encodeSInt32:x dst:dst]; // <0xfeffffff 0f>
//        [PBCodec decodeSInt32:dst];
//        
//        float f = 0.01;
//        [PBCodec encodeFloat:f dst:dst];
//        [PBCodec decodeFloat:dst];
//        
//        f = 1000.99;
//        [PBCodec encodeFloat:f dst:dst];
//        [PBCodec decodeFloat:dst];
//        
//        f = 99999.73128938912;
//        [PBCodec encodeFloat:f dst:dst];
//        [PBCodec decodeFloat:dst];
//        
//        double d = 0.0001;
//        [PBCodec encodeDouble:d dst:dst];
//        [PBCodec decodeDouble:dst];
//        
//        d = 1000.99;
//        [PBCodec encodeDouble:d dst:dst];
//        [PBCodec decodeDouble:dst];
//        
//        d = 99999.73128938912;
//        [PBCodec encodeDouble:d dst:dst];
//        [PBCodec decodeDouble:dst];
//        
//        NSMutableString *str = [[NSMutableString alloc]
//                                initWithFormat:@"中文:你好世界"];
//        [PBCodec encodeStr:str dst:dst];
//        [PBCodec decodeStr:dst dst:str];
//        
//        str = [[NSMutableString alloc] initWithFormat:@"English, Hello World!"];
//        [PBCodec encodeStr:str dst:dst];
//        [PBCodec decodeStr:dst dst:str];
    }
    return 0;
}

