#!/usr/bin/env bash

# ============================================================
# Repo Health Checker — Validation Script
# ============================================================
# This script performs automated quality checks on the
# repository. It is designed to be run by GitHub Actions
# during Pull Request reviews.
#
# Checks performed:
#   1. README.md exists and has more than 5 lines
#   2. .gitignore file exists
#   3. No .env files exist (secret leak prevention)
#
# Exit Codes:
#   0 — All checks passed
#   1 — One or more checks failed
# ============================================================

# Exit immediately if any command fails
set -e

# ──────────────────────────────────────────────────────────
# Helper Functions
# ──────────────────────────────────────────────────────────

print_header() {
  echo ""
  echo "============================================"
  echo "  Repo Health Checker"
  echo "============================================"
  echo ""
}

print_pass() {
  echo "  ✅ PASS: $1"
}

print_fail() {
  echo "  ❌ FAIL: $1"
}

print_section() {
  echo ""
  echo "--------------------------------------------"
  echo "  CHECK: $1"
  echo "--------------------------------------------"
}

print_result() {
  echo ""
  echo "============================================"
  echo "  $1"
  echo "============================================"
  echo ""
}

# ──────────────────────────────────────────────────────────
# Validation Functions
# ──────────────────────────────────────────────────────────

check_readme() {
  print_section "README Validation"

  # Check if README.md exists
  if [ ! -f "README.md" ]; then
    print_fail "README.md does not exist"
    print_fail "Every project needs a README for documentation"
    return 1
  fi
  print_pass "README.md exists"

  # Check if README has more than 5 lines
  line_count=$(wc -l < "README.md")
  if [ "$line_count" -le 5 ]; then
    print_fail "README.md has only $line_count lines (minimum: 6)"
    print_fail "README should contain meaningful project documentation"
    return 1
  fi
  print_pass "README.md has $line_count lines (above minimum of 5)"

  return 0
}

check_gitignore() {
  print_section ".gitignore Validation"

  # Check if .gitignore exists
  if [ ! -f ".gitignore" ]; then
    print_fail ".gitignore does not exist"
    print_fail "A .gitignore prevents unnecessary files from entering the repository"
    return 1
  fi
  print_pass ".gitignore exists"

  return 0
}

check_no_secrets() {
  print_section "Secret File Detection"

  # Search for any .env files in the repository
  env_files=$(find . -name "*.env" -o -name ".env" -o -name ".env.*" | grep -v ".git/" || true)

  if [ -n "$env_files" ]; then
    print_fail "Secret files detected!"
    echo ""
    echo "  The following .env files were found:"
    echo "$env_files" | while read -r file; do
      echo "    ⚠️  $file"
    done
    echo ""
    print_fail "Remove .env files to prevent accidental secret leaks"
    return 1
  fi
  print_pass "No .env files detected"

  return 0
}

check_commit_message() {
  print_section "Commit Message Validation"

  # Get the latest commit message
  commit_msg=$(git log -1 --pretty=%s)

  # Skip validation for merge commits (common in GitHub Actions PR checkouts)
  if [[ "$commit_msg" == Merge* ]]; then
    print_pass "Merge commit detected, skipping message length validation"
    return 0
  fi

  word_count=$(echo "$commit_msg" | wc -w)

  echo "  Latest commit: \"$commit_msg\""
  echo "  Word count: $word_count"

  if [ "$word_count" -le 5 ]; then
    print_fail "Commit message has only $word_count words (minimum: 6)"
    print_fail "Write meaningful commit messages that describe the change"
    return 1
  fi
  print_pass "Commit message has $word_count words (above minimum of 5)"

  return 0
}

# ──────────────────────────────────────────────────────────
# Main Execution
# ──────────────────────────────────────────────────────────

main() {
  print_header

  # Track overall result
  all_passed=true

  # Run each check — if any fails, mark overall as failed
  if ! check_readme; then
    all_passed=false
  fi

  if ! check_gitignore; then
    all_passed=false
  fi

  if ! check_no_secrets; then
    all_passed=false
  fi

  if ! check_commit_message; then
    all_passed=false
  fi

  # Final result
  if [ "$all_passed" = true ]; then
    print_result "🎉 ALL CHECKS PASSED — PR is safe to merge!"
    exit 0
  else
    print_result "🚫 CHECKS FAILED — Fix issues before merging!"
    exit 1
  fi
}

# Disable set -e for main so we can track individual failures
set +e
main
