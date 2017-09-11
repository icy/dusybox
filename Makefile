TOOLS = jq plotbar watch free

default:
	@echo "Empty section."

tests:
	@for _t in $(TOOLS); do \
		echo >&2 "::" ; \
		echo >&2 ":: Testing $$_t..." ; \
		echo >&2 "::" ; \
		dub test -d 2 dusybox:$$_t || break ; \
	done
