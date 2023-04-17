TARGET=flp22-log
SOURCE=main.pl

.PHONY: all, pack

all:
	swipl -q -g start -o $(TARGET) -c $(SOURCE)

pack:
	zip flp-log-xfiala61.zip Makefile main.pl README.md
