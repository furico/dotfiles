## ADDED Requirements

### Requirement: XDG 配置の stow パッケージ
tmux 設定は stow パッケージ `tmux` として管理され、XDG Base Directory に従い `~/.config/tmux/tmux.conf` へシンボリックリンクされる SHALL。リポジトリ内のパスは `tmux/.config/tmux/tmux.conf` とする。

#### Scenario: stow でリンクが作成される
- **WHEN** リポジトリルートで `stow tmux` を実行する
- **THEN** `~/.config/tmux/tmux.conf` がリポジトリ内 `tmux/.config/tmux/tmux.conf` へのシンボリックリンクとして作成される

#### Scenario: openspec は stow 対象外
- **WHEN** `stow -n tmux` でドライランする
- **THEN** `tmux/openspec/` 配下はリンク候補に含まれない（`.stowrc` の `--ignore=openspec` による）

### Requirement: 外部変更リロードの契約設定
tmux は `focus-events on` を設定し、ペインのフォーカス変化を内側のアプリ（Neovim）へ伝搬する SHALL。これにより Neovim の `FocusGained`→`checktime` による外部変更リロードが発火する。

#### Scenario: エージェント編集後のフォーカス復帰でリロードが発火する
- **WHEN** 別ペインの AI エージェントがファイルを書き換え、ユーザーが Neovim ペインへフォーカスを戻す
- **THEN** Neovim が `FocusGained` を受け取り `checktime` でバッファを再読み込みする

### Requirement: 入力遅延の排除
tmux は `escape-time` を 0 もしくは極小値に設定する SHALL。

#### Scenario: Esc 系操作が遅延しない
- **WHEN** Neovim で `<Esc>` または端末モード離脱 `<Esc><Esc>` を押す
- **THEN** 体感的な遅延なく即座に反応する

### Requirement: truecolor パススルー
tmux は `default-terminal "tmux-256color"` を設定し、`terminal-features` で `RGB`（truecolor）を有効化する SHALL。ghostty の `xterm-ghostty` を含む実行端末に対し色情報を欠落なく伝える。

#### Scenario: Neovim の termguicolors が正しく表示される
- **WHEN** `termguicolors` 有効の Neovim を tmux 内（ghostty 上）で開く
- **THEN** 24bit カラーが色化けなく表示される

### Requirement: システムクリップボード連携
tmux は `set-clipboard on` を設定し、OSC 52 経由でクリップボードと連携する SHALL。

#### Scenario: Neovim のヤンクが macOS クリップボードへ届く
- **WHEN** `clipboard=unnamedplus` の Neovim でテキストをヤンクする
- **THEN** macOS のクリップボードに同じ内容が入り、他アプリで貼り付けられる

### Requirement: prefix キーと基本バインド
tmux の prefix は `C-q` とし、既定の `C-b` を解除する SHALL。設定リロードのバインドを提供する SHALL。ペイン移動は `prefix + hjkl`、ペインのリサイズは `prefix + HJKL` に割り当て、`C-hjkl` は奪わず nvim・シェル・AI エージェントに残す SHALL。

#### Scenario: C-q が prefix として機能する
- **WHEN** tmux 内で `C-q` に続けてコマンドキー（例: ペイン分割）を押す
- **THEN** 対応する tmux 操作が実行される

#### Scenario: prefix + hjkl でペイン移動
- **WHEN** tmux 内で `prefix` に続けて `h`/`j`/`k`/`l` を押す
- **THEN** 対応方向のペインへフォーカスが移る。素の `C-h/j/k/l` は tmux に奪われずアプリ（nvim 挿入モード・シェルの readline・Claude Code の C-j=改行 など）へ届く

#### Scenario: 設定リロード
- **WHEN** ユーザーが設定リロードのバインドを実行する
- **THEN** `tmux.conf` が再読み込みされ、新しい設定が反映される

### Requirement: vi コピーモードとマウス
tmux はコピーモードを vi キーバインドにし、`mouse on` を設定する SHALL。

#### Scenario: vi 風にコピーモードを操作できる
- **WHEN** コピーモードに入り `v`（選択開始）と `y`（ヤンク）を使う
- **THEN** vi と同じ操作で範囲選択・コピーができ、コピー内容はシステムクリップボードへ送られる

#### Scenario: マウスでスクロール・操作できる
- **WHEN** マウスでペイン境界のドラッグやスクロールを行う
- **THEN** ペインのリサイズ・スクロールバックの閲覧ができる
