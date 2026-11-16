# RPG Manager — Aplicativo Flutter

Aplicativo para gerenciamento de campanhas de RPG, personagens, classes e
convites. O Flutter consome a API REST Laravel; não persiste os dados do domínio
localmente.

## Requisitos

- Flutter e Dart compatíveis com `mobile/pubspec.yaml`
- Docker Desktop e Docker Compose para executar a API e o banco
- Google Chrome para executar a versão web

## Executar o projeto

Na raiz do repositório, inicie o back-end:

```powershell
docker compose up -d --build
docker compose exec php php artisan migrate --seed
```

Em outro terminal:

```powershell
cd mobile
flutter pub get
flutter run -d chrome
```

A API fica em `http://localhost:8000/api` na versão web. Para Android Emulator,
o app usa `http://10.0.2.2:8000/api`. Os endereços ficam centralizados em
`lib/core/constants/app_constants.dart`.

## Arquitetura

```text
lib/
├── core/       # rotas, tema, constantes, espaçamentos, formatos e validadores
├── models/     # modelos e conversão JSON da API
├── screens/    # telas agrupadas por funcionalidade
├── services/   # chamadas HTTP e operações da API
└── widgets/    # componentes reutilizáveis de interface
```

As telas chamam serviços, os serviços usam `ApiClient` para HTTP e convertem as
respostas em modelos. O token Sanctum é enviado pelo cliente HTTP e guardado
localmente por `shared_preferences`. Cores, tipografia e componentes visuais
seguem o tema centralizado em `core/theme` e `widgets`.

Após cada mutação concluída com sucesso, os serviços notificam
`AppDataNotifier`. As telas de lista, detalhes e convites escutam esse evento e
buscam os dados novamente; falhas da API não disparam atualização.

## Funcionalidades demonstráveis

- Cadastro, login e logout.
- Listar, criar, editar e excluir campanhas, classes e personagens.
- Visualizar detalhes da campanha e gerenciar personagens e classes vinculados.
- Enviar convites para jogadores; aceitar ou recusar convites recebidos.
- Estados de carregamento, erro com nova tentativa e listas vazias com ação.
- Validação de formulários e confirmação antes das exclusões.

As permissões continuam sendo verificadas pela API autenticada; a interface não
substitui as regras de acesso do servidor.

## Testes e análise

Execute na pasta `mobile`:

```powershell
flutter analyze
flutter test
```

Os testes Flutter cobrem validações de formulário e leitura dos modelos JSON.
Os testes da API ficam em `backend/tests` e podem ser executados com:

```powershell
cd backend
php artisan test
```

## Roteiro sugerido para a apresentação

1. Iniciar API e app; explicar a separação entre `screens`, `services`, `models`
   e `core`.
2. Entrar com um usuário de teste e mostrar campanhas como mestre e jogador.
3. Criar e editar uma campanha; demonstrar status e detalhes.
4. Criar, editar e excluir personagem; mostrar a associação a uma classe.
5. Criar e editar classe, adicionar/remover habilidade e excluir a classe.
6. Mostrar convite, estados de carregamento/erro/lista vazia e a validação de
   um formulário.
7. Finalizar com `flutter analyze`, `flutter test` e a documentação da API.

Antes de gravar, use dados de teste não sensíveis e confirme que os serviços
Docker e o Chrome estão funcionando.
