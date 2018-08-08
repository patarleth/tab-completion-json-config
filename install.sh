#!/usr/bin/env bash

INSTALL_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

installTabComp() {
    mkdir -p ~/.tab-completion-config && \
        cp "$INSTALL_SCRIPT_DIR/tab-completion-lib.sh" ~/.tab-completion-config/. && \
        . ~/.tab-completion-config/tab-completion-lib.sh 
    
    if [ -e ~/.bashrc ]; then
        if grep '.tab-completion-config' ~/.bashrc; then
            echo already installed
        else
            echo adding to .bashrc
            echo "source ~/.tab-completion-config/tab-completion-lib.sh" >> ~/.bashrc
        fi
    else
        echo ~/.bashrc does not exist
    fi
}

installTabComp
