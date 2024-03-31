# ----------------------------------------------------------------------------
# log.mak - support for logging in adaptabuild
#
# To enable a specific log level, set one or more of these variables
# in your top-level makefile
#
# LOG_ERROR
# LOG_WARNING
# LOG_NOTICE
# LOG_INFO
# LOG_DEBUG
#
# To use any of the macros, you will need to:
#
#   $(call log_xxx, some $(var) or $(other))
# ----------------------------------------------------------------------------

LOG_ERROR ?=
LOG_WARNING ?=
LOG_NOTICE ?=
LOG_INFO ?=
LOG_DEBUG ?=

log_error = $(if $(LOG_ERROR),\
                $(error ERROR $1))
log_warning = $(if $(LOG_WARNING),\
                $(warning WARNING $1))
log_notice = $(if $(LOG_NOTICE),\
                $(warning NOTICE $1))
log_info = $(if $(LOG_INFO),\
                $(warning INFO $1))
log_debug = $(if $(LOG_DEBUG),\
                $(warning DEBUG $1))