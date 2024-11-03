#!/bin/bash
# usage: build [version] [stack]
set -e

version=$1
stack=$2
build=$(mktemp -d)

tar -C "$build" --strip-components=1 -xz -f /wrk/src/gperftools-"$version".tar.gz

cd "$build"
./configure --enable-minimal --disable-debugalloc --prefix="$HOME"/vendor/tcmalloc/

# Build and install the libraries only
make install-libLTLIBRARIES

# Include the license with the bundle
cp COPYING "$HOME"/vendor/tcmalloc/

# Custom tcmalloc.sh for enabling tcmalloc on a per dyno basis
mkdir -p "$HOME"/vendor/tcmalloc/bin
cp /wrk/tcmalloc.sh "$HOME"/vendor/tcmalloc/bin
chmod 0555 "$HOME"/vendor/tcmalloc/bin/tcmalloc.sh

# Bundle and compress the compiled library
mkdir -p /wrk/dist/"$stack"
tar -C "$HOME"/vendor/tcmalloc -c . | bzip2 -9 > /wrk/dist/"$stack"/tcmalloc-"$version".tar.bz2
