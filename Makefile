SCHEME ?= ModernGallery
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

test: generate
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)'

clean:
	rm -rf $(PROJECT)
	rm -rf .build
	rm -rf ~/Library/Developer/Xcode/DerivedData/ArtGallery-*