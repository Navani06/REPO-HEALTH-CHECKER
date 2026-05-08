#!/usr/bin/env bash

# ============================================================
# Repo Health Checker — Validation Script
# ============================================================
# This script performs automated quality checks on the
# repository. It is designed to be run by GitHub Actions
# during Push and Pull Request events.

set -e

# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

# ──────────────────────────────────────────────────────────
# Helper Functions
# ──────────────────────────────────────────────────────────

# Timestamped logs
log() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_header() {
  echo ""
  echo -e "${YELLOW}============================================${NC}"
  echo -e "${YELLOW}  🏥 Repo Health Checker${NC}"
  echo -e "${YELLOW}============================================${NC}"
  echo ""
}

print_pass() {
  log "${GREEN}✅ PASS: $1${NC}"
}

print_fail() {
  log "${RED}❌ FAIL: $1${NC}"
}

print_section() {
  echo ""
  echo -e "${BLUE}--------------------------------------------${NC}"
  echo -e "${BLUE}  🔍 CHECK: $1${NC}"
  echo -e "${BLUE}--------------------------------------------${NC}"
}

# ──────────────────────────────────────────────────────────
# Validation Functions
# ──────────────────────────────────────────────────────────

check_readme() {
  print_section "README Validation"
  
  if [ ! -f "README.md" ]; then
    print_fail "README.md does not exist."
    print_fail "Every project needs a README for documentation."
    return 1
  fi
  print_pass "README.md exists."

  local line_count=$(wc -l < "README.md")
  if [ "$line_count" -le 5 ]; then
    print_fail "README.md has only $line_count lines (minimum: 6)."
    print_fail "README should contain meaningful project documentation."
    return 1
  fi
  print_pass "README.md has $line_count lines (above minimum of 5)."
  return 0
}

check_gitignore() {
  print_section ".gitignore Validation"
  
  if [ ! -f ".gitignore" ]; then
    print_fail ".gitignore does not exist."
    print_fail "A .gitignore prevents unnecessary files from entering the repository."
    return 1
  fi
  print_pass ".gitignore exists."
  return 0
}

check_no_secrets() {
  print_section "Secret File Detection"
  
  # Search for sensitive files, excluding .git folder
  local secret_files=$(find . -type f \( -name ".env*" -o -name "*.pem" -o -name "*.key" -o -name "secrets.txt" \) -not -path "*/\.git/*" || true)

  if [ -n "$secret_files" ]; then
    print_fail "Secret files detected!"
    echo "$secret_files" | while read -r file; do
      echo -e "    ${RED}⚠️  $file${NC}"
    done
    print_fail "Remove secret files to prevent accidental secret leaks."
    return 1
  fi
  print_pass "No secret files (.env, *.pem, *.key, secrets.txt) detected."
  return 0
}

check_commit_message() {
  print_section "Commit Message Validation"
  
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log "${YELLOW}Not inside a git repository, skipping commit message check.${NC}"
    return 0
  fi

  local commit_msg=$(git log -1 --pretty=%s)
  
  if [[ "$commit_msg" == Merge* ]]; then
    print_pass "Merge commit detected, skipping message length validation."
    return 0
  fi

  local word_count=$(echo "$commit_msg" | wc -w)
  log "Latest commit: \"$commit_msg\""
  log "Word count: $word_count"

  if [ "$word_count" -le 5 ]; then
    print_fail "Commit message has only $word_count words (minimum: 6)."
    print_fail "Write meaningful commit messages that describe the change."
    return 1
  fi
  print_pass "Commit message has $word_count words (above minimum of 5)."
  return 0
}

# ──────────────────────────────────────────────────────────
# Main Execution
# ──────────────────────────────────────────────────────────

main() {
  print_header
  
  local all_passed=true
  local fail_count=0
  local pass_count=0

  # Run all checks independently
  if ! check_readme; then
    all_passed=false
    ((fail_count++))
  else
    ((pass_count++))
  fi

  if ! check_gitignore; then
    all_passed=false
    ((fail_count++))
  else
    ((pass_count++))
  fi

  if ! check_no_secrets; then
    all_passed=false
    ((fail_count++))
  else
    ((pass_count++))
  fi

  if ! check_commit_message; then
    all_passed=false
    ((fail_count++))
  else
    ((pass_count++))
  fi

  echo ""
  echo -e "${YELLOW}============================================${NC}"
  echo -e "${YELLOW}  📊 Summary Output${NC}"
  echo -e "${YELLOW}============================================${NC}"
  log "Checks Passed: ${GREEN}$pass_count${NC}"
  log "Checks Failed: ${RED}$fail_count${NC}"

  if [ "$all_passed" = true ]; then
    echo -e "\n${GREEN}🎉 ALL CHECKS PASSED — CI gate successful!${NC}\n"
    exit 0
  else
    echo -e "\n${RED}🚫 CHECKS FAILED — Fix issues to pass the CI gate!${NC}\n"
    exit 1
  fi
}

# Disable set -e for main execution so we can evaluate all checks
set +e
main
