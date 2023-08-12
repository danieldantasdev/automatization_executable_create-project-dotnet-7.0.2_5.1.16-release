#! /bin/bash

read -p "Informe o nome do projeto: " project_name

mkdir ${project_name}
cd ${project_name}

dotnet new sln --name ${project_name}

dotnet new classlib -n ${project_name}.Core
dotnet new classlib -n ${project_name}.Application
dotnet new classlib -n ${project_name}.Persistence
dotnet new webapi -n ${project_name}.Api

dotnet sln add ./${project_name}.Core/${project_name}.Core.csproj
dotnet sln add ./${project_name}.Application/${project_name}.Application.csproj
dotnet sln add ./${project_name}.Persistence/${project_name}.Persistence.csproj
dotnet sln add ./${project_name}.Api/${project_name}.Api.csproj

dotnet add ./${project_name}.Api/${project_name}.Api.csproj reference ./${project_name}.Application/${project_name}.Application.csproj
dotnet add ./${project_name}.Api/${project_name}.Api.csproj reference ./${project_name}.Persistence/${project_name}.Persistence.csproj
dotnet add ./${project_name}.Application/${project_name}.Application.csproj reference ./${project_name}.Core/${project_name}.Core.csproj
dotnet add ./${project_name}.Persistence/${project_name}.Persistence.csproj reference ./${project_name}.Core/${project_name}.Core.csproj

dotnet restore

echo "Projeto $project_name criado com sucesso com referência ao C#!"
