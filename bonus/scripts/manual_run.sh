#!/bin/sh
set -euo pipefail

sh ./50_app_chart.sh
sh ./60_port_forward.sh
