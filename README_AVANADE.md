# 🚀 E-Commerce Microservices Platform - Desafio Técnico Avanade

## 📋 Sobre o Projeto

Sistema de e-commerce baseado em **arquitetura de microserviços** desenvolvido em **.NET Core 8**, implementando gestão completa de estoque, vendas e autenticação com comunicação assíncrona via **RabbitMQ** e **API Gateway** centralizado.

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐
│   Client Apps   │    │   Web Browser   │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
        ┌────────────▼────────────┐
        │     API Gateway         │
        │     (Ocelot)           │
        │     Port: 5000         │
        └─────────┬──┬──┬─────────┘
                  │  │  │
     ┌────────────┘  │  └────────────┐
     │               │               │
┌────▼─────┐  ┌─────▼─────┐  ┌──────▼──────┐
│Auth.API  │  │Sales.API  │  │Inventory.API│
│Port:5001 │  │Port:5003  │  │Port:5002    │
└────┬─────┘  └─────┬─────┘  └──────┬──────┘
     │              │               │
     └──────────────┼───────────────┘
                    │
           ┌────────▼────────┐
           │    RabbitMQ     │
           │  Message Bus    │
           └─────────────────┘
```

## 🎯 Funcionalidades Implementadas

### ✅ **Inventory Service (Port 5002)**
- **CRUD completo de produtos**
- **Controle de estoque em tempo real**
- **Eventos de atualização de estoque**
- **Validações de negócio**
- **Swagger UI integrado**

### ✅ **Sales Service (Port 5003)**
- **Gestão completa de pedidos**
- **Validação de estoque antes da venda**
- **Integração com Inventory via eventos**
- **Histórico de pedidos**
- **Swagger UI integrado**

### ✅ **Auth Service (Port 5001)**
- **Autenticação JWT completa**
- **Registro de usuários**
- **Refresh tokens**
- **Controle de roles (Admin/User)**
- **Swagger UI integrado**

### ✅ **API Gateway (Port 5000)**
- **Roteamento centralizado**
- **Autenticação JWT integrada**
- **Load balancing**
- **Rate limiting**

## 🛠️ Tecnologias Utilizadas

| Categoria | Tecnologia | Versão |
|-----------|------------|--------|
| **Framework** | .NET Core | 8.0 |
| **Linguagem** | C# | 12.0 |
| **ORM** | Entity Framework Core | 8.0.0 |
| **API Gateway** | Ocelot | 23.1.0 |
| **Message Broker** | RabbitMQ | 6.8.1 |
| **Authentication** | JWT Bearer | 7.0.3 |
| **Logging** | Serilog | 8.0.0 |
| **Documentation** | Swagger/OpenAPI | 6.6.2 |
| **Testing** | xUnit + Moq + FluentAssertions | Latest |
| **Validation** | FluentValidation | 11.8.0 |
| **Containerization** | Docker + Docker Compose | Latest |

## 🏛️ Padrões de Arquitetura

- **Clean Architecture** - Separação clara entre camadas
- **Repository Pattern** - Abstração de acesso a dados
- **Unit of Work** - Gerenciamento de transações
- **CQRS** - Separação de comandos e consultas
- **Domain-Driven Design (DDD)** - Modelagem orientada ao domínio
- **Event-Driven Architecture** - Comunicação via eventos
- **API-First Design** - APIs RESTful bem documentadas

## 🚀 Como Executar

### **Pré-requisitos**
- .NET Core 8.0 SDK
- Docker Desktop (opcional)
- RabbitMQ (ou Docker)
- SQL Server (ou usar InMemory)

### **Executar Localmente**

1. **Restaurar dependências**
```bash
dotnet restore
```

2. **Executar todos os serviços**
```bash
# Terminal 1 - Auth API
dotnet run --project src/Services/Authentication/Auth.API

# Terminal 2 - Inventory API  
dotnet run --project src/Services/Inventory/Inventory.API

# Terminal 3 - Sales API
dotnet run --project src/Services/Sales/Sales.API

