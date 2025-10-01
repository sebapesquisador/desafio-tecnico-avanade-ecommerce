# Script de validacao avancada do sistema
Write-Host "=== Validacao Avancada do Sistema E-Commerce ===" -ForegroundColor Green

Write-Host "`nVerificando pre-requisitos:" -ForegroundColor Yellow

# Verificar .NET com deteccao avancada
$dotnetOK = $false
$dotnetVersion = $null

# Tentar PATH primeiro
try {
    $dotnetVersion = dotnet --version 2>$null
    if ($dotnetVersion) {
        Write-Host "OK .NET SDK no PATH: $dotnetVersion" -ForegroundColor Green
        $dotnetOK = $true
    }
} catch { }

# Se nao encontrar no PATH, procurar nos locais padrao
if (-not $dotnetOK) {
    $dotnetPaths = @(
        "${env:ProgramFiles}\dotnet\dotnet.exe",
        "${env:ProgramFiles(x86)}\dotnet\dotnet.exe",
        "$env:LOCALAPPDATA\Microsoft\dotnet\dotnet.exe"
    )
    
    foreach ($path in $dotnetPaths) {
        if (Test-Path $path) {
            try {
                $dotnetVersion = & $path --version 2>$null
                if ($dotnetVersion) {
                    Write-Host "OK .NET SDK encontrado: $dotnetVersion" -ForegroundColor Green
                    Write-Host "   Local: $path" -ForegroundColor Gray
                    Write-Host "   NOTA: Adicione ao PATH ou reinicie o terminal" -ForegroundColor Yellow
                    $dotnetOK = $true
                    break
                }
            } catch { }
        }
    }
}

if (-not $dotnetOK) {
    Write-Host "FALTA .NET SDK - Baixe em: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Red
}

# Verificar SQL Server
try {
    $sql = sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT 1" 2>$null
    Write-Host "OK SQL Server conectado" -ForegroundColor Green
    $sqlOK = $true
} catch {
    Write-Host "FALTA SQL Server - Configure LocalDB ou use InMemory" -ForegroundColor Yellow
    $sqlOK = $false
}

# Verificar RabbitMQ
$rabbit = netstat -an | findstr ":5672" 2>$null
if ($rabbit) {
    Write-Host "OK RabbitMQ rodando" -ForegroundColor Green
    $rabbitOK = $true
} else {
    Write-Host "FALTA RabbitMQ - Baixe em: https://www.rabbitmq.com/download.html" -ForegroundColor Yellow
    $rabbitOK = $false
}

Write-Host "`nResumo:" -ForegroundColor Cyan
if ($dotnetOK) {
    Write-Host "1. Instalar dependencias: .\scripts\install-dependencies.ps1" -ForegroundColor White
    Write-Host "2. Executar servicos: .\scripts\run-all-services.ps1" -ForegroundColor White
    Write-Host "3. Acessar APIs: http://localhost:5000/swagger" -ForegroundColor White
    
    if (-not $sqlOK -and -not $rabbitOK) {
        Write-Host "`nOPCAO SIMPLES (sem SQL Server/RabbitMQ):" -ForegroundColor Magenta
        Write-Host ".\scripts\run-all-services.ps1 -UseInMemoryDb -SkipRabbitMQ" -ForegroundColor White
    }
} else {
    Write-Host "PRIMEIRO: Instale o .NET SDK 8.0 ou reinicie o terminal" -ForegroundColor Red
}
