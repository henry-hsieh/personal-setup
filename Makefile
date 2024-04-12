SRC_DIR = $(CURDIR)/src
BUILD_DIR = $(CURDIR)/build
LOG_DIR = $(BUILD_DIR)/logs
TEST_SRC_DIR = $(CURDIR)/tests
TEST_DIR = $(BUILD_DIR)/test
TEST_HOME = $(TEST_DIR)/home
OUT = $(BUILD_DIR)/personal-setup.tar.gz
EXCLUDES += .cache .npm .base16_theme .bash_history .tcsh_history
TAR_EXCLUDES := $(addprefix --exclude=',$(addsuffix ', $(EXCLUDES)))

.PHONY: all release test clean

all: build

build: _build_docker
	mkdir -p $(LOG_DIR)
	docker run --user $(shell id -u):$(shell id -g) -v $(CURDIR):/setup -w /setup personal-setup bash -c "HOME=/setup/build ./src/build.sh >build/logs/build.log 2> >(tee build/logs/build_err.log >&2)"
	docker run --user $(shell id -u):$(shell id -g) -v $(CURDIR):/setup -w /setup personal-setup bash -c 'HOME=/setup/build/personal-setup/build_home PATH=$$PATH:/setup/build/personal-setup/build_home/.local/bin exec ./src/init.sh 2>&1 | tee build/logs/init.log'

_build_docker:
	docker build -t personal-setup $(SRC_DIR)

$(OUT): build
	cd $(BUILD_DIR)/personal-setup && \
	tar -czvf home.tar.gz $(TAR_EXCLUDES) build_home --transform='s/build_home/./' > $(LOG_DIR)/tar.log
	cd $(BUILD_DIR) && \
	tar -czvf $(notdir $@) --exclude='build_home' personal-setup | tee -a $(LOG_DIR)/tar.log

release: $(OUT)

test: $(OUT) _build_test_docker
	mkdir -p $(TEST_DIR)
	tar -axvf $< -C $(TEST_DIR) > $(LOG_DIR)/untar.log
	rm -rf $(TEST_HOME)
	@echo "Installing environment..."
	$(TEST_DIR)/personal-setup/install.sh $(TEST_HOME) > $(LOG_DIR)/install.log
	/usr/bin/cp -r $(TEST_SRC_DIR) $(TEST_HOME)
	docker run --user $(shell id -u):$(shell id -g) -e HOME=/home -v $(TEST_HOME):/home -v $(LOG_DIR):/log -w /home pytest-workflow bash -i -c "pytest --symlink --kwdof --wt 16 --basetemp '/log/'"

_build_test_docker:
	docker build -t pytest-workflow $(TEST_SRC_DIR)

clean:
	rm -rf $(BUILD_DIR)

