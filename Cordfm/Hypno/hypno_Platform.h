//
//  hypno_Platform.h
//  libhypno
//
//  Created by Jacob Sologub on 8/29/19.
//  Copyright © 2019 Hold Still Inc. All rights reserved.
//

#pragma once

#include <memory>
#include <functional>
#include <string_view>

namespace spdlog {
class logger;
}

namespace hypno {
namespace version {

constexpr auto major = 1;
constexpr auto minor = 0;
constexpr auto patch = 0;

constexpr unsigned int get();

} // namespace version
    
/**
 * Represents a hypno Platform instance.
 */
class Platform {
public:
    /** Destructor */
    ~Platform();
    
    /**
     * Initializes the Platform.
     *
     * This method should be called somewhere in the beginning of your
     * application's run loop before interacting with the hypno library.
     */
    static void initialize();
    
    /**
     * Shuts down the Platform.
     *
     * This method should be called right before your application terminates.
     */
    static void shutdown();
    
    /**
     * The name for the system logger.
     */
    static constexpr auto system_logger_name = "hypno";
    
    /**
     * The name for the console logger.
     */
    static constexpr auto console_logger_name = "console";
    
    /**
     * You can assign a lambda to this callback object to have it called when
     * there's a new system log.
     */
    std::function<void (std::string_view message)> onSystemLog;

    /**
     * You can assign a lambda to this callback object to have it called when
     * there's a new console log.
    */
    std::function<void (std::string_view message)> onConsoleLog;
    
    /**
     * Returns the system logger.
     *
     * @see https://github.com/gabime/spdlog
     */
    std::shared_ptr<spdlog::logger> system_logger();
    
    /**
     * Returns the console logger.
     *
     * @see https://github.com/gabime/spdlog
     */
    std::shared_ptr<spdlog::logger> console_logger();
    
    /**
     * Returns the Platform instance.
     */
    static Platform* instance();
    
    /**
     * Returns the current version of libhypno
     */
    static std::string getVersion();
    
private:
    Platform();
    
    struct Pimpl;
    friend struct Pimpl;
    friend class Sink;
};
    
} // namespace hypno
