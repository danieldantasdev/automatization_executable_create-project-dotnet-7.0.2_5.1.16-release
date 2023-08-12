#! /bin/bash

function banner_init(){
echo -e "\e[32m
  ██╗███╗   ██╗██╗ ██████╗██╗ █████╗ ███╗   ██╗██████╗  ██████╗
  ██║████╗  ██║██║██╔════╝██║██╔══██╗████╗  ██║██╔══██╗██╔═══██╗
  ██║██╔██╗ ██║██║██║     ██║███████║██╔██╗ ██║██║  ██║██║   ██║
  ██║██║╚██╗██║██║██║     ██║██╔══██║██║╚██╗██║██║  ██║██║   ██║
  ██║██║ ╚████║██║╚██████╗██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝██╗██╗██╗
  ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝╚═╝╚═╝
\e[0m
"
}

function banner_dotnet7(){
  echo -e "\e[35m
     ███╗   ██╗███████╗████████╗    ███████╗
     ████╗  ██║██╔════╝╚══██╔══╝    ╚════██║
     ██╔██╗ ██║█████╗     ██║           ██╔╝
     ██║╚██╗██║██╔══╝     ██║          ██╔╝
  ██╗██║ ╚████║███████╗   ██║          ██║
  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝          ╚═╝
  \e[0m
  "
}

function banner_menu(){
  echo -e "\e[32m
  ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
  ████╗ ████║██╔════╝████╗  ██║██║   ██║
  ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
  ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
  \e[0m
  "
}

function create_dockerfile(){
  echo "# Stage 1: Build the application" > Dockerfile
  echo "FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build" >> Dockerfile
  echo "WORKDIR /src" >> Dockerfile
  echo "EXPOSE 80" >> Dockerfile
  echo "EXPOSE 443" >> Dockerfile

  echo "# Copy the project files and restore dependencies" >> Dockerfile
  echo "COPY *.sln ." >> Dockerfile
  echo "COPY ${project_name}.Api/*.csproj ./${project_name}.Api/" >> Dockerfile
  echo "COPY ${project_name}.Core/*.csproj ./${project_name}.Core/" >> Dockerfile
  echo "COPY ${project_name}.Infrastructure/*.csproj ./${project_name}.Infrastructure/" >> Dockerfile
  echo "COPY ${project_name}.Application/*.csproj ./${project_name}.Application/" >> Dockerfile
  echo "COPY ${project_name}.UnitTests/*.csproj ./${project_name}.UnitTests/" >> Dockerfile
  echo "RUN dotnet restore" >> Dockerfile

  echo "# Copy the entire solution and build the application" >> Dockerfile
  echo "COPY . ." >> Dockerfile
  echo "WORKDIR /src/${project_name}.Api" >> Dockerfile
  echo "RUN dotnet build -c Release -o /app/publish" >> Dockerfile

  echo "# Stage 2: Publish the application" >> Dockerfile
  echo "FROM build AS publish" >> Dockerfile
  echo "RUN dotnet publish -c Release -o /app/publish" >> Dockerfile

  echo "# Stage 3: Create the final image" >> Dockerfile
  echo "FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final" >> Dockerfile
  echo "WORKDIR /app" >> Dockerfile
  echo "COPY --from=publish /app/publish ." >> Dockerfile
  echo "ENTRYPOINT ["dotnet", "${project_name}.Api.dll"]" >> Dockerfile

  echo "#sudo docker build -f Dockerfile -t smartclub.api . && sudo docker run -d -p 8080:80 --name smartclub.api smartclub.api" >> Dockerfile
}

function create_git_ignore(){
  echo "bin/" > .gitignore
  echo "obj/" >> .gitignore
}

function create_docker_ignore(){
  echo "**/.dockerignore" > .dockerignore
  echo "**/.env" >> .dockerignore
  echo "**/.git" >> .dockerignore
  echo "**/.gitignore" >> .dockerignore
  echo "**/.project" >> .dockerignore
  echo "**/.settings" >> .dockerignore
  echo "**/.toolstarget" >> .dockerignore
  echo "**/.vs" >> .dockerignore
  echo "**/.vscode" >> .dockerignore
  echo "**/.idea" >> .dockerignore
  echo "**/*.*proj.user" >> .dockerignore
  echo "**/*.dbmdl" >> .dockerignore
  echo "**/*.jfm" >> .dockerignore
  echo "**/azds.yaml" >> .dockerignore
  echo "**/bin" >> .dockerignore
  echo "**/charts" >> .dockerignore
  echo "**/docker-compose*" >> .dockerignore
  echo "**/Dockerfile*" >> .dockerignore
  echo "**/node_modules" >> .dockerignore
  echo "**/npm-debug.log" >> .dockerignore
  echo "**/obj" >> .dockerignore
  echo "**/secrets.dev.yaml" >> .dockerignore
  echo "**/values.dev.yaml" >> .dockerignore
  echo "LICENSE" >> .dockerignore
  echo "README.md" >> .dockerignore
}

function main() {
    banner_menu

    echo "Selecione uma opção:"
    echo "1 - Atualizar o sistema"
    echo "2 - Preparar o ambiente de desenvolvimento .net"
    echo "3 - Criar projeto .net com arquitetura limpa"

 read _opcao;
  case $_opcao in
   "1")
        update_system
    ;;
   "2")
        prepare_environment
    ;;
   "3")
        create_project_dotnet_with_clean_architecture
esac
}

