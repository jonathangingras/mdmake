# Main Makefile

SRC=$(wildcard *.md)

# build directory can be overriden, $PWD by default
ifndef BUILD_DIR
    BUILD_DIR=.
endif

# default LaTeX compiler
ifndef LATEX
	LATEX=pdflatex
endif

# default beamer theme
ifndef BEAMER_THEME
	BEAMER_THEME=metropolis
endif

# default html CSS style link
ifndef NO_HTML_STYLE
	ifndef HTML_STYLE_URL
		HTML_STYLE_URL='https://gist.githubusercontent.com/killercup/5917178/raw/40840de5352083adb2693dc742e9f75dbb18650f/pandoc.css'
	endif
endif

# append HTML header resources if not provided no resource
ifndef NO_HTML_RES
	HTML_RES := $(HTML_RES) mathjax.html.htmlresource
endif

# append LaTeX header resources if not provided no resource
ifndef NO_TEX_RES
	TEX_RES := $(TEX_RES) physics.tex.texresource math_operators.tex.texresource
endif


all: help

.PHONY: clean help dependencies


html: $(BUILD_DIR) $(patsubst %.md, $(BUILD_DIR)/%.html, $(SRC))
word: $(BUILD_DIR) $(patsubst %.md, $(BUILD_DIR)/%.docx, $(SRC))
pdf: $(BUILD_DIR) $(patsubst %.md, $(BUILD_DIR)/%.doc.pdf, $(SRC))
slides: $(BUILD_DIR) $(patsubst %.md, $(BUILD_DIR)/%.slides.pdf, $(SRC))


$(BUILD_DIR)/%.html: %.md HTML_STYLE.css.html $(HTML_RES)
	cat $(filter-out $<,$^) > $@.header
	pandoc -s -N -o $@ $< -H $@.header
	rm $@.header


$(BUILD_DIR)/%.docx: %.md
	pandoc -s -N -o $@ $<


$(BUILD_DIR)/%.doc.tex: %.md $(TEX_RES)
	cat $(filter-out $<,$^) > $@.header
	pandoc -s -N -o $@ $< -H $@.header
	rm $@.header


$(BUILD_DIR)/%.slides.tex: %.md $(TEX_RES) $(SLIDES_RES)
	cat $(filter-out $<,$^) > $@.header
	pandoc -s -N -o $@ -t beamer $< -V theme=$(BEAMER_THEME) -H $@.header
	rm $@.header


# calls the latex PDF compiler
$(BUILD_DIR)/%.pdf: $(BUILD_DIR)/%.tex
	$(LATEX) $< > /dev/null
	rsync $(notdir $(patsubst %.tex,%.pdf,$<)) $@
	rm -f *.aux *.log *.nav *.out *.snm *.toc *.vrb


# downloads a VAR_URL as VAR.download if not empty, otherwise touch target
%.download:
	if [[ "$($(patsubst %.download,%_URL,$@))" != "" ]]; then wget -O $@ $($(patsubst %.download,%_URL,$@)); else touch $@; fi


# wraps a CSS file to HTML style brackets
%.css.html: %.css
	echo '<style>' > $@
	cat $< >> $@
	echo '</style>' >> $@

#downloads a CSS file if not present
%.css: %.download
	mv $< $@


%.texresource:
	cat $(MDMAKE_RESOURCE_DIR)/tex/$(patsubst %.texresource,%,$@) > $@

%.htmlresource:
	cat $(MDMAKE_RESOURCE_DIR)/html/$(patsubst %.htmlresource,%,$@) > $@

%.htmlcssresource:
	echo '<style>' > $@
	cat $(MDMAKE_RESOURCE_DIR)/html/$(patsubst %.htmlcssresource,%,$@) >> $@
	echo '</style>' >> $@

%.htmljsresource:
	echo '<script type="text/javascript" async >' > $@
	cat $(MDMAKE_RESOURCE_DIR)/html/$(patsubst %.htmljsresource,%,$@) >> $@
	echo '</script>' >> $@


$(BUILD_DIR):
	mkdir -p $@


clean:
	rm -rf $(BUILD_DIR)/*.pdf $(BUILD_DIR)/*.html $(BUILD_DIR)/*.docx

help:
	@echo "mdmake utility"
	@echo "usage: mdmake [target]"
	@echo ""

	@echo "targets:"
	@echo "  pdf                                               " --- build all markdown in current directory as LaTeX pdf
	@echo "  slides                                            " --- build all markdown in current directory as beamer slides
	@echo "  html                                              " --- build all markdown in current directory as html documents
	@echo "  word                                              " --- build all markdown in current directory as Microsoft Word documents
	@echo "  [target /wo .md][ .slides.pdf | .doc.pdf | .html ]" --- build individual target
	@echo "  dependencies                                      " --- get software dependencies
	@echo "  clean                                             " --- clean directory

dependencies:
	@echo "rsync wget pandoc pdflatex"
