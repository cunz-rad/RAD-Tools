
PROJECT(RAD_TOOLS C)
CMAKE_MINIMUM_REQUIRED(VERSION 3.1)

CMAKE_POLICY(SET CMP0043 NEW)
CMAKE_POLICY(SET CMP0054 NEW)

SET(BASE lib/cmake/RAD-Tools)

SET(BASEFILE ${CMAKE_INSTALL_PREFIX}/${BASE}/RAD-Core.cmake)
SET(BASEDIR ${CMAKE_INSTALL_PREFIX}/${BASE}/RAD-Tools)

CONFIGURE_FILE(
    rad-tools-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/rad-tools-config.cmake
    @ONLY
)

FILE(GLOB ToolFiles RAD-Tools/*)

INSTALL(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/rad-tools-config.cmake
        RAD-Core.cmake
    DESTINATION
        ${BASE}
)

INSTALL(
    FILES
        ${ToolFiles}
    DESTINATION
        ${BASE}/RAD-Tools
)
