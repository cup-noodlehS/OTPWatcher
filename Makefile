.PHONY: build run clean test zip

APP_NAME = OTPWatcher
BUILD_DIR = build
DERIVED_DATA = $(BUILD_DIR)/DerivedData
APP_PATH = $(DERIVED_DATA)/Build/Products/Debug/$(APP_NAME).app

build:
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(APP_NAME) \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA) \
		build

release:
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(APP_NAME) \
		-configuration Release \
		-derivedDataPath $(DERIVED_DATA) \
		ARCHS="arm64 x86_64" \
		ONLY_ACTIVE_ARCH=NO \
		build

run: build
	open $(APP_PATH)

test:
	xcodebuild test -project $(APP_NAME).xcodeproj \
		-scheme $(APP_NAME) \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA)

zip: release
	cd $(DERIVED_DATA)/Build/Products/Release && \
		zip -r ../../../../$(APP_NAME).zip $(APP_NAME).app
	@echo "Created $(APP_NAME).zip"

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(APP_NAME).zip
