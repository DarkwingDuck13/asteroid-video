cmake_minimum_required(VERSION 3.16)
project(asteroid-video LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Multimedia)

set(SOURCES
    src/main.cpp
    src/resources.qrc
)

add_executable(asteroid-video ${SOURCES})

target_link_libraries(asteroid-video PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Multimedia
)

install(TARGETS asteroid-video RUNTIME DESTINATION bin)
install(FILES asteroid-video.desktop DESTINATION share/applications)
