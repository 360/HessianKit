#
# Makefile to generate documentation for HessianKit
#
dst_dir = ./Documentation

doc:
	rm -rf $(dst_dir)
	mkdir $(dst_dir)
	headerdoc2html -u -t -o $(dst_dir) ./HessianClasses
	gatherheaderdoc $(dst_dir) index.html
	
clean:
	rm -rf $(dst_dir)
