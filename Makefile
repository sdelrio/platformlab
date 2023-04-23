
all:
	@cd bootstrap && $(MAKE) 
	@cd platform && $(MAKE)
	@cd platform && $(MAKE) gitea/prepare
	@cd bootstrap && $(MAKE) root

push:
	@git -c http.sslVerify=false push -u local master

