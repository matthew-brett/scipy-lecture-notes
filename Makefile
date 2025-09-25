PYTHON ?= python
PIP_INSTALL_CMD ?= $(PYTHON) -m pip install
BUILD_DIR=_build/html
JL_DIR=_build/jl

html:
	# Check for ipynb files in source (should all be .Rmd).
	if compgen -G "*.ipynb" 2> /dev/null; then (echo "ipynb files" && exit 1); fi
	jupyter-book build -W .

jl:
	# Jupyter-lite files for book build.
	$(PIP_INSTALL_CMD) -r jl-build-requirements.txt
	rm -rf $(JL_DIR)
	mkdir $(JL_DIR)
	cp -r data images $(JL_DIR)
	$(PYTHON) _scripts/process_notebooks.py $(JL_DIR)
	$(PYTHON) -m jupyter lite build \
		--contents $(JL_DIR) \
		--output-dir $(BUILD_DIR)/interact \
		--lite-dir $(JL_DIR)

lint:
	pre-commit run --all-files --show-diff-on-failure --color always

web: html jl

github: web
	ghp-import -n _build/html -p -f

clean: rm-ipynb
	rm -rf _build
	find . -name ".ipynb_checkpoints" -exec rm -r {} \;

rm-ipynb:
	rm -rf *.ipynb

test:
	pytest .
