#!/usr/bin/env bash
# WSL2(Ubuntu/Debian) 개발 환경 설정 스크립트
# ════════════════════════════════════════════════════════════
#
# macOS 설정(hkh7670/dotfiles)을 WSL2에서 재현한다.
# - apt: 기본 패키지 (zsh, tmux, ripgrep, fd, btop 등)
# - 공식 설치 스크립트 / GitHub release: 최신 버전이 필요한 CLI 도구
#   (neovim, lazygit, lazydocker, fzf, delta, yazi, starship, mise, chezmoi)
# - oh-my-zsh + 플러그인, tmux 플러그인, mise 런타임, Docker Engine
# - chezmoi로 dotfiles 적용
#
# 사용법:
#   bash setup-wsl.sh
#
# 환경변수:
#   DOTFILES_REPO  chezmoi init 대상 (기본값: hkh7670)
#   UPGRADE=1      이미 설치된 GitHub release 도구도 최신 버전으로 다시 설치
#   SKIP_DOCKER=1  Docker Engine 설치 생략
#   GITHUB_TOKEN   GitHub API rate limit 회피용 (선택)
#
# 여러 번 실행해도 안전하다. 이미 설치된 항목은 건너뛴다.

set -euo pipefail

readonly DOTFILES_REPO="${DOTFILES_REPO:-hkh7670}"
readonly UPGRADE="${UPGRADE:-0}"
readonly SKIP_DOCKER="${SKIP_DOCKER:-0}"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly LOCAL_OPT="$HOME/.local/opt"
readonly OMZ_DIR="$HOME/.oh-my-zsh"
readonly TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"
# tmux.conf의 allow-passthrough가 tmux 3.3부터 지원된다.
readonly MIN_TMUX_VERSION="3.3"

APT_PACKAGES=(
  build-essential ca-certificates curl wget git gnupg unzip tar gzip file
  locales zsh tmux ripgrep fd-find btop htop jq
)

OMZ_PLUGINS=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
)

TMP_DIR=""

# ── 공통 유틸 ────────────────────────────────────────────────

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
  exit 1
}

has() { command -v "$1" >/dev/null 2>&1; }

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

# UPGRADE=1이 아니면 이미 있는 명령은 다시 설치하지 않는다.
should_install() {
  [ "$UPGRADE" = "1" ] || ! has "$1"
}

# GitHub release의 최신 tag (예: v0.12.6)
github_latest_tag() {
  local repo="$1"
  local -a auth=()
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  fi
  local tag
  tag=$(
    curl -fsSL "${auth[@]}" "https://api.github.com/repos/$repo/releases/latest" |
      grep -m1 '"tag_name"' |
      sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
  )
  [ -n "$tag" ] || die "$repo 최신 release를 찾지 못했습니다 (GITHUB_TOKEN 설정을 고려하세요)"
  printf '%s' "$tag"
}

download() {
  local url="$1" dest="$2"
  curl -fsSL --retry 3 -o "$dest" "$url" || die "다운로드 실패: $url"
}

# ── 사전 점검 ────────────────────────────────────────────────

ARCH_GNU=""   # x86_64 / aarch64
ARCH_DEB=""   # amd64 / arm64

detect_arch() {
  case "$(uname -m)" in
    x86_64)
      ARCH_GNU="x86_64"
      ARCH_DEB="amd64"
      ;;
    aarch64 | arm64)
      ARCH_GNU="aarch64"
      ARCH_DEB="arm64"
      ;;
    *) die "지원하지 않는 아키텍처입니다: $(uname -m)" ;;
  esac
}

