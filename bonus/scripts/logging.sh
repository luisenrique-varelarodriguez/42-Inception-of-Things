#!/bin/sh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Main
log() {
    local level="$1"
    local color="$2" 
    local message="$3"
    local timestamp=$(date '+%H:%M:%S')
    
    printf "${color}[${level}]${NC} ${GRAY}${timestamp}${NC} ${message}\n"
}

# Levels
log_info() {
    log "INFO" "${BLUE}" "$1"
}

log_success() {
    log "SUCCESS" "${GREEN}" "$1"
}

log_warning() {
    log "WARN" "${YELLOW}" "$1"
}

log_error() {
    log "ERROR" "${RED}" "$1"
}

# Headers
log_header() {
    local step="$1"
    local title="$2"
    echo
    printf "${BOLD}${CYAN}============================================${NC}\n"
    printf "${BOLD}${CYAN}[${step}] ${title}${NC}\n"
    printf "${BOLD}${CYAN}============================================${NC}\n"
}