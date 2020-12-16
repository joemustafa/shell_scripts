#!/usr/bin/env python
import logging
import sys
from logging.handlers import TimedRotatingFileHandler
from logging.handlers import RotatingFileHandler
FORMATTER = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s ', datefmt='%m/%d/%Y %I:%M:%S %p')
LOG_FILE = "my_app.log"


def get_console_handler():
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(FORMATTER)
    return console_handler


def get_file_handler():
   #  file_handler = TimedRotatingFileHandler(LOG_FILE, when='midnight',)
    file_handler = TimedRotatingFileHandler(
        LOG_FILE, when='s', interval=15, backupCount=15)
   #  file_handler = RotatingFileHandler(
   #      LOG_FILE, maxBytes=20, backupCount=5)
    file_handler.setFormatter(FORMATTER)
    return file_handler


def get_logger(logger_name):
    logger = logging.getLogger(logger_name)
    # better to have too much log than not enough
    logger.setLevel(logging.DEBUG)
    logger.addHandler(get_console_handler())
    logger.addHandler(get_file_handler())
    # with this pattern, it's rarely necessary to propagate the error up to parent
    logger.propagate = False
    return logger


my_logger = get_logger("my module name")
for i in range(2000000):
    my_logger.debug("a debug message [{}]".format(i))
