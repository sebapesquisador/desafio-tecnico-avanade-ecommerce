# 🚀 Validação Rápida do Sistema

Este script verifica rapidamente se todo o sistema está funcionando corretamente.

```powershell
# Script: quick-test.ps1
Write-Host "=== Validação Rápida - E-Commerce Microservices ===" -ForegroundColor Green

# 1. Verificar pré-requisitos
Write-Host "`n1️⃣ Verificando pré-requisitos..." -ForegroundColor Yellow

# .NET
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET SDK não encontrado!" -ForegroundColor Red
}

# SQL Server
try {
    $sqlConnection = sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT 1" 2>$null
    Write-Host "✅ SQL Server: Conectado" -ForegroundColor Green
} catch {
    Write-Host "⚠️  SQL Server: Verificar conexão" -ForegroundColor Yellow
}

# RabbitMQ
$rabbitMQ = netstat -an | findstr :5672
if ($rabbitMQ) {
    Write-Host "✅ RabbitMQ: Rodando na porta 5672" -ForegroundColor Green
} else {
    Write-Host "⚠️  RabbitMQ: Não detectado na porta 5672" -ForegroundColor Yellow
}

# 2. Verificar compilação
Write-Host "`n2️⃣ Verificando compilação..." -ForegroundColor Yellow
try {
    dotnet build --no-restore > $null 2>&1
    Write-Host "✅ Compilação: Sucesso" -ForegroundColor Green
} catch {
    Write-Host "❌ Compilação: Falhou" -ForegroundColor Red
}

# 3. Testar serviços (se estiverem rodando)
Write-Host "`n3️⃣ Testando serviços..." -ForegroundColor Yellow

$services = @(
    @{ Name = "Auth API"; Url = "http://localhost:5001/health" },
    @{ Name = "Inventory API"; Url = "http://localhost:5002/health" },
    @{ Name = "Sales API"; Url = "http://localhost:5003/health" },
    @{ Name = "API Gateway"; Url = "http://localhost:5000/health" }
)

foreach ($service in $services) {
    try {
        $response = Invoke-RestMethod -Uri $service.Url -TimeoutSec 5
        if ($response -eq "Healthy") {
            Write-Host "✅ $($service.Name): Healthy" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $($service.Name): $response" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($service.Name): Não acessível" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Validação concluída!" -ForegroundColor Green
Write-Host "📋 Para testes detalhados, veja: GUIA_TESTES.md" -ForegroundColor Cyan
```

## ⚡ Executar Validação

```powershell
# Copie e execute no PowerShell na raiz do projeto:
.\quick-test.ps1
```

## 🎯 Resultados Esperados

### ✅ Cenário Ideal
```
=== Validação Rápida - E-Commerce Microservices ===

1️⃣ Verificando pré-requisitos...
✅ .NET SDK: 8.0.x
✅ SQL Server: Conectado  
✅ RabbitMQ: Rodando na porta 5672

2️⃣ Verificando compilação...
✅ Compilação: Sucesso

3️⃣ Testando serviços...
✅ Auth API: Healthy
✅ Inventory API: Healthy
✅ Sales API: Healthy
✅ API Gateway: Healthy

🎯 Validação concluída!
```

### ⚠️ Serviços Não Iniciados
```
3️⃣ Testando serviços...
❌ Auth API: Não acessível
❌ Inventory API: Não acessível
❌ Sales API: Não acessível
❌ API Gateway: Não acessível
```
**Solução:** Execute `.\scripts\run-all-services.ps1`

### ❌ Problemas de Pré-requisitos
```
1️⃣ Verificando pré-requisitos...
❌ .NET SDK não encontrado!
⚠️  SQL Server: Verificar conexão
⚠️  RabbitMQ: Não detectado na porta 5672
```
**Solução:** Siga o [GUIA_TESTES.md](GUIA_TESTES.md) seção "Pré-requisitos"