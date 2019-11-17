//
//  hypno_Configuration.h
//  libhypno
//
//  Created by Jacob Sologub on 8/29/19.
//  Copyright © 2019 Hold Still Inc. All rights reserved.
//

#pragma once

#include <string>
#include <vector>

namespace hypno {
/**
 * Represents a hypno configuration.
 */
struct Configuration {
    
    using path = std::string;
    
    /**
     * The path to the JavaScript file to execute.
     *
     * @see https://jacobsologub.s3.amazonaws.com/hypno/docs/modules/_hypno_.hypno.html#argv
     */
    path script;
    
    /**
     * A list of paths to "dynamic" camera assets.
     *
     * @see https://jacobsologub.s3.amazonaws.com/hypno/docs/modules/_hypno_.hypno.html#argv
     */
    std::vector<path> cameraAssets;
    
    /**
     * A list of additional paths to static assets, i.e. overlay videos, images
     * etc.
     *
     * @see https://jacobsologub.s3.amazonaws.com/hypno/docs/modules/_hypno_.hypno.html#argv
     */
    std::vector<path> otherAssets;
};
    
} // namespace hypno
