#!/usr/bin/env bash
set -euo pipefail

red=$(tput setaf 1 2>/dev/null || true)
none=$(tput sgr0 2>/dev/null || true)

show_help() {
  printf "usage: %s [--help] [--report] [--test]\nScript for running Flutter unit and widget tests with code coverage.\n(run from root of repo)\nwhere:\n    -t, --test\n        runs all tests with coverage, but no HTML report\n    -r, -c, --report\n        generate a coverage report\n        (requires lcov, install with Homebrew)\n    -h, --help\n        print this message\n" "$0"
}

run_tests() {
  if [[ -f "pubspec.yaml" ]]; then
    rm -f coverage/lcov.info
    rm -f coverage/lcov-final.info
    flutter test --coverage
  else
    printf "\n%sError: this is not a Flutter project%s\n" "$red" "$none"
    exit 1
  fi
}

run_report() {
  if [[ ! -f "coverage/lcov.info" ]]; then
    printf "\n%sError: no coverage info was generated%s\n" "$red" "$none"
    exit 1
  fi

  if ! command -v lcov >/dev/null 2>&1 || ! command -v genhtml >/dev/null 2>&1; then
    printf "\n%sError: lcov and genhtml are required to generate the HTML report%s\n" "$red" "$none"
    printf "Install with: brew install lcov\n"
    exit 1
  fi

  lcov -r coverage/lcov.info '*/__test*__/*' -o coverage/lcov_cleaned.info
  genhtml -o coverage coverage/lcov_cleaned.info

  if command -v open >/dev/null 2>&1; then
    open coverage/index-sort-l.html
  fi
}

case "${1:-}" in
  -h | --help)
    show_help
    ;;
  -t | --test)
    run_tests
    ;;
  -r | -c | --report)
    run_report
    ;;
  *)
    run_tests
    run_report
    ;;
esac
