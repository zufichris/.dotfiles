#!/usr/bin/env bash
# Name of the default-route interface (for EWW_NET indexing); "lo" fallback.
ip route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "dev") {print $(i + 1); exit}}' | grep . || echo lo
