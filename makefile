FRAMEWORK_PATH = -F/System/Library/PrivateFrameworks
FRAMEWORK      = -framework Carbon -framework Cocoa -framework CoreServices -framework SkyLight -framework ScriptingBridge -framework IOKit
BUILD_FLAGS    = -std=c99 -Wall -DNDEBUG -O2 -fvisibility=hidden -mmacosx-version-min=10.13
BUILD_PATH     = ./bin
DOC_PATH       = ./doc
SCRIPT_PATH    = ./scripts
ASSET_PATH     = ./assets
SMP_PATH       = ./examples
ARCH_PATH      = ./archive
SPACEBAR_SRC      = ./src/manifest.m
BINS           = $(BUILD_PATH)/spacebar

.PHONY: all clean install sign archive man

all: clean $(BINS)

#install: BUILD_FLAGS=-std=c99 -Wall -DNDEBUG -O2 -fvisibility=hidden -mmacosx-version-min=10.13
#install: clean $(BINS)

install: sign
	cp $(BUILD_PATH)/spacebar /usr/local/bin/spacebar
	cp $(SCRIPT_PATH)/spacebar.plist ~/Library/LaunchAgents/spacebar.plist
	launchctl bootstrap gui/501 ~/Library/LaunchAgents/spacebar.plist

stats: BUILD_FLAGS=-std=c99 -Wall -DSTATS -DNDEBUG -O2 -fvisibility=hidden -mmacosx-version-min=10.13
stats: clean $(BINS)

man:
	asciidoctor -b manpage $(DOC_PATH)/spacebar.asciidoc -o $(DOC_PATH)/spacebar.1

icon:
	python $(SCRIPT_PATH)/seticon.py $(ASSET_PATH)/icon/2x/icon-512px@2x.png $(BUILD_PATH)/spacebar

archive: man install sign icon
	rm -rf $(ARCH_PATH)
	mkdir -p $(ARCH_PATH)
	cp -r $(BUILD_PATH) $(ARCH_PATH)/
	cp -r $(DOC_PATH) $(ARCH_PATH)/
	cp -r $(SMP_PATH) $(ARCH_PATH)/
	tar -cvzf $(BUILD_PATH)/$(shell $(BUILD_PATH)/spacebar --version).tar.gz $(ARCH_PATH)
	rm -rf $(ARCH_PATH)

sign:
	codesign -fs "spacebar" $(BUILD_PATH)/spacebar

clean:
	rm -rf $(BUILD_PATH)

$(BUILD_PATH)/spacebar: $(SPACEBAR_SRC)
	mkdir -p $(BUILD_PATH)
	clang $^ $(BUILD_FLAGS) $(FRAMEWORK_PATH) $(FRAMEWORK) -o $@
