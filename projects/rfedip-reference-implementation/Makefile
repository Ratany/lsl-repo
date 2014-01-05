SRC=$(wildcard src/*.lsl)
LIB=$(wildcard ../lib/*.lsl)
LOC=$(wildcard ./lib/*.h)
INC=$(wildcard ../include/*.h)
DBG=$(subst .lsl,.j,$(subst src,dbg,$(SRC))) $(subst .lsl,.i,$(subst src,dbg,$(SRC)))
OBJ=$(subst .lsl,.o,$(subst src,bin,$(SRC)))
#HTML=$(subst .txt,.html,$(wildcard doc/*.txt))
DOC=$(subst .ltx,.pdf,$(wildcard doc/*.ltx))
INCDIR=../include
LIBDIR=../lib
LOCDIR=./lib
TAGS=./TAGS

#FLAGS= -DDEBUG
SYM=VERSION='version 0.00'
#VERSION=undefined


all: $(DBG) $(OBJ) $(DOC) $(TAGS)
# $(HTML)

doc: doc/%.pdf
	@cp doc/*.pdf ./

deps: $(SRC) $(LIB) $(INC) $(LOC)
	@rm -f deps
	@touch deps
	@makedepend -Y -fdeps -I$(LOCDIR) -I$(LIBDIR) -I$(INCDIR) $(SRC)
	@cat deps | sed "s/^src/bin/g" > deps2
	@cat deps | sed "s/^src/dbg/g" | sed "s/\.o/.i/g" >> deps2
	@mv deps2 deps
	@rm deps.bak

debug: $(DBG)

dbg/%.i: src/%.lsl
	@echo "COMPILING $<"
	@echo -n "//" > $@
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -D$(SYM) -P $(FLAGS) $< | md5sum >> $@
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -D$(SYM) -P $(FLAGS) -DTIME=`date +0x%H%M%S` -DDATE=`date +0x%Y%m%d` $< >> $@

dbg/%.j: dbg/%.i
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -D$(SYM) -P $(FLAGS) $< > $@

bin/%.o: dbg/%.i
	@sed -f ../clean-lsl.sed $< > $<.clean
	@wc -cl $<.clean
	@astyle --style=allman -f < $<.clean > $<
	@cat $< | sed -f ../clean-lsl.sed | i2o.pl  `basename $<` > $@

%.pdf: %.ltx
#	@echo $(VERSION) > ./tmp/version.inc
	@pdflatex -output-directory ./doc $<

TAGS: $(SRC) $(LIB) $(LOC)
	@etags $(SRC) $(LIB) $(LOC)


-include deps
