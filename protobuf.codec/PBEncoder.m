//
//  PBEncoder.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-15.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBEncoder.h"
#import "PBCodec.h"
#import "PBHelper.h"

PBEncoder *_privateEncoder = nil;

@interface PBEncoder (
private)

+ (BOOL)checkMsg:(NSDictionary *)msg
      withProtos:(NSDictionary *)protos;

+ (NSUInteger)encodeMsg:(NSDictionary *)msg
             fromOffset:(NSUInteger)offset
             withProtos:(NSDictionary *)protos
               toBuffer:(NSMutableData *)dest;

+ (NSUInteger)encodeProp:(id)value
               asTypeStr:(NSString *)typeStr
               andProtos:(NSDictionary *)protos
                    from:(NSUInteger)offset
                toBuffer:(NSMutableData *)dest;

+ (NSUInteger)encodeArray:(NSArray *)array
                withProto:(NSDictionary *)proto
                andProtos:(NSDictionary *)protos
                     from:(NSUInteger)offset
                 toBuffer:(NSMutableData *)dest;

+ (NSUInteger)writeBytes:(NSMutableData *)source
                    from:(NSUInteger)offset
                withData:(NSData *)data;

+ (void)encodeTag:(NSUInteger)tag
    withPBTypeStr:(NSString *)typeStr
         toBuffer:(NSMutableData *)dest;

@end

@implementation PBEncoder {
  NSDictionary *_protos;
}

