//
//  bridge.h
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavutil/avutil.h>
#import <libavutil/error.h>
#import <libavutil/channel_layout.h>
#import <libavutil/opt.h>
#import <libavutil/replaygain.h>
#import <libswresample/swresample.h>

#import "ebur128.h"

#import "libcue.h"

/**
 * The error code corresponding to end of file (EOF). Defined in <libavutil/error.h>.
 */
static const int ERROR_EOF = AVERROR_EOF;

/**
 * The following definitions are identifiers for several ffmpeg channel layouts defined in <libavutil/channel_layout.h>.
 */

static const AVChannelLayout AVChannelLayout_Mono                   = (AVChannelLayout)AV_CHANNEL_LAYOUT_MONO;
static const AVChannelLayout AVChannelLayout_Stereo                 = (AVChannelLayout)AV_CHANNEL_LAYOUT_STEREO;

//static const AVChannelLayout AVChannelLayout_Surround               = (AVChannelLayout)AV_CHANNEL_LAYOUT_SURROUND;
//
//static const AVChannelLayout AVChannelLayout_2Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_2POINT1;
//static const AVChannelLayout AVChannelLayout_2_1                    = (AVChannelLayout)AV_CHANNEL_LAYOUT_2_1;
//static const AVChannelLayout AVChannelLayout_2_2                    = (AVChannelLayout)AV_CHANNEL_LAYOUT_2_2;
//static const AVChannelLayout AVChannelLayout_22Point2               = (AVChannelLayout)AV_CHANNEL_LAYOUT_22POINT2;
//
//static const AVChannelLayout AVChannelLayout_3Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_3POINT1;
//static const AVChannelLayout AVChannelLayout_3Point1Point2          = (AVChannelLayout)AV_CHANNEL_LAYOUT_3POINT1POINT2;
//
//static const AVChannelLayout AVChannelLayout_4Point0                = (AVChannelLayout)AV_CHANNEL_LAYOUT_4POINT0;
//static const AVChannelLayout AVChannelLayout_4Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_4POINT1;
//
//static const AVChannelLayout AVChannelLayout_5Point0                = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT0;
//static const AVChannelLayout AVChannelLayout_5Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT1;
//static const AVChannelLayout AVChannelLayout_5Point0Back            = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT0_BACK;
//static const AVChannelLayout AVChannelLayout_5Point1Back            = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT1_BACK;
//static const AVChannelLayout AVChannelLayout_5Point1Point2Back      = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK;
//static const AVChannelLayout AVChannelLayout_5Point1Point4Back      = (AVChannelLayout)AV_CHANNEL_LAYOUT_5POINT1POINT4_BACK;
//
//static const AVChannelLayout AVChannelLayout_6Point0                = (AVChannelLayout)AV_CHANNEL_LAYOUT_6POINT0;
//static const AVChannelLayout AVChannelLayout_6Point0Front           = (AVChannelLayout)AV_CHANNEL_LAYOUT_6POINT0_FRONT;
//static const AVChannelLayout AVChannelLayout_6Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_6POINT1;
//static const AVChannelLayout AVChannelLayout_6Point1Back            = (AVChannelLayout)AV_CHANNEL_LAYOUT_6POINT1_BACK;
//static const AVChannelLayout AVChannelLayout_6Point1Front           = (AVChannelLayout)AV_CHANNEL_LAYOUT_6POINT1_FRONT;
//
//static const AVChannelLayout AVChannelLayout_7Point0                = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT0;
//static const AVChannelLayout AVChannelLayout_7Point0Front           = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT0_FRONT;
//static const AVChannelLayout AVChannelLayout_7Point1                = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1;
//static const AVChannelLayout AVChannelLayout_7Point1Wide            = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1_WIDE;
//static const AVChannelLayout AVChannelLayout_7Point1WideBack        = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1_WIDE_BACK;
//static const AVChannelLayout AVChannelLayout_7Point1Point2          = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1POINT2;
//static const AVChannelLayout AVChannelLayout_7Point1Point4Back      = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1POINT4_BACK;
//static const AVChannelLayout AVChannelLayout_7Point2Point3          = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT2POINT3;
//static const AVChannelLayout AVChannelLayout_7Point1TopBack         = (AVChannelLayout)AV_CHANNEL_LAYOUT_7POINT1_TOP_BACK;
//
//static const AVChannelLayout AVChannelLayout_9Point1Point4Back      = (AVChannelLayout)AV_CHANNEL_LAYOUT_9POINT1POINT4_BACK;
//
//static const AVChannelLayout AVChannelLayout_Quad                   = (AVChannelLayout)AV_CHANNEL_LAYOUT_QUAD;
//static const AVChannelLayout AVChannelLayout_Cube                   = (AVChannelLayout)AV_CHANNEL_LAYOUT_CUBE;
//static const AVChannelLayout AVChannelLayout_Hexagonal              = (AVChannelLayout)AV_CHANNEL_LAYOUT_HEXAGONAL;
//static const AVChannelLayout AVChannelLayout_Octagonal              = (AVChannelLayout)AV_CHANNEL_LAYOUT_OCTAGONAL;
//static const AVChannelLayout AVChannelLayout_Hexadecagonal          = (AVChannelLayout)AV_CHANNEL_LAYOUT_HEXADECAGONAL;
//static const AVChannelLayout AVChannelLayout_StereoDownmix          = (AVChannelLayout)AV_CHANNEL_LAYOUT_STEREO_DOWNMIX;
