TOOLS ?= \
	plot \
	jq \
	plotbar \
	watch \
	free \
	jenkins-jobs \
	bash_builtin_hello

default:
	@echo "Empty section."

.PHONY: tests
tests:
	@for _t in $(TOOLS); do \
		if [[ "$$_t" == "jenkins-jobs" ]]; then \
			echo >&2 ":: $$_t requires manual tests with a running Jenkins instance." ; \
			continue ; \
		fi ; \
		echo >&2 "::" ; \
		echo >&2 ":: Testing $$_t..." ; \
		echo >&2 "::" ; \
		dub test -d 2 dusybox:$$_t || exit 1 ; \
	done

.PHONY: releases
releases:
	@mkdir -pv ./bin/
	@for _t in $(TOOLS); do \
		echo >&2 "::" ; \
		echo >&2 ":: Building $$_t..." ; \
		echo >&2 "::" ; \
		dub build --build release dusybox:$$_t || exit 1 ; \
	done

.PHONY: smoke-tests
smoke-tests:
	@for _t in $(TOOLS); do \
		if [ -f "smoke_tests/$$_t.sh" ]; then \
			echo >&2 ":: Smoke-test $$_t..." ; \
			./smoke_tests/$$_t.sh || exit 1; \
			echo >&2 ":: (Passed) Smoke-test $$_t" ; \
		fi ; \
	done

.PHONY: travis
travis: tests releases smoke-tests

.PHONY: clean
clean:
	@rm -fv dusybox-*-application dusybox-*-library *.lst *.a output/*.*
