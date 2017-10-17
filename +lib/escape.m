function str=escape(str)
str = regexprep(str,'(\\)','\\$1');