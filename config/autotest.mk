# Parameter
SEQUENCE_TAG ?= program/sequence_tag
COLOR        ?= 1
SHELL        := /bin/bash
MUTANTS      := 0

# Main rule
all:res

# Files & Directories
include config/directory.mk

TOCLEAN:= $(LOG) autotest.res tag.res
TOPOLISH:= $(SIM_DIR) $(MEM_DIR)

vpath %.s program:program/autotest:program/test_prof:program/test_periph

# Pas de fichier .s à la racine
ifneq ($(wildcard *.s),)
  $(error Merci de ranger vos .s dans le répertoire program/)
endif

.PHONY : res print filter clean realclean 

# Getting list of declared tags
TAGS  != sed -e 's/\#[ a-zA-Z0-9]*//g' $(SEQUENCE_TAG)

# Build patterns for select the right tests
PREFIX := "\#\\s*TAG\\s*=\\s*"
PATTERN := $(addprefix ${PREFIX}, ${TAGS})
PATTERN != echo $(PATTERN) | sed 's/[[:blank:]]/\|/g'

# Build tests list (those that match declared tags)
TESTS_S != grep -rnilE "${PATTERN}" --include=*.s ${TESTS_DIR} | sort -d
TESTS := $(patsubst %.s, %, $(notdir $(TESTS_S)))

SEQ_DIRS := $(addprefix $(SIM_DIR)/, $(TESTS))

MEM_FILES := $(TESTS:%=$(MEM_DIR)/%.mem)


print: tag.res 
	@echo ""
	@echo "   ****   Autotests Results   ****"
	@echo ""
	@# Print tag.res (with color)
	@-[[ $(COLOR) == 1 ]] && cat $< | GREP_COLORS='ms=01;31' grep --color "FAILED"        ; exit 0
	@-[[ $(COLOR) == 1 ]] && cat $< | GREP_COLORS='ms=01;33' grep --color "TIMEOUT"       ; exit 0
	@-[[ $(COLOR) == 1 ]] && cat $< | GREP_COLORS='ms=01;35' grep --color "NO_TEST_FOUND" ; exit 0
	@-[[ $(COLOR) == 1 ]] && cat $< | GREP_COLORS='ms=01;32' grep --color " PASSED"       ; exit 0
	@-[[ $(COLOR) == 1 ]] && cat $< | grep -v "FAILED\|TIMEOUT\|PASSED\|NO_TEST_FOUND"    ; exit 0
	@# (without color)
	@-[[ $(COLOR) != 1 ]] && cat $< ; exit 0
	@echo ""

tag.res : autotest.res
	@# Generate tag.res (results per tag)
	@bin/gen_res.sh "$(TAGS)" "$(TESTS_S)" | column -t > $@

autotest.res: res
	@# Generate autotest.res (results per file)
	@for test in $(TESTS) ; do echo $$test $$(cat $(SIM_DIR)/$$test/test_default.res) ; done | column -t > $@

res: export TESTS:=$(TESTS)
res: export MUTANTS:=$(MUTANTS)
res: $(SEQ_DIRS) $(MEM_FILES) 
	$(MAKE) -f config/simulation.mk SIM_SCRIPT=config/autotest.xsim.tcl TOP=autotest run

$(MEM_DIR)/%.mem:%.s
	$(MAKE) -f config/compile_RISCV.mk $@

$(SIM_DIR)/%: %.s clean_res |$(SIM_DIR)
	@echo "Generate test : '$@'"
	@mkdir -p $@
	# Quick and dirty hack to handle '#directive' instead of '# directive' in asm files
	# Generate .irq
	@sed -e 's/#/# /g' < $< |  tr -d '\r' | awk '$$1=="#" && $$2=="irq_start", $$1=="#" && $$2=="irq_end" {if ($$2!~"irq") print $$2}' > $@/test_default.irq
	# generate .out
	@sed -e 's/#/# /g' < $< |  tr -d '\r' | awk '$$1=="#" && $$2=="pout_start", $$1=="#" && $$2=="pout_end" {if ($$2!~"pout") print $$2 " " $$3}' | sed -e 's/  *$$//' > $@/test_default.out
	# generate .setup
	@sed -e 's/#/# /g' < $< |  tr -d '\r' | awk '$$1=="#" && $$2=="max_cycle" {print $$3}' > $@/test_default.setup ;\
	if [ ! -s $@/test_default.setup ] ; then echo "100" > $@/test_default.setup ; fi ;\
	if [ ! -s $@/test_default.irq ] ; then echo "false" >> $@/test_default.setup ;else echo "true" >> $@/test_default.setup ;fi

clean_res:
	@rm -f $(SIM_DIR)/*/test_default.{res,test}
	@rm -f $(SIM_DIR)/test_default.{res,test}

clean: clean_res 
	echo "Removing $(TOCLEAN)"
	@rm -rf $(TOCLEAN)

realclean: clean
	echo "Removing $(TOPOLISH)"
	@rm -rf $(TOPOLISH)