# Terminal 4 - API Gateway
dotnet run --project src/Services/Gateway/ApiGateway
```

### **Executar com Docker**
```bash
docker-compose up -d
```

## 📚 Documentação das APIs

Após executar os serviços, acesse:

- **API Gateway:** http://localhost:5000
- **Auth API:** http://localhost:5001/swagger
- **Inventory API:** http://localhost:5002/swagger  
- **Sales API:** http://localhost:5003/swagger

## 🔐 Autenticação

### **Usuários de Teste**
```json
{
  "username": "admin",
  "password": "Admin123!"
}
```

```json
{
  "username": "joao", 
  "password": "User123!"
}
```

### **Fluxo de Autenticação**
1. POST `/api/Auth/login` - Obter token JWT
2. Incluir header: `Authorization: Bearer {token}`
3. Acessar endpoints protegidos

## 🧪 Testes

```bash
# Executar todos os testes
dotnet test

# Executar com cobertura
dotnet test --collect:"XPlat Code Coverage"
```

### **Cobertura de Testes**
- ✅ Testes unitários para Controllers
- ✅ Testes unitários para Services  
- ✅ Testes de integração para APIs
- ✅ Testes de validação de DTOs
- ✅ Mocks para dependências externas

## 🔄 Comunicação entre Microserviços

### **Eventos Implementados**
- `ProductStockUpdatedEvent` - Atualização de estoque
- `OrderCreatedEvent` - Criação de pedido
- `OrderConfirmedEvent` - Confirmação de pedido

### **Fluxo de Venda**
1. Cliente cria pedido no Sales.API
2. Sales.API valida estoque via Inventory.API
3. Pedido confirmado → evento `OrderConfirmedEvent`
4. Inventory.API recebe evento e atualiza estoque
5. Inventory.API publica `ProductStockUpdatedEvent`

## 📁 Estrutura do Projeto

```
src/
├── Services/
│   ├── Authentication/Auth.API/     # Microserviço de Autenticação
│   ├── Inventory/                   # Microserviço de Estoque
│   │   ├── Inventory.API/           # API Layer
│   │   ├── Inventory.Core/          # Domain Layer  
│   │   └── Inventory.Infrastructure/ # Data Layer
│   ├── Sales/                       # Microserviço de Vendas
│   │   ├── Sales.API/               # API Layer
│   │   ├── Sales.Core/              # Domain Layer
│   │   └── Sales.Infrastructure/    # Data Layer
│   └── Gateway/ApiGateway/          # API Gateway
├── Shared/
│   ├── Common/                      # Modelos compartilhados
│   ├── Contracts/                   # Contratos de eventos
│   └── EventBus/                    # Implementação do EventBus
└── tests/                           # Testes unitários e integração
```

## 🌟 Destaques do Projeto

### **Qualidade de Código**
- ✅ **SOLID Principles** aplicados
- ✅ **Clean Code** practices
- ✅ **Design Patterns** (Repository, Factory, Observer)
- ✅ **Exception Handling** robusto
- ✅ **Input Validation** com FluentValidation

### **Segurança**
- ✅ **JWT Authentication** com refresh tokens
- ✅ **Role-based Authorization**
- ✅ **Input Sanitization**
- ✅ **CORS** configurado
- ✅ **HTTPS** suportado

### **Performance**
- ✅ **Async/Await** em todas operações I/O
- ✅ **Connection Pooling**
- ✅ **Caching** strategies
- ✅ **Lazy Loading** otimizado

### **Escalabilidade**
- ✅ **Microservices Architecture**
- ✅ **Event-Driven Communication**
- ✅ **Stateless Services**
- ✅ **Docker Support**
- ✅ **Load Balancing** ready

## 🔧 Configurações

### **Ambientes Suportados**
- **Development** - InMemory Database
- **Production** - SQL Server + RabbitMQ

### **Configuração via appsettings.json**
```json
{
  "DatabaseType": "InMemory", // ou "SqlServer"
  "UseRealEventBus": true,    // RabbitMQ ou Mock
  "Logging": {
    "Level": "Information"
  }
}
```

## 👥 Contribuição

Este projeto foi desenvolvido como parte do **Desafio Técnico da Avanade**, demonstrando competências em:

- **Arquitetura de Microserviços**
- **Domain-Driven Design**
- **Event-Driven Architecture**  
- **Clean Code & SOLID**
- **DevOps & Containerization**
- **Testing & Quality Assurance**

---

**Desenvolvido com ❤️ para o Desafio Técnico Avanade**

*Sistema de E-Commerce Microservices - Demonstração de competências técnicas em .NET Core e arquitetura de microsserviços para ambientes enterprise.*