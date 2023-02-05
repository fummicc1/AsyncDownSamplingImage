#!/bin/sh

swift package --allow-writing-to-directory docs \
    generate-documentation --target AsyncDownSamplingImage \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path AsyncDownSamplingImage \
    --output-path docs
