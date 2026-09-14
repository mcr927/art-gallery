SCHEME ?= ModernGallery
PACKAGE_SCHEME ?= GalleryPackage-Package
PACKAGE_DIR := LocalPackages/GalleryPackage
DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro
PROJECT := ArtGallery.xcodeproj

.PHONY: bootstrap generate open build test clean

bootstrap:
	brew bundle

generate:
	xcodegen generate

open: generate
	open $(PROJECT)

build: generate
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)'

test:
	cd $(PACKAGE_DIR) && xcodebuild test \
		-scheme $(PACKAGE_SCHEME) \
		-destination '$(DESTINATION)' \

clean:
	rm -rf $(PROJECT)
	rm -rf .build
	rm -rf $(PACKAGE_DIR)/.build
	rm -rf ~/Library/Developer/Xcode/DerivedData/ArtGallery-*