function update_system() {
    echo -e "\033[01;32m Atualizando pacotes com o update \033[01;37m!"

    if ! sudo apt update
        then
            echo -e "\033[01;31m Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/source.list \033[01;37m"
            exit 1

        else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Atualizando pacotes com upgrade \033[01;37m!"

    if ! sudo apt upgrade
        then
            echo -e "\033[01;31m Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/source.list \033[01;37m"
            exit 1

        else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Atualizando a distribuição \033[01;37m!"

    if ! sudo apt dist-upgrade -y
        then
            echo -e "\033[01;31m Não foi possível atualizar a distro \033[01;37m"
            exit 1

    else
        echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Atualizando a distribuição de modo full \033[01;37m!"

    if ! sudo apt full-upgrade -y
        then
            echo -e "\033[01;31m Não foi possível atualizar a distro \033[01;37m"
            exit 1

    else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Limpando os pacotes não usados \033[01;37m!"

    if ! sudo apt autoclean
        then
            echo -e "\033[01;31m Não foi possível instalar o pacote \033[01;37m"
            exit 1

    else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Autoremovendo os pacotes não usados \033[01;37m!"

    if ! sudo apt autoremove
        then
            echo -e "\033[01;31m Não foi possível instalar o pacote \033[01;37m"
            exit 1

    else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "\033[01;32m Purgando os pacotes não usados \033[01;37m!"

    if ! sudo apt purge
        then
            echo -e "\033[01;31m Não foi possível instalar o pacote \033[01;37m"
            exit 1

    else
            echo -e "\033[01;32m Atualização feita com sucesso \033[01;37m"
    fi

    echo -e "Instalação finalizada"
}

function prepare_environment_from_dotnet() {
    echo -e "\033[01;32m Preparando o ambiente para .NET \033[01;37m!"

    if ! sudo apt update
    then
        echo -e "\033[01;31m Não foi possível atualizar os repositórios. Verifique seu arquivo /etc/apt/source.list \033[01;37m"
        exit 1
    fi

    echo -e "\033[01;32m Instalando o .NET SDK \033[01;37m!"

    if ! sudo apt install dotnet-sdk-7.0 -y
    then
        echo -e "\033[01;31m Não foi possível instalar o .NET SDK \033[01;37m"
        exit 1
    fi

    echo -e "\033[01;32m .NET SDK instalado com sucesso! \033[01;37m"
}

function create_project_dotnet_with_clean_architecture() {
    banner_dotnet7

    read -p "Informe o nome do projeto: " project_name

    mkdir ${project_name}
    cd ${project_name}

    create_git_ignore
    create_dockerfile
    create_docker_ignore

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
}

main
