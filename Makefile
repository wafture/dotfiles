#
# metadata / variables
#
NAME    := dotfiles
CONFIGS := $(shell find $(CURDIR)/etc -type f)
LOGFMT  := $(shell /bin/date "+%Y-%m-%d %H:%M:%S %z [$(NAME)]")

#
# default / help screen
#
default: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-12s %s\n\033[0m", $$1, $$2}'

#
# target: clean
# purpose: clean home directory of configrations
#
clean: ## clean home directory of configrations
	@echo $(LOGFMT) "cleaning dotfiles from homedir"
	@for cfg in $(CONFIGS); \
	do \
		unlink $(HOME)/.`basename $$cfg` > /dev/null 2>&1; true; \
	done

#
# target: install
# purpose: install configurations in home directory
#
GIT_USERNAME ?= Nicholas Anderson
GIT_EMAIL    ?= nicholas.anderson@nike.com
GIT_USERID   ?= iamnande

install: ## install configurations in home directory
	@echo $(LOGFMT) "installing dotfiles to homedir"
	@for cfg in $(CONFIGS); \
	do \
		f=$$(basename $$cfg); \
		ln -sfn $$cfg $(HOME)/.`basename $$f`; \
	done

	@echo $(LOGFMT) "personalizing gitconfig"
	@sed -iE 's/\([ ]*user = \).*/\1$(GIT_USERID)/' etc/gitconfig
	@sed -iE 's/\([ ]*name = \).*/\1$(GIT_USERNAME)/' etc/gitconfig
	@sed -iE 's/\([ ]*email = \).*/\1$(GIT_EMAIL)/' etc/gitconfig

#
# target: brew
# purpose: install brew & core brew software on the machine
#
BREW_PACKAGES = autoconf bash git go hub hugo jq make terraform tree vim wget zsh

brew: ## install brew & core brew software on the machine
	@if command -v brew &>/dev/null; then \
        echo $(LOGFMT) "brew already installed"; \
     else \
     	echo $(LOGFMT) "installing brew"; \
     	ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; \
    fi

	@echo $(LOGFMT) "installing brew formulae"
	@for pkg in $(BREW_PACKAGES); do \
		if brew ls --versions $$pkg > /dev/null; then \
			echo $(LOGFMT) "$$pkg already installed"; \
		else \
			brew install $$pkg; \
		fi \
	done

	@echo $(LOGFMT) "updating brew and cleaning up formulae"
	@brew cleanup
	@brew update
	@brew upgrade

#
# target: zsh
# purpose: install oh my zsh
#
zsh: ## install oh-my-zsh
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
# target: vimfiles
# purpose: install iamnande vimfiles
#
vimfiles: ## fetch/update vimfiles
	@echo $(FORMAT) "fetching vimfiles"
	@rm -rf ~/src/iamnande/vimfiles
	@git clone git@github.com:iamnande/vimfiles.git ~/src/iamnande/vimfiles
	@cd ~/src/iamnande/vimfiles \
		&& make