#!/usr/bin/env bash

download_url='https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-standard-3.24.2-x86_64.iso'

response="$(curl -sI "$download_url")"

if ! echo "$response" | grep -q "Via:"; then
    echo "❌ No proxy is set"
    exit 1
fi

if ! echo "$response" | grep -q "X-Cache: HIT"; then
    echo "No cache hit, assuming first request and downloading..."
    curl -L -o /dev/null "$download_url"
fi

if curl -sI "$download_url" | grep -q "X-Cache: HIT"; then
    echo "✅ Cache hit"
    exit 0
else
    echo "❌ No cache hit"
fi
