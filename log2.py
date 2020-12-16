#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name: example-TimedRotatingFileHandler.py
# Purpose: Write log using TimedRotatingFileHandler
# Author: Adrian Jones
# Created: 2012-05-25
#
# TimedRotatingFileHandler: from handler.py source:
# Current 'when' events supported:
#   S - Seconds
#   M - Minutes
#   H - Hours
#   D - Days
#   midnight - roll over at midnight
#   W{0-6} - roll over on a certain day; 0 - Monday
#
# Case of the 'when' specifier is not important; lower or upper case
# will work.
#
# Interval is in seconds
# backupCount in number of old log files to keep
#
#-------------------------------------------------------------------------------
import time
import logging
import logging.handlers
log_file_name = 'TimedRotatingFileHandler.log'
logging_level = logging.DEBUG
try:
    # set TimedRotatingFileHandler for root
    formatter = logging.Formatter('%(asctime)s %(name)s %(levelname)s %(message)s')
    # use very short interval for this example, typical 'when' would be 'midnight' and no explicit interval
    handler = logging.handlers.TimedRotatingFileHandler(log_file_name, when="S", interval=30, backupCount=10)
    handler.setFormatter(formatter)
    logger = logging.getLogger() # or pass string to give it a name
    logger.addHandler(handler)
    logger.setLevel(logging_level)
    # generate lots of example messages
    for i in range(10000):
        time.sleep(0.1)
        logger.debug('i=%d' % i)
        logger.info('i=%d' % i)
        logger.warn('i=%d' % i)
        logger.error('i=%d' % i)
        logger.critical('i=%d' % i)
except KeyboardInterrupt:
    # handle Ctrl-C
    logging.warn("Cancelled by user")
except Exception as ex:
    # handle unexpected script errors
    logging.exception("Unhandled error\n{}".format(ex))
    raise
finally:
    # perform an orderly shutdown by flushing and closing all handlers; called at application exit and no further use of the logging system should be made after this call.
    logging.shutdown()
