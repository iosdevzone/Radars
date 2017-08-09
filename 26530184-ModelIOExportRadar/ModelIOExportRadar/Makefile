DEVICE_ID := $(shell instruments -s devices | grep iPad | grep -v Simulator | awk '{ print $$(NF); }' | sed -E 's/\[([0-9a-z]+)\]/\1/g' )
DESTINATION := 'platform=iOS,id=$(DEVICE_ID)'

test_macOS:
	xcodebuild -scheme ModelIOExporterRadar_macOS test

test_iOS:
	xcodebuild -destination $(DESTINATION) -scheme ModelIOExportRadar test


