//
//  PBDecoder.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBDecoder.h"
#import "PBCodec.h"
#import "PBHelper.h"

static PBDecoder *_privateDecoder = nil;

@interface PBDecoder (
private)

+ (void)decodeMsg:(NSMutableDictionary *)msg withProtos:(NSDictionary *)protos length:(NSUInteger)length;

+ (id)decodeProp:(NSString *)typeStr withProtos:(NSDictionary *)protos;

+ (void)isFinish;

+ (PBHead)getHead;

+ (PBHead)peekHead;

+ (void)decodeArray:(NSArray *)array withProtos:(NSDictionary *)protos andTypeStr:(NSString *)protoTypeStr;

+ (void)getBytes:(BOOL)flag toBuffer:(NSMutableData *)dest;

+ (void)peekBytesToBuffer:(NSMutableData *)dest;

@end

@implementation PBDecoder {
  NSDictionary *_protos;
  NSMutableData *_buffer;
  NSUInteger _offset;
}

+ (void)initialize {
  if (_privateDecoder == nil) {
    _privateDecoder = [[PBDecoder alloc] init];
    log("private encoder initialized.");
  }
}

- (void)setProtos:(NSDictionary *)protos {
  _protos = protos;
  log("setProtos, pointer test:: %p, %p", _protos, protos);
}

- (NSDictionary *)protos {
  return _protos;
}

- (void)setOffset:(NSUInteger)n {
  _offset = n;
}

- (NSUInteger)offset {
  return _offset;
}

- (void)setBuffer:(NSData *)data {
  [_buffer setData:data];
}

- (NSMutableData *)buffer {
  return _buffer;
}

+ (void)loadProtos:(NSDictionary *)protos {
  [_privateDecoder setProtos:protos];
}

+ (NSDictionary *)protos {
  return [_privateDecoder protos];
}

+ (void)setOffset:(NSInteger)n {
  [_privateDecoder setOffset:n];
}

+ (NSUInteger)offset {
  return [_privateDecoder offset];
}

+ (void)setBuffer:(NSData *)data {
  [_privateDecoder setBuffer:data];
}

+ (NSMutableData *)buffer {
  return [_privateDecoder buffer];
}

#pragma mark - decode
+ (void)decodeMsgWithRoute:(NSString *)route andData:(NSMutableData *)data toMsg:(NSMutableDictionary *)msg {
  if (msg == nil) {
    msg = [NSMutableDictionary dictionary];
  }
  NSDictionary *protos = [[PBDecoder protos] objectForKey:route];

  [PBDecoder setBuffer:data];
  [PBDecoder setOffset:0];

  if (protos != nil && [protos count] > 0) {
    [PBDecoder decodeMsg:msg withProtos:protos length:[PBDecoder buffer].length];
    return;
  }

  msg = nil;
}

@end

#pragma mark - private methods
@implementation PBDecoder (
private)

+ (void)decodeMsg:(NSMutableDictionary *)msg withProtos:(NSDictionary *)protos length:(NSUInteger)length {
  while ([PBDecoder offset] < length) {
    PBHead head = [PBDecoder getHead];
    NSString *name = [[protos objectForKey:@"__tags"] objectAtIndex:head.tag];
    NSString *protosNameOption = [[protos objectForKey:name] objectForKey:@"option"];

    if ([protosNameOption isEqualToString:@"optional"] || [protosNameOption isEqualToString:@"required"]) {
      [msg setObject:[PBDecoder decodeProp:[[protos objectForKey:name] objectForKey:@"type"] withProtos:protos] forKey:name];
    } else if ([protosNameOption isEqualToString:@"repeated"]) {
      id msgName = [msg objectForKey:name];
      if ([msgName isKindOfClass:[NSMutableArray class]] || msgName == nil) {
        msgName = [NSMutableArray array];
      }
      [PBDecoder decodeArray:msgName withProtos:protos andTypeStr:[[protos objectForKey:name] objectForKey:@"type"]];
    }
  }
}

