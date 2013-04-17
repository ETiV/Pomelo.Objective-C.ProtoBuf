//
//  Codec.h
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEBUG_LOG 1

#ifdef DEBUG_LOG
#define log(fmt, args...) NSLog(@fmt, ##args)
#else
#define log(fmt, args...)
#endif

#define JSON_stringify(data) [[NSString alloc] initWithData:([NSJSONSerialization dataWithJSONObject:(data) options:0 error:nil]) encoding:NSUTF8StringEncoding]
#define JSON_parse(string) [NSJSONSerialization JSONObjectWithData:([string dataUsingEncoding:NSUTF8StringEncoding]) options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil]

typedef enum {
  PBT_Unknown = -1,
  PBT_UInt32 = 0,
  PBT_SInt32 = 0,
  PBT_Int32 = 0,
  PBT_Double = 1,
  PBT_String = 2,
  PBT_Message = 2,
  PBT_Float = 5
} ProtoBufType;

//inline void translatePBTypeFromType(ProtoBufType type, NSMutableString *str) {
//  switch (type) {
//    case PBT_UInt32:
//      [str setString:@"uInt32"];
//      break;
//    case PBT_SInt32:
//      [str setString:@"sInt32"];
//      break;
//    case PBT_Float:
//      [str setString:@"float"];
//      break;
//    case PBT_Double:
//      [str setString:@"double"];
//      break;
//    case PBT_String:
//      [str setString:@"string"];
//      break;
//    default:
//      [str setString:@"unknown"];
//  }
//}

@interface PBCodec : NSObject

/**
 * unsigned long
 */
+ (void)encodeUInt32:(uint32_t)n dst:(NSMutableData *)dst;

+ (uint32_t)decodeUInt32:(NSData *)data;

/**
 * signed long
 */
+ (void)encodeSInt32:(int32_t)n dst:(NSMutableData *)dst;

+ (int32_t)decodeSInt32:(NSData *)data;

/**
 * float
 */
+ (void)encodeFloat:(float)n dst:(NSMutableData *)dst;

+ (float)decodeFloat:(NSData *)data from:(NSUInteger)offset;

/**
 * double
 */
+ (void)encodeDouble:(double)n dst:(NSMutableData *)dst;

+ (double)decodeDouble:(NSData *)data from:(NSUInteger)offset;

/**
 * string
 */
+ (void)encodeStr:(NSString *)str dst:(NSMutableData *)dst from:(NSUInteger)offset;

+ (void)decodeStr:(NSData *)data dst:(NSMutableString *)dst from:(NSUInteger)offset withLength:(NSUInteger)length;

+ (unsigned long)byteLength:(NSString *)str;

@end
