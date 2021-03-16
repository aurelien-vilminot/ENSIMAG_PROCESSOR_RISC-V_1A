quiet-command = $(if $(filter 1, $(VERB)), $(1), $(if $(2), @echo $(2) && ($(1)) >> $(LOG_FILE), @($(1)) >> $(LOG_FILE)))
