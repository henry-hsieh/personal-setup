function lazygit --wraps=lazygit --description="Lazygit wrapper to disable delta features"
  set -lx DELTA_FEATURES
  command lazygit $argv
end
