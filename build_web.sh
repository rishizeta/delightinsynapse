#!/bin/bash
# Build Flutter web and move output to docs/ for GitHub Pages

set -e

flutter build web
rm -rf docs
mv build/web docs

echo "Web build complete. Output is now in ./docs for GitHub Pages."
