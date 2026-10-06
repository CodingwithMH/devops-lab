SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help report

all: test ## build and test everything

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "  BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check: ## verify sources exist
	@if [ ! -d "$(SRC_DIR)" ] || [ -z "$(SOURCES)" ]; then \
	  echo "ERROR: no .txt files found in $(SRC_DIR)"; exit 1; \
	fi
	@echo "check: found $(words $(SOURCES)) source file(s) in $(SRC_DIR)"

build: $(OUTPUTS) ## build all outputs

test: build ## build, then check outputs are uppercase
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
	  echo "TEST FAILED: lowercase characters remain"; exit 1; \
	fi
	@echo "TEST PASSED"

clean: ## remove the output directory
	rm -rf $(OUT_DIR)

ci: clean check test ## full pipeline for a build server

report: $(OUT_DIR)/report.txt ## write a summary of all outputs

count: build ## report source files and built words
	@ls -1 $(SRC_DIR)/*.txt | wc -l
	@wc -w $(OUTPUTS) | tail -1
# count: see section 5 of the README
# OUTPUTS is set by the wildcard above
# run 'make help' for all targets
