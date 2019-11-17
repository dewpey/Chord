//
//  hypno_Video.h
//  libhypno
//
//  Created by Jacob Sologub on 8/29/19.
//  Copyright © 2019 Hold Still Inc. All rights reserved.
//

#pragma once

#include "hypno_Configuration.h"
#include <CoreMedia/CMBase.h>
#include <string>
#include <memory>
#include <optional>
#include <variant>
#include <map>

#ifdef __OBJC__
 @class AVComposition;
 @class AVVideoComposition;
 @class AVAudioMix;
#else
 class AVComposition;
 class AVVideoComposition;
 class AVAudioMix;
#endif

namespace hypno {

class Context;

/**
 * Represents a hypno video result.
 */
class Video {
public:
    ~Video();
    
    /**
     * Creates a Video object with a specified configuration.
     *
     * @see hypno::Configuration
     */
    static std::shared_ptr<Video> create (const Configuration& configuration);
    
    /**
     * Returns an error or an std::nullopt if there was no error.
     *
     * @see hypno::Configuration
     */
    std::optional<std::string> getError();
    
    /**
     * Returns the AVComposition object associated with this Video.
     *
     * @see https://developer.apple.com/documentation/avfoundation/avcomposition?language=objc
     */
    AVComposition* getComposition() { return composition; };
    
    /**
     * Returns the AVVideoComposition object associated with this Video.
     *
     * @see https://developer.apple.com/documentation/avfoundation/avvideocomposition?language=objc
     */
    AVVideoComposition* getVideoComposition() { return videoComposition; };
    
    /**
     * Returns the AVAudioMix object associated with this Video.
     *
     * @see https://developer.apple.com/documentation/avfoundation/avaudiomix?language=objc
     */
    AVAudioMix* getAudioMix() { return audioMix; };
    
    /**
     * ExportSettings type alias.
     */
    using ExportSettings = std::map<std::string, std::variant<std::string, double>>;
    
    /**
     * Returns the video export settings associated with this Video.
     * @see https://jacobsologub.s3.amazonaws.com/hypno/docs/classes/_hypno_.hypno.composition.html#videoexportsettings
     * @see https://jacobsologub.s3.amazonaws.com/hypno/doc/modules/_hypno_.hypno.html
     *
     * Possible keys are averageBitRate, profileLevel.
     *
     * @see https://developer.apple.com/documentation/avfoundation/avvideoaveragebitratekey?language=objc
     * @see https://developer.apple.com/documentation/avfoundation/avvideoprofilelevelkey?language=objc
     *
     * Possible profileLevel values are H264_Baseline_3_0, H264_Baseline_3_1,
     * H264_Baseline_4_1, H264_Baseline_AutoLevel, H264_High_4_0, H264_High_4_1,
     * H264_High_5_1, H264_High_AutoLevel, H264_Main_3_0, H264_Main_3_1,
     * H264_Main_3_2, H264_Main_4_1, H264_Main_AutoLevel
     *
     * The possible profileLevel values correspond to the string values defined
     * inside AVFoundation/AVVideoSettings.h.
     *
     */
    ExportSettings getVideoExportSettings() const;
    
    /**
     * Returns the audio export settings associated with this Video.
     * @see https://jacobsologub.s3.amazonaws.com/hypno/docs/classes/_hypno_.hypno.composition.html#audioexportsettings
     *
     * Possible keys are format, numberOfChannels, sampleRate, bitRate
     *
     * @see https://developer.apple.com/documentation/avfoundation/avformatidkey?language=objc
     * @see https://developer.apple.com/documentation/avfoundation/avnumberofchannelskey?language=objc
     * @see https://developer.apple.com/documentation/avfoundation/avsampleratekey?language=objc
     * @see https://developer.apple.com/documentation/avfoundation/avencoderbitratekey?language=objc
     *
     * Possible format values are lpcm, ac-3, cac3, ima4, aac, celp, hvxc,
     * twvq, MAC3, MAC6, ulaw, alaw, QDMC, QDM2, Qclp, .mp1, .mp2, .mp3, time,
     * midi, apvs, alac, aach, aacl, aace, aacf, aacg, aacp, aacs, usac, samr,
     * sawb, AUDB, ilbc, 0x6D730011, 0x6D730031, aes3, ec-3, flac, opus.
     *
     * The possible format values correspond to the character values defined
     * inside CoreAudioTypes/CoreAudioBaseTypes.h
     */
    ExportSettings getAudioExportSettings() const;
    
    /** internal */
    std::string getTrackName (CMPersistentTrackID trackId);
    
private:
    Video (const Configuration& configuration);
    Video (const Video&) = delete;
    Video& operator= (const Video&) = delete;
    
    std::shared_ptr<Context> context;
    std::optional<std::string> error{};
    
    AVComposition* composition = nullptr;
    AVVideoComposition* videoComposition = nullptr;
    AVAudioMix* audioMix = nullptr;
    
    friend class Context;
};
    
} // namespace hypno
