.PHONY: default help clean install bootstrap-darwin bootstrap-debian zsh git vim vimfiles go

#
# make: app info
#
NAME    := dotfiles
UNAME   := $(shell uname -a)
CONFIGS := $(shell find $(CURDIR)/etc -type f)
FORMAT  := $(shell /bin/date "+%Y-%m-%d %H:%M:%S %z [$(NAME)]")

default: clean bootstrap zsh git vim vimfiles go install
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-12s %s\n\033[0m", $$1, $$2}'

#
# make: clean target
#
clean: ## clean dotfiles & scripts from system
	@echo $(FORMAT) "cleaning dotfiles from homedir"
	@for cfg in $(CONFIGS); \
	do \
		unlink $(HOME)/.`basename $$cfg` > /dev/null 2>&1; true; \
	done

#
# make: install target
#
install: ## installs dotfiles & scripts on system
	@echo $(FORMAT) "installing dotfiles to homedir"
	@for cfg in $(CONFIGS); \
	do \
		f=$$(basename $$cfg); \
		ln -sfn $$cfg $(HOME)/.`basename $$f`; \
	done

#
# make: bootstrap target
#
bootstrap: ## install machine software
	@echo $(FORMAT) "installing brew"
	@/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	@echo $(FORMAT) "installing brew formulae"
	@brew reinstall \
		autoconf \
		bash \
		gcc \
		gettext \
		jq \
		make \
		openssl \
		ossp-uuid \
		tree \
		wget \
		zlib \
		zsh
	@brew reinstall gettext && brew unlink gettext && brew link gettext --force

#
# make: zsh target
#
zsh: ## install zsh
	@echo $(FORMAT) "installing powerline fonts"
	@git clone --quiet --depth=1 \
		https://github.com/powerline/fonts.git ~/src/powerline-fonts
	@cd ~/src/powerline-fonts && ./install.sh
	@rm -rf ~/src/powerline-fonts

	@echo $(FORMAT) "installing oh-my-zsh"
	@rm -rf ~/.oh-my-zsh
	@curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
	@chsh -s /bin/zsh "${USER}"

	@echo $(FORMAT) "installing bullet-train theme"
	@curl -fsSL -o ~/.oh-my-zsh/themes/bullet-train.zsh-theme \
		https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme

#
# make: git target
#
GIT_VERSION := 2.22.0
GIT_HOME    := /usr/local/src
GIT_SOURCE  := https://github.com/git/git/archive/v$(GIT_VERSION).tar.gz

git: ## install git from source
	@echo $(FORMAT) "installing $@"
	@sudo rm -rf $(GIT_HOME)/$@-* && sudo mkdir -p /usr/local/src
	@curl -sSL $(GIT_SOURCE) | sudo tar -C $(GIT_HOME) -zx
	@cd $(GIT_HOME)/$@-$(GIT_VERSION) \
		&& sudo make prefix=/usr/local all \
		&& sudo make prefix=/usr/local install

#
# make: hub target
#
HUB_VERSION := 2.12.2
HUB_HOME    := /usr/local/src
HUB_FLAVOR  := $(shell uname -s | awk '{print tolower($$0)}')
HUB_SOURCE  := https://github.com/github/hub/releases/download/v$(HUB_VERSION)/hub-$(HUB_FLAVOR)-amd64-$(HUB_VERSION).tgz

hub:
	@echo $(FORMAT) "installing $@"
	@sudo rm -rf $(HUB_HOME)/$@-*-$(HUB_VERSION) && sudo mkdir -p /usr/local/src
	@curl -sSL $(HUB_SOURCE) | sudo tar -C $(HUB_HOME) -zx
	@cd $(HUB_HOME)/$@-*-$(HUB_VERSION) \
		&& sudo ./install

#
# make: vim target
#
VIM_VERSION := 8.1.1666
VIM_HOME    := /usr/local/src
VIM_SOURCE  := https://github.com/vim/vim/archive/v$(VIM_VERSION).tar.gz

vim:
	@echo $(FORMAT) "installing $@ v$(VIM_VERSION)"
	@sudo rm -rf $(VIM_HOME)/$@-* && sudo mkdir -p /usr/local/src
	@curl -sSL $(VIM_SOURCE) | sudo tar -C $(VIM_HOME) -zx
	@cd $(VIM_HOME)/$@-$(VIM_VERSION) \
		&& sudo ./configure \
		&& sudo make install

#
# make: vimfiles target
#
vimfiles: ## fetch/update vimfiles
	@echo $(FORMAT) "fetching vimfiles"
	@rm -rf ~/src/iamnande/vimfiles
	@git clone git@github.com:iamnande/vimfiles.git ~/src/iamnande/vimfiles
	@cd ~/src/iamnande/vimfiles \
		&& make

#
# make: go target
#
GO_VERSION := 1.12.7
GO_HOME    := /usr/local
GO_FLAVOR  := $(shell uname -s | awk '{print tolower($$0)}')
GO_SOURCE  := https://dl.google.com/go/go$(GO_VERSION).$(GO_FLAVOR)-amd64.tar.gz

go: ## install golang
	@echo $(FORMAT) "installing $@ $(GO_VERSION)"
	@sudo rm -rf $(GO_HOME)/$@
	@curl -sSL $(GO_SOURCE) | sudo tar -C $(GO_HOME) -zx