+ (id)decodeProp:(NSString *)typeStr withProtos:(NSDictionary *)protos {

  NSMutableData *_local_buffer_ = [NSMutableData data];

  if ([typeStr isEqualToString:@"uInt32"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    unsigned int ui = [PBCodec decodeUInt32:_local_buffer_];
    // done todo return value
    return [NSNumber numberWithUnsignedInt:ui];
  } else if ([typeStr isEqualToString:@"int32"] || [typeStr isEqualToString:@"sInt32"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    signed int si = [PBCodec decodeSInt32:_local_buffer_];
    // done todo return value
    return [NSNumber numberWithInt:si];
  } else if ([typeStr isEqualToString:@"float"]) {
    float flt = [PBCodec decodeFloat:[PBDecoder buffer] from:[PBDecoder offset]];
    [PBDecoder setOffset:([PBDecoder offset] + 4)];
    // done todo return value
    return [NSNumber numberWithFloat:flt];
  } else if ([typeStr isEqualToString:@"double"]) {
    double dbl = [PBCodec decodeDouble:[PBDecoder buffer] from:[PBDecoder offset]];
    [PBDecoder setOffset:([PBDecoder offset] + 8)];
    // done todo return value
    return [NSNumber numberWithDouble:dbl];
  } else if ([typeStr isEqualToString:@"string"]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    NSUInteger length = [PBCodec decodeUInt32:_local_buffer_];

    NSMutableString *str = [NSMutableString string];
    [PBCodec decodeStr:[PBDecoder buffer] dst:str from:[PBDecoder offset] withLength:length];
    [PBDecoder setOffset:([PBDecoder offset] + length)];
    // done todo return value
    return str;
  } else {
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];
    NSDictionary *privateProtosMsgType = [privateProtosMsg objectForKey:typeStr];
    if (protos != nil || privateProtosMsgType != nil) {
      [PBDecoder getBytes:NO toBuffer:_local_buffer_];
      NSUInteger length = [PBCodec decodeUInt32:_local_buffer_];
      // done todo return value
      NSMutableDictionary *msg = [NSMutableDictionary dictionary];
      [PBDecoder decodeMsg:msg withProtos:privateProtosMsgType length:(length + [PBDecoder offset])];
      return msg;
    }
  }
  return nil;
}

// what is this for ?
+ (void)isFinish {
  // return (!protos.__tags[peekHead().tag]);
}

+ (PBHead)getHead {
  NSMutableData *_local_buffer_ = [NSMutableData dataWithLength:4];

  [PBDecoder getBytes:NO toBuffer:_local_buffer_];
  NSUInteger tag = [PBCodec decodeUInt32:_local_buffer_];

  PBHead head;
  head.type = (int) tag & 0x07;
  head.tag = (int) tag >> 3;

  return head;
}

+ (PBHead)peekHead {
  NSMutableData *_local_buffer_ = [NSMutableData dataWithLength:4];

  [PBDecoder peekBytesToBuffer:_local_buffer_];
  NSUInteger tag = [PBCodec decodeUInt32:_local_buffer_];

  PBHead head;
  head.type = (int) tag & 0x07;
  head.tag = (int) tag >> 3;

  return head;
}

+ (void)decodeArray:(NSMutableArray *)array withProtos:(NSDictionary *)protos andTypeStr:(NSString *)protoTypeStr {
  NSMutableData *_local_buffer_ = [NSMutableData data];
  if ([PBHelper isSimpleType:[PBHelper translatePBTypeFromStr:protoTypeStr]]) {
    [PBDecoder getBytes:NO toBuffer:_local_buffer_];
    NSUInteger length = [PBCodec decodeUInt32:_local_buffer_];
    NSUInteger i = 0;
    for (; i < length; i++) {
      // done todo array.push
      [array addObject:[PBDecoder decodeProp:protoTypeStr withProtos:nil]];
    }
  } else {
    // done todo array.push
    [array addObject:[PBDecoder decodeProp:protoTypeStr withProtos:protos]];
  }
}

+ (void)getBytes:(BOOL)flag toBuffer:(NSMutableData *)dest {
  NSUInteger pos = [PBDecoder offset];
  NSUInteger count = 0;
  unsigned char c = 0;

  unsigned char *buff = (unsigned char *) [PBDecoder buffer].bytes;
  unsigned char *dst = malloc([PBDecoder buffer].length);

  do {
    c = buff[pos++];
    dst[count++] = c;
  } while (c >= 128);

  if (!flag) {
    [PBDecoder setOffset:pos];
  }

  NSData *tmpData = [NSData dataWithBytes:dst length:count];
  [dest setData:tmpData];

  free(dst);
}

+ (void)peekBytesToBuffer:(NSMutableData *)dest {
  [PBDecoder getBytes:YES toBuffer:dest];
}


@end
