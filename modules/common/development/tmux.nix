{ pkgs, lib, ... }:
let
  plugins = with pkgs.tmuxPlugins; [
    sensible
    yank
    resurrect
    continuum
  ];
  loadPlugins = lib.concatMapStringsSep "\n" (p: "run-shell ${p.rtp}") plugins;
in
{
  programs.tmux = {
    enable = true;

    extraConfig = ''
      # ── Prefix: backtick ─────────────────────────────────
      unbind C-b
      set -g prefix `
      bind ` send-prefix

      # ── Base options ─────────────────────────────────────
      # Windows and panes count from 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g history-limit 100000
      set -g escape-time 0
      set -g mouse on
      set -g repeat-time 1000
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # ── Vi mode ──────────────────────────────────────────
      setw -g mode-keys vi
      set -g status-keys vi

      # ── No auto-rename / bell ────────────────────────────
      set-option -g allow-rename off
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # ── Config reload ────────────────────────────────────
      bind r source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # ── Pane navigation ──────────────────────────────────
      # prefix + hjkl
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      # Alt + hjkl (no prefix)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Pane resizing (prefix + H/J/K/L)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Swap panes
      bind < swap-pane -U
      bind > swap-pane -D

      # ── Window navigation (vim-style) ────────────────────
      bind -r C-h previous-window
      bind -r C-l next-window
      # Move the current window left/right (< and > are swap-pane above)
      bind -r M-h swap-window -d -t -1
      bind -r M-l swap-window -d -t +1

      # Split windows
      bind '\' split-window -h
      bind '-' split-window -v
      bind f resize-pane -Z

      # ── 24h clock ────────────────────────────────────────
      setw -g clock-mode-style 24

      # ── Status line ──────────────────────────────────────
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=white bg=black'

      set -g status-left '#[fg=green,bold] #S #[default]'
      set -g status-left-length 30

      set -g status-right '#[fg=yellow]%Y-%m-%d #[fg=cyan]%H:%M '
      set -g status-right-length 50

      # Window dots
      setw -g window-status-format ' #[fg=colour240]●'
      setw -g window-status-current-format ' #[fg=magenta,bold]●'
      setw -g window-status-bell-style 'fg=red,nobold'

      # Pane borders
      set -g pane-border-style 'fg=colour238'
      set -g pane-active-border-style 'fg=green'

      # Messages
      set -g message-style 'fg=black bg=yellow bold'

      # ── Copy mode (vi) ───────────────────────────────────
      bind Enter copy-mode
      bind -T copy-mode-vi v      send-keys -X begin-selection
      bind -T copy-mode-vi V      send-keys -X select-line
      bind -T copy-mode-vi C-v    send-keys -X rectangle-toggle
      bind -T copy-mode-vi Escape send-keys -X cancel
      bind -T copy-mode-vi H      send-keys -X start-of-line
      bind -T copy-mode-vi L      send-keys -X end-of-line
      # ponytail: tmux-yank handles clipboard per-platform (y in copy-mode-vi)

      # ── Session persistence ──────────────────────────────
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'

      # ── Load plugins (must be last; continuum must be final) ──
      ${loadPlugins}
    '';
  };
}
