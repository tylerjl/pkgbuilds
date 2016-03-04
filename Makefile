.PHONY: clean

clean:
	rm -rf */src */pkg
	find -E . -regex '.*\.(xz|gz)$$' -print -delete
