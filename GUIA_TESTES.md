# 🧪 Guia Completo de Testes - E-Commerce Microservices

Este guia fornece instruções detalhadas para testar todo o sistema de microserviços e verificar se está funcionando corretamente.

## 📋 Pré-requisitos

### 1. Software Necessário
- ✅ **.NET 8.0 SDK** - [Download aqui](https://dotnet.microsoft.com/download/dotnet/8.0)
- ✅ **SQL Server** (LocalDB ou Express) - [Download aqui](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- ✅ **RabbitMQ** - [Download aqui](https://www.rabbitmq.com/download.html)
- ✅ **Visual Studio Code** com extensões:
  - REST Client
  - C# Dev Kit

### 2. Verificação de Pré-requisitos
```powershell
# Verificar .NET
dotnet --version
# Deve mostrar: 8.0.x

# Verificar SQL Server
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT @@VERSION"

# Verificar RabbitMQ (deve estar rodando na porta 5672)
netstat -an | findstr :5672
```

## 🚀 Passo a Passo para Testar o Sistema

### Etapa 1: Preparação do Ambiente

#### 1.1. Clonar e Configurar Projeto
```powershell
cd C:\Users\sebas\Music\DESAFIO_TECNICO_AVANADE

# Restaurar dependências
dotnet restore

# Compilar todos os projetos
dotnet build
```

#### 1.2. Configurar Banco de Dados
```powershell
# Executar migrations para todos os serviços
cd src\Services\Inventory\Inventory.API
dotnet ef database update

cd ..\..\..\Services\Sales\Sales.API
dotnet ef database update

cd ..\..\..\Services\Authentication\Auth.API
dotnet ef database update
```

#### 1.3. Iniciar RabbitMQ
```powershell
# No Windows (se instalado como serviço)
net start RabbitMQ

# Ou executar manualmente
rabbitmq-server

# Verificar se está funcionando
# Acesse: http://localhost:15672 (user: guest, password: guest)
```

### Etapa 2: Executar os Serviços

#### 2.1. Executar Serviços Individualmente
```powershell
# Terminal 1: Authentication Service (porta 5001)
cd src\Services\Authentication\Auth.API
dotnet run

# Terminal 2: Inventory Service (porta 5002)
cd src\Services\Inventory\Inventory.API
dotnet run

# Terminal 3: Sales Service (porta 5003)
cd src\Services\Sales\Sales.API
dotnet run

# Terminal 4: API Gateway (porta 5000)
cd src\Services\Gateway\ApiGateway
dotnet run
```

#### 2.2. Ou Usar Tasks do VS Code
```powershell
# No VS Code, pressione Ctrl+Shift+P e digite:
"Tasks: Run Task" > "Start All Services"
```

### Etapa 3: Verificação de Saúde dos Serviços

#### 3.1. Health Checks
```powershell
# Authentication Service
Invoke-RestMethod -Uri "http://localhost:5001/health"

# Inventory Service
Invoke-RestMethod -Uri "http://localhost:5002/health"

# Sales Service
Invoke-RestMethod -Uri "http://localhost:5003/health"

# API Gateway
Invoke-RestMethod -Uri "http://localhost:5000/health"
```

**Resultado Esperado:** Todos devem retornar `"Healthy"`

#### 3.2. Swagger UI
- **Auth API**: http://localhost:5001/swagger
- **Inventory API**: http://localhost:5002/swagger
- **Sales API**: http://localhost:5003/swagger
- **Gateway**: http://localhost:5000/swagger

### Etapa 4: Testes de Funcionalidade

#### 4.1. Teste de Autenticação

**Registrar Usuário:**
```http
POST http://localhost:5001/api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "Test123!",
  "confirmPassword": "Test123!"
}
```

**Fazer Login:**
```http
POST http://localhost:5001/api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "Test123!"
}
```

**Resultado Esperado:** Token JWT no response

#### 4.2. Teste do Inventory Service

**Criar Produto:**
```http
POST http://localhost:5002/api/products
Content-Type: application/json
Authorization: Bearer SEU_TOKEN_AQUI

{
  "name": "Notebook Gamer",
  "description": "Notebook para jogos",
  "price": 2999.99,
  "stock": 10,
  "category": "Electronics"
}
```

**Listar Produtos:**
```http
GET http://localhost:5002/api/products
```

**Verificar Estoque:**
```http
GET http://localhost:5002/api/products/{PRODUCT_ID}/stock
```

#### 4.3. Teste do Sales Service

**Criar Pedido:**
```http
POST http://localhost:5003/api/orders
Content-Type: application/json
Authorization: Bearer SEU_TOKEN_AQUI

{
  "customerId": "customer-123",
  "items": [
    {
      "productId": "PRODUCT_ID_AQUI",
      "quantity": 2,
      "unitPrice": 2999.99
    }
  ]
}
```

#### 4.4. Teste via API Gateway

**Acessar Inventory via Gateway:**
```http
GET http://localhost:5000/api/inventory/products
Authorization: Bearer SEU_TOKEN_AQUI
```

**Acessar Sales via Gateway:**
```http
GET http://localhost:5000/api/sales/orders
Authorization: Bearer SEU_TOKEN_AQUI
```

### Etapa 5: Teste de Comunicação Assíncrona (RabbitMQ)

#### 5.1. Verificar Eventos
1. **Criar um produto** no Inventory Service
2. **Verificar logs** do Sales Service para confirmar que recebeu o evento
3. **Criar um pedido** no Sales Service
4. **Verificar logs** do Inventory Service para confirmar atualização de estoque

#### 5.2. Monitorar RabbitMQ
- Acesse: http://localhost:15672
- Verifique as filas: `inventory-events`, `sales-events`
- Confirme que mensagens estão sendo processadas

### Etapa 6: Testes Automatizados

```powershell
# Executar todos os testes
dotnet test

# Testes por projeto
dotnet test tests/Auth.Tests
dotnet test tests/Inventory.Tests
dotnet test tests/Sales.Tests

# Testes com relatório detalhado
dotnet test --logger "console;verbosity=detailed"
```

## 🔍 Verificação de Problemas Comuns

### Problema 1: Porta em Uso
```powershell
# Verificar quais portas estão em uso
netstat -an | findstr ":5000\|:5001\|:5002\|:5003"

# Matar processo em porta específica
netstat -ano | findstr :5002
taskkill /F /PID PROCESS_ID
```

### Problema 2: Banco de Dados
```powershell
# Verificar conexão com SQL Server
sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT 1"

# Recriar banco se necessário
dotnet ef database drop --force
dotnet ef database update
```

### Problema 3: RabbitMQ
```powershell
# Verificar status do RabbitMQ
rabbitmq-diagnostics status

# Reiniciar serviço
net stop RabbitMQ
net start RabbitMQ
```

### Problema 4: Token JWT Expirado
- Tokens têm validade de 1 hora
- Faça login novamente para obter novo token
- Use o endpoint `/api/auth/refresh` se implementado

## 📊 Checklist de Verificação

### ✅ Pré-requisitos
- [ ] .NET 8.0 instalado
- [ ] SQL Server funcionando
- [ ] RabbitMQ funcionando
- [ ] Portas 5000-5003 livres

### ✅ Serviços
- [ ] Auth API respondendo na porta 5001
- [ ] Inventory API respondendo na porta 5002
- [ ] Sales API respondendo na porta 5003
- [ ] API Gateway respondendo na porta 5000

### ✅ Funcionalidades
- [ ] Autenticação funciona (login/register)
- [ ] CRUD de produtos funciona
- [ ] Criação de pedidos funciona
- [ ] Roteamento via Gateway funciona
- [ ] Eventos RabbitMQ sendo processados

### ✅ Testes
- [ ] Health checks retornam "Healthy"
- [ ] Swagger UI acessível
- [ ] Testes automatizados passando
- [ ] Logs sendo gerados

## 🎯 Cenários de Teste Completos

### Cenário 1: Fluxo de E-commerce Completo
1. Registrar usuário
2. Fazer login
3. Criar produto
4. Verificar estoque
5. Criar pedido
6. Verificar redução de estoque
7. Consultar pedido criado

### Cenário 2: Teste de Integração
1. Criar produto via Inventory API
2. Verificar se evento foi publicado no RabbitMQ
3. Confirmar que Sales API recebeu o evento
4. Criar pedido para o produto
5. Verificar se estoque foi reduzido

### Cenário 3: Teste via API Gateway
1. Autenticar via Gateway
2. Criar produto via Gateway
3. Criar pedido via Gateway
4. Verificar logs centralizados

## 🔧 Comandos Úteis

```powershell
# Ver logs em tempo real
Get-Content src\Services\Inventory\Inventory.API\logs\*.txt -Wait -Tail 50

# Verificar processos .NET rodando
Get-Process dotnet

# Limpar e reconstruir solução
dotnet clean
dotnet build

# Restaurar banco do zero
dotnet ef database drop --force --project src\Services\Inventory\Inventory.API
dotnet ef database update --project src\Services\Inventory\Inventory.API
```

---

**✅ Se todos os testes passarem, seu sistema está funcionando corretamente!**