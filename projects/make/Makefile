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
POP=../bin/postprocess.pl

# gives the name of the project directory, $(CURDIR) is the full path
#
DIR=`basename $(CURDIR)`


DEPS=$(subst .lsl,.d,$(subst src/,dep/,$(SRC)))

all: $(DBG) $(OBJ) $(DOC) $(TAGS) $(DEPS)
# $(HTML)

doc: doc/%.pdf
	@cp doc/*.pdf ./

debug: $(DBG)

dbg/%.i: src/%.lsl
#	@echo "processing $<"
	@echo "// =$(DIR)/$(@F)" > $@
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -P -DTIME=`date +0x%H%M%S` -DDATE=`date +0x%Y%m%d` $< | $(POP) | astyle --style=allman >> $@
	@wc -cl $@
	@$(ADD) $(DIR)/$< $(CURDIR)/bin/`basename $<`

bin/%.o: dbg/%.i
#	@cat $< | $(ITO) `basename $<` > $@
	@cat $< | $(ITO) $(DIR)/$(@F) > $@

%.pdf: %.ltx
	@pdflatex -output-directory ./doc $<

TAGS: $(SRC) $(LIB) $(LOC) $(INC)
#	@echo "generating $(TAGS)"
	@etags $(SRC) $(LIB) $(LOC) $(INC)

dep/%.di: src/%.lsl
#	@echo "generating dependencies: $@"
	@cpp -I$(LIBDIR) -I$(LOCDIR) -I$(INCDIR) -MM $< | sed '/^.*\.o:/s_^_dbg/_' | sed 's/\.o:/\.i:/' > $@

dep/%.d: dep/%.di
#	@echo "generating dependencies: $@"
	@sed 's_^dbg/_bin/_' $< | sed 's/\.i:/\.o:/' > $@


-include $(subst .lsl,.d,$(subst src/,dep/,$(SRC)))
-include $(subst .lsl,.di,$(subst src/,dep/,$(SRC)))


###########################################################################
#
# http://www.gnu.org/software/make/manual/make.html#Automatic-Variables
#
# Here is a table of automatic variables:
#
# $@
#    The file name of the target of the rule. If the target is an
#    archive member, then ‘$@’ is the name of the archive file. In a
#    pattern rule that has multiple targets (see Introduction to
#    Pattern Rules), ‘$@’ is the name of whichever target caused the
#    rule's recipe to be run.
#
# $<
#
#    The name of the first prerequisite. If the target got its recipe
#    from an implicit rule, this will be the first prerequisite added
#    by the implicit rule (see Implicit Rules).
#
###########################################################################
#
#
# with ~/.astylerc:
#
# 
# --mode=c
# --style=gnu
# --indent=tab
# --break-blocks
# --unpad-paren
# --break-elseifs
# --add-brackets
# --add-one-line-brackets
# --pad-oper
# --mode=c
# --min-conditional-indent=0
#
###########################################################################
