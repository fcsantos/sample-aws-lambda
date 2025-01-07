# sample-aws-lambda

# AWS Lambda .NET Deployment Guide

Este guia fornece instruções passo a passo para publicar uma função AWS Lambda usando .NET 8.0.

## Pré-requisitos

- [.NET SDK 8.0](https://dotnet.microsoft.com/download/dotnet/8.0) instalado
- [AWS CLI](https://aws.amazon.com/cli/) configurado com suas credenciais
- [Terraform](https://www.terraform.io/downloads.html) instalado (versão >= 0.13)
- [Git](https://git-scm.com/downloads) instalado

## Instalação das Ferramentas AWS Lambda

1. Instale a ferramenta Amazon.Lambda.Tools globalmente:
```bash
dotnet tool install -g Amazon.Lambda.Tools
```

Para atualizar uma instalação existente:
```bash
dotnet tool update -g Amazon.Lambda.Tools
```

## Estrutura do Projeto

```plaintext
.
├── AWSLambdaSample/
│     ├── Function.cs
│     └── AWSLambdaSample.csproj
├── terraform/
│   ├── main.tf
└── README.md
```

## Passos para Publicação

### 1. Preparação do Projeto

1. Clone o repositório:
```bash
git clone <seu-repositorio>
cd <seu-repositorio>
```

2. Restaure as dependências:
```bash
dotnet restore
```

### 2. Publicação Local

1. Publique o projeto usando Amazon.Lambda.Tools:
```bash
cd AWSLambdaSample
dotnet lambda package -c Release -f net8.0 -o ../../publish/aws-lambda-sample.zip
```

Ou, se preferir usar o comando dotnet publish:
```bash
dotnet publish -c Release \
--runtime linux-x64 \
--self-contained false \
/p:PublishReadyToRun=true \
-o ./publish
```

Se usar dotnet publish, empacote os arquivos manualmente:
```bash
cd publish
zip -r ../../../publish/aws-lambda-sample.zip *
```

### 3. Verificação do Pacote

Verifique se todos os arquivos necessários estão no ZIP:
```bash
unzip -l publish/aws-lambda-sample.zip
```

Você deve ver os seguintes arquivos:
- `AWSLambdaSample.dll`
- `AWSLambdaSample.deps.json`
- `AWSLambdaSample.runtimeconfig.json`
- Outras DLLs de dependências

### 4. Deployment com Terraform

1. Navegue até a pasta terraform:
```bash
cd terraform
```

2. Inicialize o Terraform:
```bash
terraform init
```

3. Verifique as mudanças planejadas:
```bash
terraform plan
```

4. Aplique as mudanças:
```bash
terraform apply
```

## Estrutura do Terraform

Seu arquivo `main.tf` deve conter:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = "eu-west-1"  # ou sua região preferida
}

resource "aws_lambda_function" "lambda_function" {
  filename         = "../publish/aws-lambda-sample.zip"
  function_name    = "my_lambda_function"
  role            = aws_iam_role.lambda_exec_role.arn
  handler         = "AWSLambdaSample::AWSLambdaSample.Function::FunctionHandler"
  runtime         = "dotnet8.0"
  source_code_hash = filebase64sha256("../publish/aws-lambda-sample.zip")

  environment {
    variables = {
      ASPNETCORE_ENVIRONMENT = "Production"
    }
  }
}

# ... resto do código Terraform ...
```

## Testes

Para testar a função localmente antes do deploy:
```bash
dotnet lambda invoke-function my_lambda_function --payload "{ }"
```

## Troubleshooting

### Problemas Comuns

1. **Erro: Missing .deps.json**
   - Certifique-se de usar o comando `dotnet lambda package`
   - Verifique se o arquivo está presente no ZIP

2. **Erro: Handler não encontrado**
   - Verifique se o handler no Terraform corresponde exatamente ao namespace e classe

3. **Erro: Permissões IAM**
   - Verifique se a role IAM tem as políticas corretas anexadas

## Limpeza

Para remover os recursos da AWS:
```bash
terraform destroy
```

## Notas Adicionais

- Mantenha suas dependências atualizadas
- Use variáveis de ambiente para configurações
- Implemente logs adequados usando ILogger
- Configure o timeout da função adequadamente
- Monitore o uso de memória

## Contribuindo

1. Fork o projeto
2. Crie sua branch de feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Suporte

Para suporte, abra uma issue no repositório GitHub.
