# race_coach — development commands
#
# Usage:
#   make gen         — regenerate ALL codegen outputs (proto + FRB)
#   make gen-check   — verify all generated code is fresh
#   make proto       — regenerate proto types (Dart + Rust)
#   make frb         — regenerate flutter_rust_bridge bindings
#   make rust-test   — run Rust tests
#   make analyze     — run Flutter analyze
#   make check       — cargo check + flutter analyze

# Path to proto2type binary (built from ../proto2type)
PROTO2TYPE_BIN ?= $(shell which protoc-gen-proto2type 2>/dev/null || echo "../proto2type/protoc-gen-proto2type")
GENERATED_RS_DIR := rust/src/generated/racecoach/v1

# Directories containing generated code (for freshness checks)
GENERATED_DIRS := lib/generated/ lib/src/rust/ rust/src/generated/ lib/features/session/data/db/

.PHONY: gen gen-check proto proto-clean proto-gen proto-fixup frb db \
        rust-test rust-check analyze check version-check

# ─── Unified codegen ──────────────────────────────────────────────────

## Regenerate ALL codegen outputs in correct order
gen: proto frb db
	@echo "✅ All codegen complete"

## Verify all generated code is fresh (CI + pre-push)
gen-check: gen
	@if [ -n "$$(git status --porcelain -- $(GENERATED_DIRS))" ]; then \
		echo "ERROR: Generated code is stale. Run 'make gen' and commit."; \
		git status --short -- $(GENERATED_DIRS); \
		git checkout -- $(GENERATED_DIRS); \
		git clean -fd -- $(GENERATED_DIRS); \
		exit 1; \
	fi
	@echo "✅ All generated code is fresh"

## Validate local tool versions match VERSIONS file
version-check:
	@echo "Checking tool versions..."
	@. ./VERSIONS && \
	  buf_actual=$$(buf --version 2>/dev/null) && \
	  frb_actual=$$(flutter_rust_bridge_codegen --version 2>/dev/null | awk '{print $$NF}') && \
	  dart_actual=$$(dart --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
	  protoc_actual=$$(protoc --version 2>/dev/null | awk '{print $$2}') && \
	  rustc_actual=$$(rustc --version 2>/dev/null | awk '{print $$2}') && \
	  ok=1 && \
	  if [ "$$buf_actual" != "$$BUF_VERSION" ]; then echo "  ⚠ buf: expected $$BUF_VERSION, got $$buf_actual"; ok=0; fi && \
	  if [ "$$frb_actual" != "$$FRB_VERSION" ]; then echo "  ⚠ FRB: expected $$FRB_VERSION, got $$frb_actual"; ok=0; fi && \
	  if [ "$$dart_actual" != "$$DART_SDK" ]; then echo "  ⚠ Dart: expected $$DART_SDK, got $$dart_actual"; ok=0; fi && \
	  if [ "$$protoc_actual" != "$$PROTOC_VERSION" ]; then echo "  ⚠ protoc: expected $$PROTOC_VERSION, got $$protoc_actual"; ok=0; fi && \
	  if [ "$$rustc_actual" != "$$RUSTC" ]; then echo "  ⚠ rustc: expected $$RUSTC, got $$rustc_actual"; ok=0; fi && \
	  if [ "$$ok" = "1" ]; then echo "  ✅ All versions match"; fi

# ─── Proto generation ─────────────────────────────────────────────────

## Generate all proto outputs (Dart + Rust)
proto: proto-clean proto-gen proto-fixup
	@echo "✅ Proto generation complete"

## Delete generated Rust proto files (preserves mod.rs)
proto-clean:
	@rm -f $(GENERATED_RS_DIR)/*.type.rs
	@echo "  cleaned $(GENERATED_RS_DIR)/*.type.rs"

## Run buf generate (requires protoc-gen-proto2type in PATH)
proto-gen:
	@echo "  running buf generate..."
	@PATH="$$(dirname $(PROTO2TYPE_BIN)):$$PATH" buf generate
	@echo "  generated files:"
	@ls $(GENERATED_RS_DIR)/*.type.rs 2>/dev/null | sed 's/^/    /'

## Strip duplicate use-lines from generated .type.rs files
## (they're already declared in v1/mod.rs which uses include!())
proto-fixup:
	@echo "  stripping duplicate imports from generated files..."
	@for f in $(GENERATED_RS_DIR)/*.type.rs; do \
		sed -i '' \
			-e '/^use serde::/d' \
			-e '/^use chrono::/d' \
			-e '/^use std::collections::/d' \
			"$$f"; \
	done
	@echo "  ✅ fixup complete"

# ─── Flutter Rust Bridge ──────────────────────────────────────────────

## Regenerate flutter_rust_bridge bindings
frb:
	flutter_rust_bridge_codegen generate
	@echo "✅ FRB codegen complete"

# ─── Drift Database ───────────────────────────────────────────────────

## Regenerate Drift database code
db:
	dart run build_runner build --delete-conflicting-outputs
	@echo "✅ Drift codegen complete"

# ─── Rust ─────────────────────────────────────────────────────────────

## Run Rust tests
rust-test:
	cd rust && cargo test

## Cargo check (type checking only, fast)
rust-check:
	cd rust && cargo check

# ─── Flutter ──────────────────────────────────────────────────────────

## Flutter analyze
analyze:
	flutter analyze

# ─── Combined ────────────────────────────────────────────────────────

## Full check: cargo check + flutter analyze
check: rust-check analyze
	@echo "✅ All checks passed"

## Full proto + FRB pipeline (alias for gen)
proto-all: gen
