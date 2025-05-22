#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Inicializando módulos Go para todos los servicios ===${NC}"
echo

# Lista de servicios
SERVICES=(
    "students-get-service"
    "students-create-service"
    "students-getbyid-service"
    "students-update-service"
    "students-delete-service"
)

# Función para inicializar un servicio
init_service() {
    local service=$1
    echo -e "${YELLOW}Inicializando $service...${NC}"
    
    # Entrar al directorio del servicio
    cd "$service" || { echo -e "${RED}Error: No se pudo entrar al directorio $service${NC}"; return 1; }
    
    # Verificar si go.mod ya existe
    if [ -f "go.mod" ]; then
        echo -e "${YELLOW}El archivo go.mod ya existe, actualizando...${NC}"
        # Eliminamos go.mod y go.sum para recrearlos
        rm -f go.mod go.sum
    fi
    
    # Inicializar módulo Go
    module_name="example.com/$service"
    go mod init "$module_name"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al inicializar módulo en $service${NC}"
        cd ..
        return 1
    fi
    
    # Agregar dependencias
    echo -e "${YELLOW}Agregando dependencias...${NC}"
    go get github.com/gorilla/mux
    go get go.mongodb.org/mongo-driver/mongo
    go get go.mongodb.org/mongo-driver/bson
    go get go.mongodb.org/mongo-driver/bson/primitive
    go get github.com/joho/godotenv
    
    # Limpiar y descargar todas las dependencias
    go mod tidy
    
    echo -e "${GREEN}✓ $service inicializado correctamente${NC}"
    
    # Volver al directorio principal
    cd ..
    echo
}

# Inicializar cada servicio
for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
        init_service "$service"
    else
        echo -e "${RED}Error: El directorio $service no existe${NC}"
    fi
done

echo -e "${GREEN}=== Inicialización completada ===${NC}"
echo -e "${YELLOW}Ahora puedes construir las imágenes Docker con:${NC}"
echo -e "docker-compose build"
echo

