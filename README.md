# 🎲 RPG Manager — Projeto Integrado (4º Período)

Sistema para gerenciamento de personagens, classes e campanhas de RPG de mesa, desenvolvido como Trabalho Final Integrado para as disciplinas:
- **Programação Orientada a Objetos para Web (Laravel)** — Prof. Claudinei José Machado
- **Programação para Dispositivos Móveis (Flutter/Dart)**
- **Paradigmas de Linguagem de Programação** (Padrões Arquiteturais e Separação de Camadas)

---

## 🏗️ Arquitetura do Back-end (Laravel)

Em estrito alinhamento com as exigências de **Paradigmas de Linguagem de Programação** e **POO Web**, o back-end adota separação estrita de responsabilidades:

```text
HTTP Request
     │
     ▼
Controllers (app/Http/Controllers) ───► Recebe requisições e retorna respostas JSON padronizadas
     │
     ▼
Form Requests (app/Http/Requests)  ───► Validação isolada e tipada de dados de entrada
     │
     ▼
Services (app/Services)            ───► Concentra 100% das regras de negócio e controle de acesso
     │
     ▼
Repositories (app/Repositories)    ───► Abstração de persistência e consultas Eloquent
     │
     ▼
Models (app/Models)                ───► Relacionamentos Eloquent, casts e atributos fillable
     │
     ▼
MySQL Database (Docker)
```

---

## 🚀 Como Executar o Ambiente (Docker)

O projeto utiliza **Docker Compose** com a mesma stack e padronização adotada durante as aulas:

### 1. Subir os contêineres
Na raiz do projeto, execute:
```bash
docker compose up -d --build
```

Os seguintes serviços estarão disponíveis:
| Serviço | Contêiner | Porta Externa | Descrição |
|---|---|---|---|
| **API REST (Nginx + PHP 8.4)** | `rpg_manager_nginx` | `http://localhost:8000` | Servidor da API Laravel |
| **Documentação Scramble** | `rpg_manager_nginx` | `http://localhost:8000/docs/api` | Swagger/OpenAPI interativo |
| **Banco MySQL 9** | `rpg_manager_mysql` | `localhost:33066` | Banco de dados relacional |
| **phpMyAdmin** | `rpg_manager_phpmyadmin` | `http://localhost:8081` | Interface web para o banco |

### 2. Rodar Migrations e Popular Dados de Teste
Entre no contêiner PHP ou execute diretamente:
```bash
docker compose exec php php artisan migrate --seed
```

---

## 🔑 Credenciais Padrão para Testes

### Usuários semeados pelo Seeder (`DatabaseSeeder`):
| Papel | E-mail | Senha | Descrição |
|---|---|---|---|
| **Mestre** | `mestre@rpgmanager.com` | `password123` | Dono de classes e da campanha "A Mina Perdida de Phandelver" |
| **Jogador** | `jogador@rpgmanager.com` | `password123` | Dono dos personagens Thorin e Elion |

### Acesso ao Banco no phpMyAdmin (`http://localhost:8081`):
- **Servidor (Host):** `mysql`
- **Usuário:** `rpg_user`
- **Senha:** `rpg_password`
- **Database:** `rpg_manager`
- *(Ou como root: usuário `root`, senha `root`)*

---

## 📄 Testes de API e Documentação

1. **Documentação Interativa (Scramble / OpenAPI):**
   - Acesse no navegador: **`http://localhost:8000/docs/api`**
2. **Arquivo `rest.http`:**
   - Na raiz do projeto, utilize a extensão *REST Client* no VS Code / editor para disparar todas as requisições autenticadas (Auth, Classes, Personagens, Campanhas e Vínculos).

---

## 📱 Como Executar o Aplicativo Flutter (Web / Chrome)

O frontend foi desenvolvido em Flutter e consome a API REST Laravel. A
organização separa telas, serviços HTTP, modelos, regras compartilhadas e
widgets reutilizáveis. A documentação do app, arquitetura e roteiro de
apresentação está em [`mobile/README.md`](./mobile/README.md).

```bash
# 1. Entrar na pasta do aplicativo
cd mobile

# 2. Obter as dependências
flutter pub get

# 3. Executar diretamente no Google Chrome
flutter run -d chrome
```

### Validar o aplicativo

Na pasta `mobile`, execute:
```bash
flutter analyze
flutter test
```

---

## 📦 Estrutura de Diretórios
- `backend/` — API REST desenvolvida em Laravel (Fase 1)
- `mobile/` — Aplicativo em Flutter/Dart (Fase 2)
- `docker/` — Configurações de PHP 8.4, Nginx e MySQL
- `rest.http` — Suíte de testes manuais da API REST
- `referencias/` — Projetos de aula guardados apenas como consulta interna (não versionados)
