# race_coach — development commands
#
# Usage:
#   make proto       — regenerate proto types (Dart + Rust)
#   make rust-test   — run Rust tests
#   make analyze     — run Flutter analyze
#   make check       — cargo check + flutter analyze
#   make frb         — regenerate flutter_rust_bridge bindings

# Path to proto2type binary (built from ../proto2type)
PROTO2TYPE_BIN ?= $(shell which protoc-gen-proto2type 2>/dev/null || echo "../proto2type/protoc-gen-proto2type")
GENERATED_RS_DIR := rust/src/generated/racecoach/v1

.PHONY: proto proto-rust proto-dart rust-test analyze check frb clean-proto

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

## Regenerate flutter_rust_bridge bindings
frb:
	flutter_rust_bridge_codegen generate
	@echo "✅ FRB codegen complete"

# ─── Combined ────────────────────────────────────────────────────────

## Full check: cargo check + flutter analyze
check: rust-check analyze
	@echo "✅ All checks passed"

## Full proto + FRB pipeline: regenerate protos, then FRB bindings
proto-all: proto frb
	@echo "✅ Proto + FRB pipeline complete"
