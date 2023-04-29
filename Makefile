TARGET=flp22-log
SOURCE=main.pl
TESTRUN=tests/run.sh

.PHONY: all pack test

all:
	swipl -t halt -q -g start -o $(TARGET) -c $(SOURCE)

test:
	$(MAKE)
	chmod +x ./$(TESTRUN)
	./$(TESTRUN)

pack:
	zip -r flp-log-xfiala61.zip Makefile main.pl README.md tests/
