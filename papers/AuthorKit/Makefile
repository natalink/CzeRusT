all:
	latex semantics.tex
	bibtex semantics
	latex semantics.tex
	latex semantics.tex
	dvipdf semantics.dvi

clean:
	rm -f semantics.aux semantics.bbl semantics.blg semantics.dvi semantics.log semantics.pdf
