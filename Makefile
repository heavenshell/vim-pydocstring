.PHONY: install
install:
	bash lib/install.sh

.PHONY: clean
clean:
	rm -rf lib/venv lib/doq
