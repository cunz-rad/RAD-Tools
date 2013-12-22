
SET(_rad_this_version "1")
IF(RAD_CORE_INCLUDED)
    IF(NOT ${RAD_CORE_VERSION} VERSION_EQUAL ${_rad_this_version})
        MESSAGE(FATAL_ERROR "Cannot mix different versions of RAD-Core/Tools!")
    ENDIF()
ELSE()
    SET(RAD_CORE_INCLUDED TRUE)
    SET(RAD_CORE_VERSION ${_rad_this_version})

    INCLUDE(CMakeParseArguments)

    MACRO(RAD_ADD_MODULE_DIR dir)
        LIST(APPEND RAD_CORE_MODULE_DIRS ${dir})
        SET(RAD_CORE_MODULE_DIRS ${RAD_CORE_MODULE_DIRS}
            CACHE STRING "RAD Module directories" FORCE)
    ENDMACRO()

    FUNCTION(_RAD_FIND_DIRS base)
        FILE(GLOB dirs RELATIVE ${CMAKE_SOURCE_DIR} ${base}/* )

        SET(subdirs)

        FOREACH(dir ${dirs})
            IF(IS_DIRECTORY ${CMAKE_SOURCE_DIR}/${dir})
                GET_FILENAME_COMPONENT(basename ${dir} NAME_WE)
                IF("${basename}" STREQUAL "RAD-Tools")
                    IF(${RAD_CORE_VERBOSE})
                        MESSAGE(STATUS "Found RAD-Tools directory in ${dir}")
                    ENDIF()
                    RAD_ADD_MODULE_DIR(${dir})
                ELSE()
                    LIST(APPEND subdirs ${dir})
                ENDIF()
            ENDIF()
        ENDFOREACH()

        FOREACH(dir ${subdirs})
            _RAD_FIND_DIRS(${dir})
        ENDFOREACH()
    ENDFUNCTION()

    FUNCTION(RAD_IS_FEATURE_LOADED feature output)
        LIST(FIND RAD_CORE_LOADED_FEATURES ${feature} is_loaded)
        IF(${is_loaded} EQUAL -1)
            SET(output FALSE PARENT_SCOPE)
        ELSE()
            SET(output TRUE PARENT_SCOPE)
        ENDIF()
    ENDFUNCTION()

    MACRO(RAD_LOAD_FEATURE _feature)
        LIST(FIND RAD_CORE_LOADED_FEATURES ${_feature} _is_loaded)

        SET(_chatty ${RAD_CORE_VERBOSE})
        IF(${ARGC} EQUAL 2)
            IF(${ARGV1} STREQUAL "SILENT")
                SET(_silent TRUE)
                SET(_chatty FALSE)
            ELSEIF(${ARGV1} STREQUAL "VERBOSE")
                SET(_chatty TRUE)
                SET(_silent FALSE)
            ENDIF()
        ELSE()
            SET(_silent FALSE)
        ENDIF()

        IF(NOT ${_is_loaded} EQUAL -1)
            IF(${_chatty})
                MESSAGE(STATUS "Already loaded: ${_feature}")
            ENDIF()
        ELSE()
            SET(_rad_found FALSE)
            FOREACH(_rad_dir ${RAD_CORE_MODULE_DIRS})
                IF(NOT _rad_found)
                    SET(_file ${CMAKE_SOURCE_DIR}/${_rad_dir}/${_feature}.RAD-Tool)
                    IF(EXISTS ${_file})

                        SET(_user_info "RAD-Feature ${_feature}")
                        IF(NOT ${_rad_dir} STREQUAL "RAD-Core/RAD-Tools")
                            SET(_user_info "${_user_info} from ${_rad_dir}")
                        ENDIF()
                        IF(NOT ${CMAKE_SOURCE_DIR} STREQUAL
                               ${CMAKE_CURRENT_SOURCE_DIR})
                            STRING(REPLACE "${CMAKE_SOURCE_DIR}/"
                                           "" _subtree
                                           ${CMAKE_CURRENT_SOURCE_DIR})
                            SET(_user_info "${_user_info} for subtree ${_subtree}")
                        ENDIF()

                        IF(${_chatty})
                            MESSAGE(STATUS "Loading ${_user_info}")
                        ENDIF()

                        SET(RAD_CURRENT_TOOL_DIR ${CMAKE_SOURCE_DIR}/${_rad_dir})
                        SET(RAD_CURRENT_TOOL_SILENT ${_silent})
                        INCLUDE(${_file})
                        UNSET(RAD_CURRENT_TOOL_DIR)
                        UNSET(RAD_CURRENT_TOOL_SILENT)

                        LIST(APPEND RAD_CORE_LOADED_FEATURES ${_feature})
                        SET(_rad_found TRUE)

                        IF(NOT ${_silent})
                            MESSAGE(STATUS "Loaded ${_user_info}")
                        ENDIF()
                    ENDIF()
                ENDIF()
            ENDFOREACH()
            IF(NOT _rad_found)
                MESSAGE(FATAL_ERROR "RAD-Tools: Feature ${_feature} not found.")
            ENDIF()
        ENDIF()
    ENDMACRO()

    MACRO(RAD_INIT)
        CMAKE_PARSE_ARGUMENTS(
            _rad_init
            "VERBOSE"
            ""
            "FEATURES"
            ${ARGN}
        )

        IF(NOT _rad_init_verbose)
            SET(_rad_init_verbose FALSE)
        ENDIF()
        SET(RAD_CORE_VERBOSE ${_rad_init_VERBOSE} CACHE BOOL "RAD should be verbose")
        IF(${RAD_CORE_VERBOSE})
            MESSAGE(STATUS "RAD-Tools (C) 2013 Cunz RAD Ltd.")
            MESSAGE(STATUS "RAD-Tools version is ${RAD_CORE_VERSION}")
        ENDIF()
        _RAD_FIND_DIRS(${CMAKE_SOURCE_DIR})

        FOREACH(_feature ${_rad_init_FEATURES})
            RAD_LOAD_FEATURE(${_feature})
        ENDFOREACH()

    ENDMACRO()

    MACRO(RAD_CORE_ADD_FLAG _var _flag)
        IF(NOT DEFINED ${_var})
            SET(${_var} "${_flag}" CACHE STRING "..." FORCE )
        ENDIF()

        IF(NOT "${${_var}}" MATCHES ".*${_flag}.*")
            SET(${_var} "${${_var}} ${_flag}" CACHE STRING "..." FORCE )
        ENDIF()
    ENDMACRO()
ENDIF()