preflight() {
  [ "$(id -u)" -ne 0 ] || die "root가 아닌 일반 사용자로 실행하세요 (필요할 때 sudo를 사용합니다)"
  grep -qi microsoft /proc/version 2>/dev/null || warn "WSL이 아닌 환경으로 보입니다. 계속 진행합니다."
  [ -r /etc/os-release ] || die "/etc/os-release가 없습니다"
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    ubuntu | debian) ;;
    *) die "Ubuntu/Debian만 지원합니다 (현재: ${ID:-unknown})" ;;
  esac
  has sudo || die "sudo가 필요합니다"
  detect_arch
  mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"
  export PATH="$LOCAL_BIN:$PATH"
  TMP_DIR=$(mktemp -d)
  trap cleanup EXIT
  sudo -v
}

# ── apt 패키지 ───────────────────────────────────────────────

install_apt_packages() {
  log "apt 패키지 설치"
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT_PACKAGES[@]}"

  # Debian/Ubuntu는 fd를 fdfind로 설치한다. LazyVim 등은 fd를 찾으므로 링크를 만든다.
  if has fdfind && ! has fd; then
    ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
}

setup_locale() {
  if locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
    return
  fi
  log "en_US.UTF-8 locale 생성"
  sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  sudo locale-gen
}

check_tmux_version() {
  local version
  version=$(tmux -V | sed -E 's/^tmux ([0-9.]+).*/\1/')
  if [ "$(printf '%s\n%s\n' "$MIN_TMUX_VERSION" "$version" | sort -V | head -1)" \
    != "$MIN_TMUX_VERSION" ]; then
    warn "tmux $version: tmux.conf의 일부 옵션(allow-passthrough)은 $MIN_TMUX_VERSION 이상 필요합니다"
  fi
}

# ── 공식 설치 스크립트 ───────────────────────────────────────

install_chezmoi() {
  should_install chezmoi || return 0
  log "chezmoi 설치"
  sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$LOCAL_BIN"
}

install_starship() {
  should_install starship || return 0
  log "starship 설치"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN"
}

install_mise() {
  should_install mise || return 0
  log "mise 설치"
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$LOCAL_BIN/mise" sh
}

# ── GitHub release ──────────────────────────────────────────

install_neovim() {
  should_install nvim || return 0
  log "neovim 설치"
  local arch="$ARCH_GNU"
  [ "$arch" = "aarch64" ] && arch="arm64"
  local name="nvim-linux-$arch"
  download "https://github.com/neovim/neovim/releases/latest/download/$name.tar.gz" \
    "$TMP_DIR/nvim.tar.gz"
  rm -rf "${LOCAL_OPT:?}/$name"
  tar -xzf "$TMP_DIR/nvim.tar.gz" -C "$LOCAL_OPT"
  ln -sf "$LOCAL_OPT/$name/bin/nvim" "$LOCAL_BIN/nvim"
}

install_lazygit() {
  should_install lazygit || return 0
  log "lazygit 설치"
  local tag version arch="$ARCH_GNU"
  tag=$(github_latest_tag jesseduffield/lazygit)
  version="${tag#v}"
  [ "$arch" = "aarch64" ] && arch="arm64"
  local base="https://github.com/jesseduffield/lazygit/releases/download/$tag"
  download "$base/lazygit_${version}_linux_${arch}.tar.gz" "$TMP_DIR/lazygit.tar.gz"
  tar -xzf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR" lazygit
  install -m 755 "$TMP_DIR/lazygit" "$LOCAL_BIN/lazygit"
}

install_lazydocker() {
  should_install lazydocker || return 0
  log "lazydocker 설치"
  local tag version arch="$ARCH_GNU"
  tag=$(github_latest_tag jesseduffield/lazydocker)
  version="${tag#v}"
  [ "$arch" = "aarch64" ] && arch="arm64"
  local base="https://github.com/jesseduffield/lazydocker/releases/download/$tag"
  download "$base/lazydocker_${version}_Linux_${arch}.tar.gz" "$TMP_DIR/lazydocker.tar.gz"
  tar -xzf "$TMP_DIR/lazydocker.tar.gz" -C "$TMP_DIR" lazydocker
  install -m 755 "$TMP_DIR/lazydocker" "$LOCAL_BIN/lazydocker"
}

