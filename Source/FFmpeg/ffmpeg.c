//
//  ffmpeg.c
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
#include "ffmpeg.h"

/**
 *  This file exposes constants and macros defined in ffmpeg with "#define" that are not otherwise available
 *   to Swift code.
 */

/**
 * The error code corresponding to end of file (EOF). Defined in <libavutil/error.h>.
 */
int ERROR_EOF = AVERROR_EOF;

/**
 * The following definitions are identifiers for several ffmpeg channel layouts defined in <libavutil/channel_layout.h>.
 */

long CH_LAYOUT_MONO              = AV_CH_FRONT_CENTER;

long CH_LAYOUT_STEREO            = (AV_CH_FRONT_LEFT|AV_CH_FRONT_RIGHT);

long CH_LAYOUT_STEREO_DOWNMIX    = (AV_CH_STEREO_LEFT|AV_CH_STEREO_RIGHT);

long CH_LAYOUT_2POINT1           = (AV_CH_LAYOUT_STEREO|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_2_1               = (AV_CH_LAYOUT_STEREO|AV_CH_BACK_CENTER);

long CH_LAYOUT_SURROUND          = (AV_CH_LAYOUT_STEREO|AV_CH_FRONT_CENTER);

long CH_LAYOUT_3POINT1           = (AV_CH_LAYOUT_SURROUND|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_4POINT0           = (AV_CH_LAYOUT_SURROUND|AV_CH_BACK_CENTER);

long CH_LAYOUT_4POINT1           = (AV_CH_LAYOUT_4POINT0|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_2_2               = (AV_CH_LAYOUT_STEREO|AV_CH_SIDE_LEFT|AV_CH_SIDE_RIGHT);

long CH_LAYOUT_QUAD              = (AV_CH_LAYOUT_STEREO|AV_CH_BACK_LEFT|AV_CH_BACK_RIGHT);

long CH_LAYOUT_5POINT0           = (AV_CH_LAYOUT_SURROUND|AV_CH_SIDE_LEFT|AV_CH_SIDE_RIGHT);

long CH_LAYOUT_5POINT1           = (AV_CH_LAYOUT_5POINT0|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_5POINT0_BACK      = (AV_CH_LAYOUT_SURROUND|AV_CH_BACK_LEFT|AV_CH_BACK_RIGHT);

long CH_LAYOUT_5POINT1_BACK      = (AV_CH_LAYOUT_5POINT0_BACK|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_6POINT0           = (AV_CH_LAYOUT_5POINT0|AV_CH_BACK_CENTER);

long CH_LAYOUT_6POINT0_FRONT     = (AV_CH_LAYOUT_2_2|AV_CH_FRONT_LEFT_OF_CENTER|AV_CH_FRONT_RIGHT_OF_CENTER);

long CH_LAYOUT_HEXAGONAL         = (AV_CH_LAYOUT_5POINT0_BACK|AV_CH_BACK_CENTER);

long CH_LAYOUT_6POINT1           = (AV_CH_LAYOUT_5POINT1|AV_CH_BACK_CENTER);

long CH_LAYOUT_6POINT1_BACK      = (AV_CH_LAYOUT_5POINT1_BACK|AV_CH_BACK_CENTER);

long CH_LAYOUT_6POINT1_FRONT     = (AV_CH_LAYOUT_6POINT0_FRONT|AV_CH_LOW_FREQUENCY);

long CH_LAYOUT_7POINT0           = (AV_CH_LAYOUT_5POINT0|AV_CH_BACK_LEFT|AV_CH_BACK_RIGHT);

long CH_LAYOUT_7POINT0_FRONT     = (AV_CH_LAYOUT_5POINT0|AV_CH_FRONT_LEFT_OF_CENTER|AV_CH_FRONT_RIGHT_OF_CENTER);

long CH_LAYOUT_7POINT1           = (AV_CH_LAYOUT_5POINT1|AV_CH_BACK_LEFT|AV_CH_BACK_RIGHT);

long CH_LAYOUT_7POINT1_WIDE      = (AV_CH_LAYOUT_5POINT1|AV_CH_FRONT_LEFT_OF_CENTER|AV_CH_FRONT_RIGHT_OF_CENTER);

long CH_LAYOUT_7POINT1_WIDE_BACK = (AV_CH_LAYOUT_5POINT1_BACK|AV_CH_FRONT_LEFT_OF_CENTER|AV_CH_FRONT_RIGHT_OF_CENTER);

long CH_LAYOUT_OCTAGONAL         = (AV_CH_LAYOUT_5POINT0|AV_CH_BACK_LEFT|AV_CH_BACK_CENTER|AV_CH_BACK_RIGHT);

long CH_LAYOUT_HEXADECAGONAL     = (AV_CH_LAYOUT_OCTAGONAL|AV_CH_WIDE_LEFT|AV_CH_WIDE_RIGHT|AV_CH_TOP_BACK_LEFT|AV_CH_TOP_BACK_RIGHT|AV_CH_TOP_BACK_CENTER|AV_CH_TOP_FRONT_CENTER|AV_CH_TOP_FRONT_LEFT|AV_CH_TOP_FRONT_RIGHT);
