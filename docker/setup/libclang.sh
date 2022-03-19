#!/bin/bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
# source /lib.sh

main() {
  local clang_version
  clang_version="$1"

  local install_dir
  install_dir="$2"

  local td
  td="$(mktemp -d)"

  builtin pushd "${td}"

  wget --quiet https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-$clang_version.tar.gz
  tar -xzf llvmorg-$clang_version.tar.gz --strip-components=1

  builtin cd llvm
  mkdir -p build-release
  builtin cd build-release
  cmake .. -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_PARALLEL_LINK_JOBS=1 -DLLVM_TARGETS_TO_BUILD=X86
  make -j "$(nproc)" install
  builtin cd ../..

  # LLD
  builtin cd lld
  mkdir -p build-release
  builtin cd build-release
  cmake .. -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DCMAKE_BUILD_TYPE=Release -DLLVM_PARALLEL_LINK_JOBS=1 -DCMAKE_CXX_STANDARD=17 -DLLVM_TARGETS_TO_BUILD=X86
  make -j "$(nproc)" install
  builtin cd ../..

  # Clang
  builtin cd clang
  mkdir -p build-release
  builtin cd build-release
  cmake .. -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=$install_dir -DCMAKE_PREFIX_PATH=$install_dir -DCMAKE_BUILD_TYPE=Release -DLLVM_PARALLEL_LINK_JOBS=1 -DLLVM_TARGETS_TO_BUILD=X86
  make -j "$(nproc)" install
  builtin cd ../..

  builtin popd
  rm -rf "${td}"
  rm "${0}"
}

main "${@}"
