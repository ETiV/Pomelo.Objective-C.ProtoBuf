//
//  Codec.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBCodec.h"

//inline unsigned long codeLength(int code) {
//  if (code >> 11) { // code >= 0x800
//    return 3;
//  } else if (code >> 7) { // code >= 0x80 and <= 0x7ff
//    return 2;
//  } else {
//    return 1;
//  }
//}
//
//unsigned long encode2UTF8(int charCode) {
//  unsigned long n;
//  if (charCode <= 0x7f) {
//    n = (unsigned long)charCode;
//  } else if (charCode <= 0x7ff) {
//    n = (unsigned long)(0xc0 | (charCode >> 6)) << 8 | (0x80 | (charCode & 0x3f));
//  } else {
//    n = (unsigned long)(0xe0 | (charCode >> 12) << 16) | (0x80 | ((charCode & 0xfc0) >> 6) << 8) | (0x80 | (charCode & 0x3f));
//  }
//  return n;
//}

@implementation PBCodec

+ (void)encodeUInt32:(uint32_t)n dst:(NSMutableData *)dst {
  unsigned char result[5] = {0}, count = 0;
  do {
    result[count++] = (unsigned char) ((n & 0x7F) | 0x80);
    n >>= 7;
  } while (n != 0);
  result[count - 1] &= 0x7F;
  [dst setData:[NSData dataWithBytes:result length:count]];
  //log("encodeUInt32: 0x%@", dst);
}

+ (uint32_t)decodeUInt32:(NSData *)data {
  uint32_t n = 0;
  unsigned char *ptr = (unsigned char *) data.bytes;
  uint32_t i = 0;
  for (; i < data.length; i++) {
    n |= ((ptr[i] & 0x7F) << (i * 7));
  }
  //log("decodeUInt32: %u", n);
  return n;
}

+ (void)encodeSInt32:(int32_t)n dst:(NSMutableData *)dst {
  n = n < 0 ? (abs(n) * 2 - 1) : n * 2;
  [PBCodec encodeUInt32:n dst:dst];
  //log("encodeSInt32: %@", dst);
}

+ (int32_t)decodeSInt32:(NSData *)data {
  // even number means source number is >= 0
  // odd number means source number is < 0
  uint32 n = [PBCodec decodeUInt32:data];
  bool isOddNumber = (bool) (n & 0x1);
  n >>= 1;
  //log("decodeSInt32: %d", ( (isOddNumber) ? (-1 * (n + 1)) : (n) ));
  return ((isOddNumber) ? (-1 * (n + 1)) : (n));
}

+ (void)encodeFloat:(float)n dst:(NSMutableData *)dst {
  union u {
    float f;
    int32_t i;
  };
  union u tmp;
  tmp.f = n;
  [dst setData:[NSData dataWithBytes:&(tmp.i) length:sizeof(float)]];
  //log("encodeFloat: %@", dst);
}

+ (float)decodeFloat:(NSData *)data from:(NSUInteger)offset {
  if (data == nil || data.length < (offset + 4)) {
    return 0.0;
  }

  union u {
    float f;
    int32_t i;
  };
  union u tmp;
  tmp.i = *(int32_t *) data.bytes;
  //log("decodeFloat: %f", tmp.f);
  return tmp.f;
}

+ (void)encodeDouble:(double)n dst:(NSMutableData *)dst {
  union u {
    double d;
    int64_t i;
  };
  union u tmp;
  tmp.d = n;
  [dst setData:[NSData dataWithBytes:&(tmp.i) length:sizeof(double)]];
  //log("encodeDouble: %@", dst);
}

+ (double)decodeDouble:(NSData *)data from:(NSUInteger)offset {
  if (data == nil || data.length < (offset + 8)) {
    return 0.0;
  }
  union u {
    double d;
    int64_t i;
  };
  union u tmp;
  tmp.i = *(int64_t *) data.bytes;
  //log("decodeDouble: %lf", tmp.d);
  return tmp.d;
}

+ (void)encodeStr:(NSString *)str dst:(NSMutableData *)dst from:(NSUInteger)offset {
  [dst replaceBytesInRange:NSMakeRange(offset, [str length])
                 withBytes:[str dataUsingEncoding:NSUTF8StringEncoding].bytes
                    length:[str length]];
//  [dst setData:[str dataUsingEncoding:NSUTF8StringEncoding]];
  //log("encodeStr: %@", dst);
}

+ (void)decodeStr:(NSData *)data dst:(NSMutableString *)dst from:(NSUInteger)offset withLength:(NSUInteger)length {
  [dst setString:[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(offset, length)] encoding:NSUTF8StringEncoding]];
  //log("decodeStr: %@", dst);
}

+ (unsigned long)byteLength:(NSString *)str {
  return [[str dataUsingEncoding:NSUTF8StringEncoding] length];
}

@end
