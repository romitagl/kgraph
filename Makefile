.PHONY: ci
ci:
	# developer note: implement this target only for the subfolders (exclude the root Makefile)
	# searches for all Makefile from the root directory and runs the make ci target on each entry
	find . -name "Makefile" -not -path "./Makefile" | sed -e "s/Makefile//g" | xargs -I {} make --directory={} ci