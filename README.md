# dotfiles (chezmoi)

chezmoi로 관리하는 dotfiles. source: `~/.local/share/chezmoi`, remote: `git@github.com:hkh7670/dotfiles.git` (branch: `master`)

## 이 PC에서 dotfile 수정 → push

1. 평소처럼 그냥 실제 파일을 수정한다 (`~/.tmux.conf`, `~/.config/nvim/...` 등 홈 디렉토리 파일을 직접 편집).
   - 또는 `chezmoi edit ~/.tmux.conf` 로 source 파일을 바로 열어 편집해도 된다 (이 경우 2번 re-add 불필요).

2. 변경사항을 chezmoi source에 반영한다.

   ```sh
   chezmoi re-add          # 관리 중인 파일 전체를 실제 상태 기준으로 재반영
   # 또는 특정 파일만: chezmoi add ~/.tmux.conf
   ```

3. 뭐가 바뀌는지 확인한다 (선택이지만 추천).

   ```sh
   chezmoi status
   chezmoi diff
   ```

4. 커밋 & 푸시한다 (source 디렉토리 자체가 git repo라 `cd` 하거나 `chezmoi git` 패스스루 사용).

   ```sh
   chezmoi git add -- -A
   chezmoi git commit -- -m "설명"
   chezmoi git push
   ```

   또는 동일하게:

   ```sh
   cd ~/.local/share/chezmoi
   git add -A
   git commit -m "설명"
   git push
   ```

## 다른 PC에 반영

- 처음 세팅하는 PC:

  ```sh
  chezmoi init --apply git@github.com:hkh7670/dotfiles.git
  ```

- 이미 세팅된 PC에서 최신 변경 받아오기 (제일 자주 쓸 명령):

  ```sh
  chezmoi update
  ```

  내부적으로 `git pull` + `chezmoi apply`를 한 번에 해준다.

- 적용 전에 뭐가 바뀌는지 미리 보고 싶으면:

  ```sh
  chezmoi update -v -n     # dry-run으로 diff만 확인
  chezmoi update            # 실제 적용
  ```

## 핵심 요약

- 이 PC: 수정 → `chezmoi re-add` → git commit/push
- 다른 PC: `chezmoi update`
