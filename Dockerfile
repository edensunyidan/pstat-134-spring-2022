ARG BASE_IMAGE=jupyter/scipy-notebook:7a0c7325e470
FROM $BASE_IMAGE

LABEL maintainer="Sang-Yun Oh <syoh@ucsb.edu>"

USER root

RUN \
    # yadm
    git clone https://github.com/TheLocehiliosan/yadm.git \
        /usr/local/share/yadm && \
    ln -s /usr/local/share/yadm/yadm /usr/local/bin/yadm && \
    \
    apt-get update && \
    apt-get install -y \
        libxtst-dev zsh powerline fonts-powerline less \
        bsdmainutils vim.tiny wget curl zip unzip && \
    \
    ln -s $(which vim.tiny) /usr/local/bin/vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# apt-get install -y file # doesn't work on WSL docker


USER $NB_USER

RUN \
    # classic notebook vim binding
    git clone https://github.com/lambdalisue/jupyter-vim-binding \
        /opt/conda/share/jupyter/nbextensions/vim_binding && \
    jupyter nbextension disable vim_binding/vim_binding --sys-prefix && \
    \
    # jupyter lab vim binding
    jupyter labextension install \
        @jupyterlab/katex-extension@1.0.0 \
        jupyterlab_vim@0.11.0 \
        --clean && \
    jupyter labextension disable jupyterlab_vim

RUN \
    ## Jupyter Classic Notebook Extensions
    ## pip install jupyter_nbextensions_configurator && \
    ## jupyter nbextensions_configurator enable --sys-prefix && \
    \
    pip install nbgitpuller==0.9.0 jupyter_contrib_nbextensions==0.5.1 && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable toc2/main --sys-prefix && \
    jupyter nbextension enable toggle_all_line_numbers/main --sys-prefix && \
    jupyter nbextension enable table_beautifier/main --sys-prefix && \
    \
    # rise
    pip install rise==5.6.1 && \
    jupyter nbextension install rise --py --sys-prefix && \
    jupyter nbextension enable rise --py --sys-prefix && \
    \
    # hide_code
    pip install hide_code==0.5.5 && \
    jupyter nbextension install --py hide_code --sys-prefix && \
    jupyter nbextension enable --py hide_code --sys-prefix && \
    jupyter serverextension enable --py hide_code --sys-prefix && \
    \
    # export_embedded
    jupyter nbextension enable export_embedded/main --sys-prefix && \
    \
    # nbzip
    pip install nbzip==0.1.0 && \
    jupyter serverextension enable nbzip --py --sys-prefix && \
    jupyter nbextension install nbzip --py --sys-prefix && \
    jupyter nbextension enable nbzip --py --sys-prefix

RUN \
    # user group
    rm -rf ~/.cache/pip ~/.cache/matplotlib ~/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN \
    pip install otter-grader==2.1.3 altair==4.1.0 cvxpy

