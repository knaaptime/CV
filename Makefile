all: eknaap_cv.pdf

#pdf:   clean $(PDFS)
#html:  clean $(HTML)

eknaap_cv.pdf: eknaap_cv.tex
	xelatex eknaap_cv
	biber eknaap_cv
	xelatex eknaap_cv
	xelatex eknaap_cv
	rm -f *cv.aux *cv.bcf *cv.log *cv.out *cv.run.xml eknaap_cv.tex eknaap_cv.bbl eknaap_cv.blg *yaml_cv.md

yaml_cv.md: curriculum_vitae.yaml
# Pandoc can't actually read YAML, just YAML blocks in
# Markdown. So I give it a document that's just a YAML block,
# while still editing a straight YAML file which has a bunch of advantages.
	echo "---" > $@
	cat $< >> $@
	echo "..." >> $@

eknaap_cv.tex: template_for_eknaap_cv.tex yaml_cv.md
# Pandoc does the initial compilation to tex; we then latex handle the actual bibliography
# and pdf creation.
	pandoc --template=$< -t latex yaml_cv.md > $@
# Citekeys get screwed up by pandoc which escapes the underscores.
# Years should have en-dashes, which damned if I'm going to do it
# on my own.
	perl -pi -e 'if ($$_=~/cite\{/) {s/\\_/_/g}; s/(\d{4})-([Pp]resent|\d{4})/$$1--$$2/g' $@;


clean:
	rm -f *cv.aux *cv.bcf *cv.log *cv.out *cv.run.xml *cv.pdf short_cv.tex long_cv.tex *cv.bbl *cv.blg *yaml_cv.md