# apt의 fzf는 버전이 낮아 .zshrc의 `fzf --zsh`(0.48+)를 지원하지 않을 수 있다.
install_fzf() {
  should_install fzf || return 0
  log "fzf 설치"
  local tag version
  tag=$(github_latest_tag junegunn/fzf)
  version="${tag#v}"
  local base="https://github.com/junegunn/fzf/releases/download/$tag"
  download "$base/fzf-${version}-linux_${ARCH_DEB}.tar.gz" "$TMP_DIR/fzf.tar.gz"
  tar -xzf "$TMP_DIR/fzf.tar.gz" -C "$TMP_DIR" fzf
  install -m 755 "$TMP_DIR/fzf" "$LOCAL_BIN/fzf"
}

install_delta() {
  should_install delta || return 0
  log "git-delta 설치"
  local tag name
  tag=$(github_latest_tag dandavison/delta)
  name="delta-${tag}-${ARCH_GNU}-unknown-linux-gnu"
  download "https://github.com/dandavison/delta/releases/download/$tag/$name.tar.gz" \
    "$TMP_DIR/delta.tar.gz"
  tar -xzf "$TMP_DIR/delta.tar.gz" -C "$TMP_DIR"
  install -m 755 "$TMP_DIR/$name/delta" "$LOCAL_BIN/delta"
}

install_yazi() {
  should_install yazi || return 0
  log "yazi 설치"
  local name="yazi-${ARCH_GNU}-unknown-linux-gnu"
  download "https://github.com/sxyazi/yazi/releases/latest/download/$name.zip" \
    "$TMP_DIR/yazi.zip"
  unzip -q -o "$TMP_DIR/yazi.zip" -d "$TMP_DIR"
  install -m 755 "$TMP_DIR/$name/yazi" "$LOCAL_BIN/yazi"
  install -m 755 "$TMP_DIR/$name/ya" "$LOCAL_BIN/ya"
}

# ── zsh ─────────────────────────────────────────────────────

install_oh_my_zsh() {
  if [ ! -d "$OMZ_DIR" ]; then
    log "oh-my-zsh 설치"
    # .zshrc는 chezmoi가 관리하므로 설치 스크립트가 만들거나 덮어쓰지 않게 한다.
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended
  fi

  local custom="${ZSH_CUSTOM:-$OMZ_DIR/custom}/plugins" repo
  for repo in "${OMZ_PLUGINS[@]}"; do
    if [ ! -d "$custom/${repo##*/}" ]; then
      log "oh-my-zsh 플러그인: $repo"
      git clone --depth 1 "https://github.com/$repo.git" "$custom/${repo##*/}"
    fi
  done
}

set_default_shell() {
  local zsh_path
  zsh_path=$(command -v zsh)
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh_path" ]; then
    return
  fi
  log "기본 셸을 zsh로 변경"
  sudo chsh -s "$zsh_path" "$USER"
}

# ── dotfiles ────────────────────────────────────────────────

apply_dotfiles() {
  if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    log "dotfiles 적용 (기존 chezmoi 소스 사용)"
    chezmoi apply
  else
    log "dotfiles 적용: $DOTFILES_REPO"
    chezmoi init --apply "$DOTFILES_REPO"
  fi
}

