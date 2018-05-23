all: long_CV.pdf

#pdf:   clean $(PDFS)
#html:  clean $(HTML)

%_CV.pdf: %_CV.tex
	xelatex $*_CV
	biber $*_CV
	xelatex $*_CV
	xelatex $*_CV

yaml_CV.md: curriculum_vitae.yaml
# Pandoc can't actually read YAML, just YAML blocks in
# Markdown. So I give it a document that's just a YAML block,
# while still editing a straight YAML file which has a bunch of advantages.
	echo "---" > $@
	cat $< >> $@
	echo "..." >> $@

%_CV.tex: template_for_%_CV.tex yaml_CV.md
# Pandoc does the initial compilation to tex; we then latex handle the actual bibliography
# and pdf creation.
	pandoc --template=$< -t latex yaml_CV.md > $@
# Citekeys get screwed up by pandoc which escapes the underscores.
# Years should have en-dashes, which damned if I'm going to do it
# on my own.
	perl -pi -e 'if ($$_=~/cite\{/) {s/\\_/_/g}; s/(\d{4})-([Pp]resent|\d{4})/$$1--$$2/g' $@;

%-scholar.tex: FORCE_MAKE
	rm -f $@
	for cids in `grep 'scholar' /Users/knaaptime/Dropbox/references/library.bib|sed 's/^[^0-9]*//;s/[^0-9]*$$//'` ; do \
	 	sleep 10m ;\ # query every 10 mins so we don't get blocked
		cidss=`echo $$cids | sed 's/,/ /g'` ;\
		cites=`./citecount $$cidss` ;\
		echo "$$cites citations for $$cidss" ;\
		if [ "$$cites" -gt "0" ] ; then \
			echo "\defscholar{$$cids}{$$cites}" >> $@ ;\
		fi ;\
	done

clean:
	rm -f *CV.aux *CV.bcf *CV.log *CV.out *CV.run.xml *CV.pdf short_CV.tex long_CV.tex *CV.bbl *CV.blg *yaml_CV.md
