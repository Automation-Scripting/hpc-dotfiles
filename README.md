# Dotfiles para Bash (HPC Linux)

Este diretorio contem uma versao Bash, portavel para Linux, das automacoes mais universais do seu setup em `macOS-automations/shell`.

## Como ativar

Adicione ao seu `~/.bashrc`:

```bash
source "$HOME/.dotfiles/bash/bootstrap.sh"
```

No HPC, abra um novo terminal ou rode `source ~/.bashrc`.

## Diretorio Inicial Sem Quebrar source

Se voce quer abrir todo terminal em um diretorio fixo, coloque o `cd` no seu `~/.bash_profile` (ou `~/.profile`) e nao no `~/.bashrc`.

Exemplo para `~/.bash_profile`:

```bash
if [[ -d "$HOME/work" ]]; then
  cd "$HOME/work"
fi
```

Assim:
- novo terminal entra no diretorio desejado
- `source ~/.bashrc` nao muda seu diretorio atual

## O que foi migrado

- Helpers de PATH: `path_prepend`, `path_append`
- Aliases universais de navegacao:
  - `..`, `...`, `....`
  - `c` (clear)
  - `reloadsh` (recarrega `~/.bashrc`)
- Python:
  - Integracao com pyenv (`PYENV_ROOT`, init condicional)
  - Funcao `venv` para criar/ativar `.venv`, atualizar pip e instalar `requirements.txt`
- Git:
  - `gh_clone_org_repos` para clonar repositorios de uma organizacao (detectada pela pasta atual)
  - Compatibilidade com seus atalhos antigos: `u` e `n`
- HPC Condor:
  - Submissao de jobs: `csub`
  - Fila e inspeção: `cq`, `cqi`, `cwatch`, `cjobpaths`
  - Historico: `chist`
  - Controle de jobs: `crm`, `chold`, `chrel`
  - Atalhos: `cme`, `cqa`, `cst`
- Registro rapido de automacoes:
  - `reg-alias` / `aliases`
  - `reg-install` / `installs`
  - `reg-config` / `configs`
  - `reg-export` / `exports`
  - `reg-symlink` / `symlink`

## O que foi deixado de fora

- Itens especificos de macOS (`launchctl`, Homebrew path de macOS, TeX em `/Library/TeX/texbin`, Karabiner, Safari-touch-tabs)
- Aliases fortemente acoplados a ambientes/projetos pessoais (AWS/Kane/terraform com caminhos fixos, hosts SSH fixos)
- Funcoes com operacoes destrutivas ou muito especificas de workflow (ex.: force-push de tag)

## Uso rapido (Condor)

```bash
# Submete o unico arquivo .sub do diretorio atual
csub

# Submete um arquivo especifico
csub run.sub

# Mostra sua fila
cq

# Monitora fila continuamente (5s)
cwatch

# Mostra detalhes de um job
cqi 12345.0

# Cancela job
crm 12345.0
```

## Uso rapido (registro)

```bash
# Salva alias customizado e ativa na sessao atual
reg-alias ll='ls -lah'

# Registra e executa um comando de instalacao
reg-install sudo apt-get install -y jq

# Registra e executa um comando de configuracao
reg-config git config --global pull.rebase true

# Registra e ativa uma variavel de ambiente
reg-export API_TOKEN=abc123

# Registra e aplica um symlink (target relativo ao HOME)
reg-symlink bash/bootstrap.sh .dotfiles/bootstrap.sh
```

Cada registro faz `git add` + `git commit` + `git push` automaticamente no repo de dotfiles quando houver remote configurado e autenticacao valida.
