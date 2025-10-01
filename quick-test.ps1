# Script de Validacao Rapida - E-Commerce Microservices
# Executa verificacoes basicas para confirmar que o sistema esta funcionando

Write-Host "=== Validacao Rapida - E-Commerce Microservices ===" -ForegroundColor Green

# 1. Verificar pre-requisitos
Write-Host "`n1. Verificando pre-requisitos..." -ForegroundColor Yellow

# .NET
try {
    $dotnetVersion = dotnet --version 2>$null
    if ($dotnetVersion) {
        Write-Host "OK .NET SDK: $dotnetVersion" -ForegroundColor Green
    } else {
        throw "Nao encontrado"
    }
} catch {
    Write-Host "ERRO .NET SDK nao encontrado!" -ForegroundColor Red
    Write-Host "   Baixe em: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
}

# SQL Server
try {
    $sqlResult = sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT 1" 2>$null
    if ($sqlResult) {
        Write-Host "OK SQL Server: Conectado" -ForegroundColor Green
    } else {
        throw "Falha na conexao"
    }
} catch {
    Write-Host "AVISO SQL Server: Verificar conexao" -ForegroundColor Yellow
}

# RabbitMQ
$rabbitMQPort = netstat -an | findstr ":5672"
if ($rabbitMQPort) {
    Write-Host "OK RabbitMQ: Rodando" -ForegroundColor Green
} else {
    Write-Host "AVISO RabbitMQ: Nao detectado" -ForegroundColor Yellow
}

# 2. Verificar compilacao
Write-Host "`n2. Verificando compilacao..." -ForegroundColor Yellow
try {
    $buildResult = dotnet build --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK Compilacao: Sucesso" -ForegroundColor Green
    } else {
        Write-Host "ERRO Compilacao: Falhou" -ForegroundColor Red
    }
} catch {
    Write-Host "ERRO Compilacao: Erro ao executar" -ForegroundColor Red
}

# 3. Testar servicos
Write-Host "`n3. Testando servicos..." -ForegroundColor Yellow

$services = @(
    @{ Name = "Auth API"; Url = "http://localhost:5001/health" }
    @{ Name = "Inventory API"; Url = "http://localhost:5002/health" }
    @{ Name = "Sales API"; Url = "http://localhost:5003/health" }
    @{ Name = "API Gateway"; Url = "http://localhost:5000/health" }
)

$runningServices = 0
foreach ($service in $services) {
    try {
        $response = Invoke-RestMethod -Uri $service.Url -TimeoutSec 3 -ErrorAction Stop
        if ($response -eq "Healthy") {
            Write-Host "OK $($service.Name): Healthy" -ForegroundColor Green
            $runningServices++
        } else {
            Write-Host "AVISO $($service.Name): $response" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "OFFLINE $($service.Name): Nao iniciado" -ForegroundColor Gray
    }
}

# 4. Resumo
Write-Host "`nResumo da Validacao:" -ForegroundColor Green

if ($runningServices -eq 4) {
    Write-Host "PERFEITO! Todos os servicos estao rodando!" -ForegroundColor Green
    Write-Host "   Acesse: http://localhost:5000/swagger" -ForegroundColor Cyan
} elseif ($runningServices -gt 0) {
    Write-Host "Alguns servicos rodando ($runningServices/4)" -ForegroundColor Yellow
    Write-Host "   Para iniciar todos: .\scripts\run-all-services.ps1" -ForegroundColor Cyan
} else {
    Write-Host "Nenhum servico detectado rodando" -ForegroundColor Yellow
    Write-Host "   Para iniciar: .\scripts\run-all-services.ps1" -ForegroundColor Cyan
}

Write-Host "`nProximos passos:" -ForegroundColor Cyan
Write-Host "   Testes detalhados: GUIA_TESTES.md" -ForegroundColor White
Write-Host "   Scripts disponiveis: .\scripts\" -ForegroundColor White
Write-Host "   Documentacao: README.md" -ForegroundColor White

Write-Host "`nValidacao concluida!" -ForegroundColor Green