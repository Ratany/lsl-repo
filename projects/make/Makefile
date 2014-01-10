SRC=$(wildcard src/*.lsl)
LIB=$(wildcard ../lib/*.lsl)
LOC=$(wildcard ./lib/*.h)
INC=$(wildcard ../include/*.h)
DBG=$(subst .lsl,.i,$(subst src/,dbg/,$(SRC)))
OBJ=$(subst .lsl,.o,$(subst src/,bin/,$(SRC)))
#HTML=$(subst .txt,.html,$(wildcard doc/*.txt))
DOC=$(subst .ltx,.pdf,$(wildcard doc/*.ltx))
INCDIR=../include
LIBDIR=../lib
LOCDIR=./lib

TAGS=./TAGS
ITO=../bin/i2o.pl
ADD=../bin/addtotable.pl

DEPS=$(subst .lsl,.d,$(subst src/,dep/,$(SRC)))

all: $(DBG) $(OBJ) $(DOC) $(TAGS) $(DEPS)
# $(HTML)

doc: doc/%.pdf
	@cp doc/*.pdf ./

debug: $(DBG)

dbg/%.i: src/%.lsl
	@echo "preprocessing $<"
	@echo "// =`basename $@`" > $@
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -P -DTIME=`date +0x%H%M%S` -DDATE=`date +0x%Y%m%d` $< >> $@
	@$(ADD) $< $(CURDIR)/bin/`basename $<`

bin/%.o: dbg/%.i
	@sed -f ../clean-lsl.sed $< > $<.clean
	@wc -cl $<.clean
	@astyle --style=allman -f < $<.clean > $<
	@rm $<.clean
	@cat $< | sed -f ../clean-lsl.sed | $(ITO) `basename $<` > $@

%.pdf: %.ltx
	@pdflatex -output-directory ./doc $<

TAGS: $(SRC) $(LIB) $(LOC) $(INC)
	@echo "generating $(TAGS)"
	@etags $(SRC) $(LIB) $(LOC) $(INC)

dep/%.di: src/%.lsl
	@echo "generating dependencies: $@"
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -MM $< | sed '/^.*\.o:/s_^_dbg/_' | sed 's/\.o:/\.i:/' > $@

dep/%.d: dep/%.di
	@echo "generating dependencies: $@"
	@sed 's_^dbg/_bin/_' $< | sed 's/\.i:/\.o:/' > $@


-include $(subst .lsl,.d,$(subst src/,dep/,$(SRC)))
-include $(subst .lsl,.di,$(subst src/,dep/,$(SRC)))
