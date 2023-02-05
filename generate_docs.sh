#!/bin/sh

swift package --allow-writing-to-directory docs \
    generate-documentation --target AsyncDownSamplingImage \
    --transform-for-static-hosting \
    --hosting-base-path asyncdownsamplingimage \
    --output-path docs
