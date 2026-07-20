{ inputs, pkgs, lib, config, ... }: {
  home.packages = with pkgs; [
    grc
  ];

  #age.secrets.bwSession = {
  #  file = ../../secrets/bwSession.age;
  #};

  programs = {

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    zsh = {
      enable = true;

      # already the defaukt:
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      #zplug = {
      #  enable = true;
      #  plugins = [
      #    { name = "zsh-users/zsh-autosuggestions"; }
      #    #{ name = "zsh-users/zsh-syntax-highlighting"; }
      #    #{ name = "zsh-users/zsh-completions"; }
      #    # { name = "zsh-users/zsh-history-substring-search"; }
      #    #{ name = "unixorn/warhol.plugin.zsh"; }
      #    ##{ name = "notthebee/prompt"; tags = [ as:theme ]; }
      #  ];
      #};

      history.size = 10000;

      shellAliases = {
        #la = "ls --color -lha";
        #df = "df -h";
        #du = "du -ch";
        #rebuild = "~/flexos/rebuild.sh"
        ipp = "curl ipinfo.io/ip";
        #yh = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:a copy -c:v copy {}.mkv && rm {}'";
        #yd = "yt-dlp --continue --no-check-certificate --format=bestvideo+bestaudio --exec='ffmpeg -i {} -c:v prores_ks -profile:v 1 -vf fps=25/1 -pix_fmt yuv422p -c:a pcm_s16le {}.mov && rm {}'";
        #ya = "yt-dlp --continue --no-check-certificate --format=bestaudio -x --audio-format wav";
        #aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
        #mkdir = "mkdir -p";
        #xp-microstack = "xpanes -t -s -c 'ssh -o StrictHostKeyChecking=no -J root@<jumphost> {}' <user>@10.x.x.x <user>@10.x.x.x <user>@10.x.x.x";
        #xp-microcloud = "xpanes -t -s -c 'ssh -o StrictHostKeyChecking=no -J root@<jumphost> {}' <user>@10.x.x.x <user>@10.x.x.x <user>@10.x.x.x";
        #clab = "containerlab";
      };

      #initContent = ''
      #  # Cycle back in the suggestions menu using Shift+Tab
      #  bindkey '^[[Z' reverse-menu-complete
      #
      #  bindkey '^B' autosuggest-toggle
      #  # Make Ctrl+W remove one path segment instead of the whole path
      #  WORDCHARS=''${WORDCHARS/\/}
      #
      #  # Highlight the selected suggestion
      #  zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      #  zstyle ':completion:*' menu yes=long select
      #
      #  if [ $(uname) = "Darwin" ]; then 
      #    path=("$HOME/.nix-profile/bin" "/run/wrappers/bin" "/etc/profiles/per-user/$USER/bin" "/nix/var/nix/profiles/default/bin" "/run/current-system/sw/bin" "/opt/homebrew/bin" $path)
      #    #export BW_SESSION=$($#{pkgs.coreutils}/bin/cat $#{config.age.secrets.bwSession.path})
      #    export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock" 
      #  fi
      #
      #  export EDITOR=nvim || export EDITOR=vim
      #  export LANG=en_US.UTF-8
      #  export LC_CTYPE=en_US.UTF-8
      #  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
      #
      #  source $ZPLUG_HOME/repos/unixorn/warhol.plugin.zsh/warhol.plugin.zsh
      #  bindkey '^[[A' history-substring-search-up
      #  bindkey '^[[B' history-substring-search-down
      #
      #  if command -v motd &> /dev/null
      #  then
      #    motd
      #  fi
      #  bindkey -e
      #
      #  # additional stuff to get home and end working
      #
      #  # Setup bindings for both smkx and rmkx key variants
      #  # Home
      #  #bindkey '\e[H'  beginning-of-line
      #  #bindkey '\eOH'  beginning-of-line
      #  #bindkey '^[[1~'  beginning-of-line
      #  #bindkey '$terminfo[khome]'  beginning-of-line 
      #  bindkey '^[[H'  end-of-line
      #  # End
      #  #bindkey '\e[F'  end-of-line
      #  #bindkey '\eOF'  end-of-line
      #  #bindkey '^[[4~'  end-of-line
      #  #bindkey '$terminfo[kend]'  end-of-line
      #  bindkey '^[[F'  end-of-line
      #
      #  # not necessary?
      #
      #  # Up
      #  #bindkey '\e[A' up-line-or-beginning-search
      #  #bindkey '\eOA' up-line-or-beginning-search
      #  # Down
      #  #bindkey '\e[B' down-line-or-beginning-search
      #  #bindkey '\eOB' down-line-or-beginning-search
      #  # Left
      #  #bindkey '\e[D' backward-char
      #  #bindkey '\eOD' backward-char
      #  # Right
      #  #bindkey '\e[C' forward-char
      #  #bindkey '\eOC' forward-char
      #  # Delete
      #  #bindkey '\e[3~' delete-char
      #  bindkey '^[[3~' delete-char
      #  # Backspace
      #  #bindkey '\e?' backward-delete-char
      #  # PageUp
      #  #bindkey '\e[5~' up-line-or-history
      #  bindkey '^[[5~' up-line-or-history
      #  # PageDown
      #  #bindkey '\e[6~' down-line-or-history
      #  bindkey '^[[6~' down-line-or-history
      #  # Ctrl+Left
      #  #bindkey '\e[1;5D' backward-word
      #  # Ctrl+Right
      #  #bindkey '\e[1;5C' forward-word
      #  # Shift+Tab
      #  #bindkey '\e[Z' reverse-menu-complete
      #  '';
      #};
    };
  };
}
