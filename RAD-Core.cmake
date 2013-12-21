
SET(_this_version "1")
IF(RAD_TOOLS_INCLUDED)
    IF(NOT ${RAD_TOOLS_VERSION} VERSION_EQUAL ${_this_version})
        MESSAGE(FATAL_ERROR "Cannot mix different version of RAD-Tools!")
    ENDIF()
ELSE()
    SET(RAD_TOOLS_INCLUDED TRUE)
    SET(RAD_TOOLS_VERSION ${_this_version})

    INCLUDE(CMakeParseArguments)

    FUNCTION(RAD_ADD_MODULE_DIR dir)
        LIST(APPEND RAD_MODULES ${dir})
        SET(RAD_MODULES CACHE STRING "RAD Module directories" FORCE)
    ENDFUNCTION()

    FUNCTION(_RAD_FIND_DIRS base)
        FILE(GLOB dirs RELATIVE ${CMAKE_SOURCE_DIR} ${base}/* )

        SET(subdirs)

        FOREACH(dir ${dirs})
            IF(IS_DIRECTORY ${CMAKE_SOURCE_DIR}/${dir})
                GET_FILENAME_COMPONENT(basename ${dir} NAME_WE)
                IF("${basename}" STREQUAL "RAD-Tools")
                    IF(${_RAD_INIT_VERBOSE})
                        MESSAGE(STATUS "Found RAD-Tools directory: ${dir}")
                    ENDIF()
                    RAD_ADD_MODULE_DIR(${dir})
                ELSE()
                    LIST(APPEND subdirs ${dir})
                ENDIF()
            ENDIF()
        ENDFOREACH()

        FOREACH(dir ${subdirs})
            _RAD_FIND_DIRS(${base}/${dir})
        ENDFOREACH()
    ENDFUNCTION()

    MACRO(RAD_INIT)
        MESSAGE(STATUS "RAD-Tools (C) 2013 Cunz RAD Ltd.")

        CMAKE_PARSE_ARGUMENTS(
            _RAD_INIT
            "VERBOSE"
            ""
            "FEATURES"
            ${ARGN}
        )

        _RAD_FIND_DIRS(${CMAKE_SOURCE_DIR})

        FOREACH(_feature ${_RAD_INIT_FEATURES})

            LIST(FIND RAD_FEATURES ${_feature} _is_loaded)
            IF(NOT ${_is_loaded} EQUAL -1)
                MESSAGE(STATUS "Already loaded: ${_feature}")
            ELSE()

                IF(${_RAD_INIT_VERBOSE})
                    MESSAGE(STATUS "Loading feature: ${_feature}")
                ENDIF()

                SET(_file cmake/${_feature}.cmake)
                IF(EXISTS ${CMAKE_CURRENT_LIST_DIR}/${_file})

                    INCLUDE(${_file})
                    MESSAGE(STATUS "Loaded: ${_feature}")

                    LIST(APPEND RAD_FEATURES ${_feature})
                ELSE()
                    MESSAGE(FATAL_ERROR "RAD-Tools: Feature ${_feature} not found.")
                ENDIF()
            ENDIF()

        ENDFOREACH()

    ENDMACRO()

ENDIF()
