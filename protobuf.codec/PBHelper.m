//
//  PBHelper.m
//  protobuf.codec
//
//  Created by ETiV on 13-4-16.
//  Copyright (c) 2013年 ETiV. All rights reserved.
//

#import "PBHelper.h"

@implementation PBHelper

+ (BOOL) isSimpleType:(ProtoBufType)pbType
{
    return (pbType == PBT_UInt32 ||
            pbType == PBT_SInt32 ||
            pbType == PBT_Int32 ||
            pbType == PBT_Double ||
            pbType == PBT_String ||
            pbType == PBT_Message ||
            pbType == PBT_Float
            );
}

+ (ProtoBufType) translatePBTypeFromStr:(NSString *)key
{
    if ([key isEqualToString:@"uInt32"]) {
        return PBT_UInt32;
    }
    if ([key isEqualToString:@"int32"]) {
        return PBT_SInt32;
    }
    if ([key isEqualToString:@"sInt32"]) {
        return PBT_SInt32;
    }
    if ([key isEqualToString:@"float"]) {
        return PBT_Float;
    }
    if ([key isEqualToString:@"double"]) {
        return PBT_Double;
    }
    if ([key isEqualToString:@"string"]) {
        return PBT_String;
    }
    return PBT_Unknown;
}

@end