+ (void)initialize {
  if (_privateEncoder == nil) {
    _privateEncoder = [[PBEncoder alloc] init];
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

+ (void)loadProtos:(NSDictionary *)protos {
  [_privateEncoder setProtos:protos];
}

+ (NSDictionary *)protos {
  return [_privateEncoder protos];
}


+ (void)encodeMsg:(NSDictionary *)msg withRoute:(NSString *)route toBuffer:(NSMutableData *)destBuffer {
  // Get protos from protos map use the route as key
  NSDictionary *protos = [[PBEncoder protos] objectForKey:route];

  //Check msg
  if ([PBEncoder checkMsg:msg withProtos:protos]) {
    //Set the length of the buffer 2 times bigger to prevent overflow
    NSUInteger length = JSON_stringify(msg).length;

    //Init buffer and offset
    NSMutableData *buffer = [[NSMutableData alloc] initWithLength:length];
    NSUInteger offset = 0;

    if (protos != nil) {
      offset = [PBEncoder encodeMsg:msg fromOffset:offset withProtos:protos toBuffer:buffer];
      if (offset > 0) {
        // OK
        if (destBuffer == nil) {
          destBuffer = [[NSMutableData alloc] initWithLength:offset];
        }
        [destBuffer setData:[buffer subdataWithRange:NSMakeRange(0, offset)]];
        return;
      }
    }
  }

  destBuffer = nil;
}


@end

#pragma mark - private methods
@implementation PBEncoder (
private)

+ (BOOL)checkMsg:(NSDictionary *)msg withProtos:(NSDictionary *)protos {
  if (protos == nil || [protos count] == 0) {
    return NO;
  }

  NSEnumerator *protosEnum = [protos keyEnumerator];
  id name;
  while ((name = [protosEnum nextObject]) != nil) {
    NSDictionary *proto = [protos objectForKey:name];
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];

    NSString *protoOpt = [proto objectForKey:@"option"];
    NSString *protoTypeStr = [proto objectForKey:@"type"];

    id msgName = [msg objectForKey:@"name"];

    if ([@"required" isEqualToString:protoOpt]) {
      // All required element must exist
      if (nil == msgName) {
        return false;
      }
    } else if ([@"optional" isEqualToString:protoOpt]) {
      if (nil != msgName) {
        if ([privateProtosMsg objectForKey:protoTypeStr] != nil) {
          [PBEncoder checkMsg:msgName
                   withProtos:[privateProtosMsg objectForKey:protoTypeStr]];
        }
      }
    } else if ([@"repeated" isEqualToString:protoOpt]) {
      //Check nest message in repeated elements
      if (msgName != nil && [privateProtosMsg objectForKey:protoTypeStr] != nil) {
        NSEnumerator *msgNamesEnum = [msgName objectEnumerator];
        id singleMsgName;
        while ((singleMsgName = [msgNamesEnum nextObject]) != nil) {
          if (NO == [PBEncoder checkMsg:singleMsgName
                             withProtos:[privateProtosMsg objectForKey:protoTypeStr]]) {
            return NO;
          }
        }
      }
    }
  }
  return YES;
}

+ (NSUInteger)encodeMsg:(NSDictionary *)msg
             fromOffset:(NSUInteger)offset
             withProtos:(NSDictionary *)protos
               toBuffer:(NSMutableData *)dest {
  NSEnumerator *msgEnum = [msg keyEnumerator];
  id name;
  while ((name = [msgEnum nextObject]) != nil) {
    id msgName = [msg objectForKey:name];
    NSDictionary *proto = [protos objectForKey:name];
    if (proto != nil) {
      // switch proto.option
      NSString *protoOpt = [proto objectForKey:@"option"];
      NSString *protoTypeStr = [[proto objectForKey:@"type"] stringValue];
      NSUInteger protoTag = [[proto objectForKey:@"tag"] unsignedIntegerValue];

      NSMutableData *_local_buffer_ = [[NSMutableData alloc] initWithLength:0];

      if ([protoOpt isEqualToString:@"required"] || [protoOpt isEqualToString:@"optional"]) {
        [PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr toBuffer:_local_buffer_];
        offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
        offset = [PBEncoder encodeProp:msgName asTypeStr:protoTypeStr andProtos:protos from:offset toBuffer:dest];
      } else if ([protoOpt isEqualToString:@"repeated"]) {
        // TODO need to test if msgName is instanceOf NSArray
        if ([msgName count] > 0) {
          offset = [PBEncoder encodeArray:msgName
                                withProto:proto
                                andProtos:protos
                                     from:offset
                                 toBuffer:dest];
        }
      }
    }
  }

  return offset;
}

+ (NSUInteger)encodeProp:(id)value
               asTypeStr:(NSString *)typeStr
               andProtos:(NSDictionary *)protos
                    from:(NSUInteger)offset
                toBuffer:(NSMutableData *)dest {

  NSMutableData *_local_buffer_ = [[NSMutableData alloc] initWithLength:0];

  if ([typeStr isEqualToString:@"uInt32"]) {
    [PBCodec encodeUInt32:(uint32_t)[value unsignedIntegerValue] dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
  } else if ([typeStr isEqualToString:@"int32"] || [typeStr isEqualToString:@"sInt32"]) {
    [PBCodec encodeSInt32:(int32_t)[value integerValue] dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
  } else if ([typeStr isEqualToString:@"float"]) {
    [PBCodec encodeFloat:[value floatValue] dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
  } else if ([typeStr isEqualToString:@"double"]) {
    [PBCodec encodeDouble:[value doubleValue] dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
  } else if ([typeStr isEqualToString:@"string"]) {
    // value is NSString
    NSUInteger length = [PBCodec byteLength:value];

    [PBCodec encodeUInt32:(uint32_t)length dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];

    [PBCodec encodeStr:value dst:dest from:offset];

    offset += length;
  } else if (protos != nil) {
    NSDictionary *privateProtosMsg = [protos objectForKey:@"__messages"];
    if ([privateProtosMsg objectForKey:typeStr] != nil) {
      //Use a tmp buffer to build an internal msg
      NSMutableData *_tmp_buffer_ = [NSMutableData dataWithLength:[PBCodec byteLength:JSON_stringify(value)]];
      NSUInteger length = 0;

      length = [PBEncoder encodeMsg:value
                         fromOffset:length
                         withProtos:[privateProtosMsg objectForKey:typeStr]
                           toBuffer:_tmp_buffer_];

      //Encode length
      [PBCodec encodeUInt32:(uint32_t)length dst:_local_buffer_];
      offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
      //contact the object
      [dest replaceBytesInRange:NSMakeRange(offset, length) withBytes:_tmp_buffer_.bytes length:length];
    }
  }

  return offset;
}

+ (NSUInteger)encodeArray:(NSArray *)array
                withProto:(NSDictionary *)proto
                andProtos:(NSDictionary *)protos
                     from:(NSUInteger)offset
                 toBuffer:(NSMutableData *)dest {
  int i = 0;
  NSString *protoTypeStr = [[proto objectForKey:@"type"] stringValue];
  NSUInteger protoTag = [[proto objectForKey:@"tag"] unsignedIntegerValue];
  NSMutableData *_local_buffer_ = [[NSMutableData alloc] initWithLength:0];

  if ([PBHelper isSimpleType:[PBHelper translatePBTypeFromStr:protoTypeStr]]) {
    [PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr toBuffer:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];

    [PBCodec encodeUInt32:(uint32_t) [array count] dst:_local_buffer_];
    offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
    for (i = 0; i < [array count]; i++) {
      [PBEncoder encodeProp:[array objectAtIndex:i]
                  asTypeStr:protoTypeStr
                  andProtos:nil
                       from:offset
                   toBuffer:dest];
    }
  } else {
    for (i = 0; i < [array count]; i++) {
      [PBEncoder encodeTag:protoTag withPBTypeStr:protoTypeStr toBuffer:_local_buffer_];
      offset = [PBEncoder writeBytes:dest from:offset withData:_local_buffer_];
      offset = [PBEncoder encodeProp:[array objectAtIndex:i] asTypeStr:protoTypeStr andProtos:protos from:offset toBuffer:dest];
    }
  }
  return offset;
}

+ (NSUInteger)writeBytes:(NSMutableData *)source from:(NSUInteger)offset withData:(NSData *)data {
  [source replaceBytesInRange:NSMakeRange(offset, data.length) withBytes:data.bytes length:data.length];
  return (offset + data.length);
}

+ (void)encodeTag:(NSUInteger)tag withPBTypeStr:(NSString *)typeStr toBuffer:(NSMutableData *)dest {
  ProtoBufType type = [PBHelper translatePBTypeFromStr:typeStr];
  int value = (type == 0) ? 2 : type;
  if (dest == nil) {
    dest = [[NSMutableData alloc] initWithLength:0];
  }
  [PBCodec encodeUInt32:(uint32_t) ((tag << 3) | value) dst:dest];
}

@end
