#!/bin/bash
#sort ps-save.01.30.2022.13.54.16435508* | uniq | grep -v "tee\|tcp\|ps"
sort ps-save.* | uniq | grep -v "tee\|tcp\|ps"
#sort ns-save-01.30.2022.14.11.16435519* | uniq
sort ns-save-* | uniq