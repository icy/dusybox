TOOLS ?= \
	plot \
	jq \
	plotbar \
	watch \
	free

default:
	@echo "Empty section."

.PHONY: tests
tests:
	@for _t in $(TOOLS); do \
		echo >&2 "::" ; \
		echo >&2 ":: Testing $$_t..." ; \
		echo >&2 "::" ; \
		dub test -d 2 dusybox:$$_t || exit 1 ; \
	done

.PHONY: releases
releases: tests
	@for _t in $(TOOLS); do \
		echo >&2 "::" ; \
		echo >&2 ":: Building $$_t..." ; \
		echo >&2 "::" ; \
		dub build --build release dusybox:$$_t || exit 1 ; \
	done
