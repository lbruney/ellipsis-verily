staticJs=../demo/assets/js/

all: jade coffee minify

jade:
	jade --pretty -w index.jade --out ../demo/
  
coffee:
	coffee -c -w -o $(staticJs) ellipsis-verily.coffee

minify:
	cat $(staticJs)ellipsis-verily.js | uglifyjs -m -c -o $(staticJs)ellipsis-verily.min.js