# Guia de Instalação - E-Commerce Microservices

Este guia explica como instalar e configurar o ambiente de desenvolvimento para o sistema de microserviços.

## 📋 Pré-requisitos

### 1. .NET 8.0 SDK
**Download:** https://dotnet.microsoft.com/download/dotnet/8.0

Após a instalação, verifique:
```powershell
dotnet --version
```

### 2. SQL Server (Opções)
**Opção A - SQL Server Express (Recomendado):**
- Download: https://www.microsoft.com/sql-server/sql-server-downloads
- Escolha "Express" (gratuito)

**Opção B - SQL Server LocalDB:**
```powershell
# Instalar via chocolatey (se tiver)
choco install sqllocaldb

# Ou baixar do site da Microsoft
```

**Opção C - Docker Desktop (se preferir):**
- Download: https://www.docker.com/products/docker-desktop/

### 3. RabbitMQ (Opções)
**Opção A - Instalação Local:**
- Download: https://www.rabbitmq.com/install-windows.html
- Instalar Erlang primeiro: https://www.erlang.org/downloads

**Opção B - CloudAMQP (Serviço gratuito na nuvem):**
- Criar conta em: https://www.cloudamqp.com/

### 4. Visual Studio Code (Opcional)
- Download: https://code.visualstudio.com/
- Extensões recomendadas:
  - C# Dev Kit
  - REST Client
  - Docker (se usar)

## 🚀 Configuração Rápida

### 1. Instalar .NET 8.0
```powershell
# Verificar se foi instalado corretamente
dotnet --info
```

### 2. Restaurar Dependências
```powershell
cd "C:\Users\sebas\Music\DESAFIO_TECNICO_AVANADE"
dotnet restore
```

### 3. Configurar Connection Strings
Edite os arquivos `appsettings.Development.json` de cada serviço:

**Para SQL Server Express:**
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=ECommerce.Inventory;Trusted_Connection=true;TrustServerCertificate=true;"
}
```

**Para LocalDB:**
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=ECommerce.Inventory;Trusted_Connection=true;"
}
```

### 4. Executar Migrações
```powershell
# Inventory Service
cd src\Services\Inventory\Inventory.API
dotnet ef database update

# Sales Service (quando implementado)
cd ..\..\..\Sales\Sales.API
dotnet ef database update
```

### 5. Executar os Serviços
```powershell
# Terminal 1 - Inventory API
cd src\Services\Inventory\Inventory.API
dotnet run

# Terminal 2 - Sales API
cd src\Services\Sales\Sales.API
dotnet run

# Terminal 3 - Auth API
cd src\Services\Authentication\Auth.API
dotnet run

# Terminal 4 - API Gateway
cd src\Services\Gateway\ApiGateway
dotnet run
```

## 🔧 Scripts de Automação

Execute os scripts na pasta `scripts/` para facilitar o desenvolvimento:

```powershell
# Instalar todas as dependências
.\scripts\install-dependencies.ps1

# Executar todos os serviços
.\scripts\run-all-services.ps1

# Executar apenas um serviço
.\scripts\run-service.ps1 -Service "Inventory"
```

## 🌐 URLs dos Serviços

Após executar os serviços:

- **API Gateway:** http://localhost:5000
- **Inventory API:** http://localhost:5002 
- **Sales API:** http://localhost:5003
- **Auth API:** http://localhost:5001
- **Swagger Docs:** http://localhost:5002/swagger (Inventory)

## 🧪 Testando a API

Use o arquivo `api-tests.http` ou Postman:

```http
### Get all products
GET http://localhost:5002/api/products

### Create product
POST http://localhost:5002/api/products
Content-Type: application/json

{
  "name": "Novo Produto",
  "description": "Descrição do produto",
  "price": 99.99,
  "stock": 100,
  "category": "Test"
}
```

## ❗ Problemas Comuns

### Erro: "dotnet command not found"
- Reinstale o .NET 8.0 SDK
- Reinicie o terminal/VS Code
- Verifique as variáveis de ambiente

### Erro de Connection String
- Verifique se o SQL Server está executando
- Teste a conexão com SQL Server Management Studio
- Use Windows Authentication se possível

### Erro RabbitMQ
- Se não tiver RabbitMQ, comente as linhas relacionadas no `Program.cs`
- Use um serviço online como CloudAMQP
- Ou execute via Docker se disponível

## 🐳 Alternativa com Docker

Se preferir Docker (após instalação):

```powershell
# Na pasta docker/
docker-compose up -d

# Parar os serviços
docker-compose down
```