# tpm으로 설치하려면 tmux 서버가 필요하므로, tmux.conf의 @plugin 목록을 읽어 직접 clone한다.
# tpm과 같은 규칙으로 저장소 이름을 디렉터리명으로, '#' 뒤를 branch/tag로 쓴다.
install_tmux_plugins() {
  local conf="$HOME/.tmux.conf" spec repo ref dest
  [ -f "$conf" ] || {
    warn "~/.tmux.conf가 없어 tmux 플러그인 설치를 건너뜁니다"
    return 0
  }
  mkdir -p "$TMUX_PLUGIN_DIR"
  while IFS= read -r spec; do
    repo="${spec%%#*}"
    ref=""
    [ "$spec" != "$repo" ] && ref="${spec#*#}"
    dest="$TMUX_PLUGIN_DIR/${repo##*/}"
    [ -d "$dest" ] && continue
    log "tmux 플러그인: $spec"
    if [ -n "$ref" ]; then
      git -c advice.detachedHead=false clone --depth 1 --branch "$ref" \
        "https://github.com/$repo.git" "$dest"
    else
      git clone --depth 1 "https://github.com/$repo.git" "$dest"
    fi
  done < <(sed -nE "s/^set -g @plugin ['\"]([^'\"]+)['\"].*/\1/p" "$conf")
}

install_mise_tools() {
  [ -f "$HOME/.config/mise/config.toml" ] || {
    warn "mise 설정이 없어 런타임 설치를 건너뜁니다"
    return 0
  }
  log "mise 런타임 설치 (java, node, python, yarn)"
  mise install --yes
}

# ── Docker Engine ───────────────────────────────────────────

enable_wsl_systemd() {
  local conf=/etc/wsl.conf
  if grep -qE '^\s*systemd\s*=\s*true' "$conf" 2>/dev/null; then
    return
  fi
  log "/etc/wsl.conf에 systemd 활성화"
  if grep -q '^\[boot\]' "$conf" 2>/dev/null; then
    sudo sed -i '/^\[boot\]/a systemd=true' "$conf"
  else
    printf '\n[boot]\nsystemd=true\n' | sudo tee -a "$conf" >/dev/null
  fi
  NEED_WSL_RESTART=1
}

install_docker() {
  [ "$SKIP_DOCKER" = "1" ] && return 0
  enable_wsl_systemd

  if ! has docker; then
    log "Docker Engine 설치"
    # shellcheck disable=SC1091
    . /etc/os-release
    local keyring=/etc/apt/keyrings/docker.asc
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "https://download.docker.com/linux/$ID/gpg" -o "$keyring"
    sudo chmod a+r "$keyring"
    echo "deb [arch=$ARCH_DEB signed-by=$keyring] https://download.docker.com/linux/$ID" \
      "$VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
      docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker "$USER"
    NEED_RELOGIN=1
  fi

  # systemd가 이미 PID 1이면 바로 시작하고, 아니면 WSL 재시작 후 자동으로 시작된다.
  if [ "$(ps -p 1 -o comm=)" = "systemd" ]; then
    sudo systemctl enable --now docker
  fi
}

# ── 마무리 ──────────────────────────────────────────────────

NEED_WSL_RESTART=0
NEED_RELOGIN=0

print_summary() {
  log "설정 완료"
  cat <<EOF

다음 단계:
  - 새 터미널을 열면 zsh가 기본 셸로 실행됩니다.
  - nvim을 처음 실행하면 lazy.nvim과 Mason이 플러그인/LSP를 설치합니다.
  - Windows Terminal에 Nerd Font(예: D2Coding Nerd Font)를 설정하세요.
EOF
  if [ "$NEED_WSL_RESTART" = "1" ]; then
    echo "  - systemd를 켰습니다. PowerShell에서 'wsl --shutdown' 후 다시 접속하세요."
  fi
  if [ "$NEED_RELOGIN" = "1" ]; then
    echo "  - docker 그룹이 추가되었습니다. 다시 로그인해야 sudo 없이 docker를 쓸 수 있습니다."
  fi
}

main() {
  preflight
  install_apt_packages
  setup_locale
  check_tmux_version

  install_chezmoi
  install_starship
  install_mise
  install_neovim
  install_lazygit
  install_lazydocker
  install_fzf
  install_delta
  install_yazi

  install_oh_my_zsh
  apply_dotfiles
  install_tmux_plugins
  install_mise_tools
  install_docker
  set_default_shell

  print_summary
}

main "$@"
