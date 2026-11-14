# The OmniGen2 and EditScore guest: a riscv64 godot-sandbox ELF whose body is Lean.
#
#   cmake -S guest -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_TOOLCHAIN_FILE=<ws>/5-repository/riscv64-sysroot/toolchain.cmake \
#     -DGUEST_RUNTIME_ROOT=<ws>/2-contract/guest-runtime \
#     -DLEAN_GUEST_DIR=<ws>/3-interactor/lean-guest
#   cmake --build build --target omnigen2
#   cp build/omnigen2 build/omnigen2.elf
#
# SPDX-License-Identifier: MIT
cmake_minimum_required(VERSION 3.20)
project(omnigen2_guest C CXX)
set(GUEST_RUNTIME_ROOT "" CACHE PATH "contract-guest-runtime checkout")
set(LEAN_GUEST_DIR "" CACHE PATH "interactor-lean-guest checkout")
if(NOT GUEST_RUNTIME_ROOT OR NOT LEAN_GUEST_DIR)
  message(FATAL_ERROR "pass -DGUEST_RUNTIME_ROOT=<contract-guest-runtime> and -DLEAN_GUEST_DIR=<interactor-lean-guest>")
endif()
# --strip-debug, never -s: the host resolves every guest function through .symtab.
set(STRIPPED ON CACHE BOOL "" FORCE)
set(GUEST_ROOT ${CMAKE_CURRENT_LIST_DIR}/..)
# The Lean release is pinned in interactor-lean-guest's own CMakeLists.txt. Read it from there and
# refuse a toolchain that disagrees: the emitted C and the runtime must be the same release.
file(STRINGS ${LEAN_GUEST_DIR}/CMakeLists.txt _lean_guest_pins REGEX "^set\\((LEAN|LIBUV)_VERSION ")
foreach(_pin IN LISTS _lean_guest_pins)
  string(REGEX MATCH "set\\(([A-Z]+)_VERSION \"([^\"]+)\"" _match "${_pin}")
  set(${CMAKE_MATCH_1}_VERSION "${CMAKE_MATCH_2}" CACHE STRING "")
endforeach()
file(STRINGS ${GUEST_ROOT}/lean-toolchain _toolchain)
string(REGEX REPLACE "^leanprover/lean4:v" "" _guest_lean "${_toolchain}")
if(NOT _guest_lean STREQUAL LEAN_VERSION)
  message(FATAL_ERROR
    "the lean-toolchain is ${_guest_lean} and the guest runtime is ${LEAN_VERSION}; they must be the same release")
endif()

include(${GUEST_RUNTIME_ROOT}/cmake/guest_runtime.cmake)
include(${LEAN_GUEST_DIR}/cmake/lean_guest.cmake)

set(GUEST_MODULES Omnigen2.Guest Omnigen2.MulMat)
file(GLOB_RECURSE GUEST_LEAN ${GUEST_ROOT}/*.lean)
list(FILTER GUEST_LEAN EXCLUDE REGEX "/\\.lake/")

set(GUEST_C)
foreach(_m IN LISTS GUEST_MODULES)
  string(REPLACE "." "/" _path ${_m})
  list(APPEND GUEST_C ${GUEST_ROOT}/.lake/build/ir/${_path}.c)
endforeach()

add_custom_command(OUTPUT ${GUEST_C}
  COMMAND ${LAKE_EXE} build Omnigen2.Guest:c omnigen2_witness
  WORKING_DIRECTORY ${GUEST_ROOT}
  DEPENDS ${GUEST_LEAN}
  VERBATIM)

add_sandbox_program(omnigen2 ${CMAKE_CURRENT_LIST_DIR}/main.cpp ${GUEST_C})
target_compile_features(omnigen2 PRIVATE cxx_std_23)
target_link_libraries(omnigen2 PRIVATE leaninit_guest pthread)
target_compile_options(omnigen2 PRIVATE -ffunction-sections -fdata-sections)
target_link_options(omnigen2 PRIVATE -Wl,--gc-sections)
