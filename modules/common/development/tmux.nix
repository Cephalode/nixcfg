{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Enable the bundled "sensible" defaults (256 color, base-index 1,
    # escape-time 0, renumber-windows, new-window from current path)
    enableSensible = true;

    # Mouse support (clickable panes/windows, scroll, resize)
    enableMouse = true;

    # Vim-style pane nav (hjkl) + vi copy mode + pbcopy integration on macOS
    enableVim = true;

    # ── Additional config ────────────────────────────────────
    extraConfig = ''
      # ── Extended keys (required for pi inside tmux) ────
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # ── History ───────────────────────────────────────────
      set -g history-limit 100000

      # ── No auto-rename ───────────────────────────────────
      set-option -g allow-rename off

      # ── Disable bell ─────────────────────────────────────
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # ── Fast config reload ───────────────────────────────
      bind r source-file /etc/tmux.conf \; display-message "Config reloaded!"

      # ── Pane navigation without prefix (Alt + hjkl) ─────
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ── Pane resizing (prefix + H/J/K/L) ────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── Swap panes ──────────────────────────────────────
      bind < swap-pane -U
      bind > swap-pane -D

      # ── Vi-style copy mode bindings ─────────────────────
      bind Enter copy-mode
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      # ── 24h clock ───────────────────────────────────────
      setw -g clock-mode-style 24

      # ── Status line ─────────────────────────────────────
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'fg=white bg=black'

      set -g status-left '#[fg=green,bold] #S #[default]'
      set -g status-left-length 30

      set -g status-right '#[fg=yellow]%Y-%m-%d #[fg=cyan]%H:%M '
      set -g status-right-length 50

      setw -g window-status-current-style 'fg=black bg=green bold'
      setw -g window-status-current-format ' #I:#W#F '

      setw -g window-status-style 'fg=white bg=black'
      setw -g window-status-format ' #I:#W#F '

      # Pane borders
      set -g pane-border-style 'fg=colour238'
      set -g pane-active-border-style 'fg=green'

      # Messages
      set -g message-style 'fg=black bg=yellow bold'
    '';
  };

  # tmux plugins (install as system packages)
  environment.systemPackages =
    (with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ]);
}
