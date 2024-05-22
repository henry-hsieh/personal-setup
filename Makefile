SRC_DIR = $(CURDIR)/src
BUILD_DIR = $(CURDIR)/build
LOG_DIR = $(BUILD_DIR)/logs
TEST_SRC_DIR = $(CURDIR)/tests
TEST_DIR = $(BUILD_DIR)/test
TEST_HOME = $(TEST_DIR)/home
OUT = $(BUILD_DIR)/personal-setup.tar.gz
EXCLUDES += .cache .npm .bash_history .tcsh_history nvim/telescope_history .local/state tinty/current_scheme rustup/downloads rustup/tmp cargo/git cargo/credentials
TAR_EXCLUDES := $(addprefix --exclude=',$(addsuffix ', $(EXCLUDES)))

.PHONY: all build release test clean

all: release

build: $(CURDIR)/build/personal-setup/build_home

$(CURDIR)/build/personal-setup/build_home:
	docker run --user $(shell id -u):$(shell id -g) -v $(CURDIR):$(CURDIR) -w $(CURDIR) personal-setup ./src/build.sh
	docker run --user $(shell id -u):$(shell id -g) -v $(CURDIR):$(CURDIR) -w $(CURDIR) -e HOME=$(CURDIR)/build/personal-setup/build_home personal-setup bash -i -c './src/init.sh'

build_docker:
	docker build -t personal-setup $(SRC_DIR)

$(OUT): $(CURDIR)/build/personal-setup/build_home
	cd $(BUILD_DIR)/personal-setup && \
	tar -czf home.tar.gz $(TAR_EXCLUDES) build_home --transform='s/build_home/./'
	cd $(BUILD_DIR) && \
	tar -czf $(notdir $@) --exclude='build_home' personal-setup

release: $(OUT)

test:
	mkdir -p $(TEST_DIR) $(LOG_DIR)
	tar -axf $(OUT) -C $(TEST_DIR)
	rm -rf $(TEST_HOME)
	@echo "Installing environment..."
	$(TEST_DIR)/personal-setup/install.sh $(TEST_HOME) > $(LOG_DIR)/install.log
	cp -r $(TEST_SRC_DIR) $(TEST_HOME)
	cd $(TEST_HOME) && \
	HOME=$(TEST_HOME) bash -i -c "pytest --symlink --kwdof --wt 16 --basetemp $(LOG_DIR)"

build_test_docker:
	docker build -t pytest-workflow $(TEST_SRC_DIR)

clean:
	rm -rf $(BUILD_DIR)
