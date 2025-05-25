#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables para el seguimiento de la cobertura
total_tests=0
passed_tests=0

# Dirección base de Kubernetes
KUBE_IP="192.168.49.2"

# Función para registrar resultados de pruebas
record_test_result() {
    local result=$1
    total_tests=$((total_tests + 1))
    if [ "$result" = "pass" ]; then
        passed_tests=$((passed_tests + 1))
    fi
}

# Función para mostrar el resumen de cobertura
show_coverage_summary() {
    echo -e "\n${YELLOW}Resumen de Cobertura de Pruebas${NC}"
    echo "================================="
    echo -e "Total de pruebas ejecutadas: ${BLUE}$total_tests${NC}"
    echo -e "Pruebas exitosas: ${GREEN}$passed_tests${NC}"
    echo -e "Pruebas fallidas: ${RED}$((total_tests - passed_tests))${NC}"
    
    if [ "$total_tests" -gt 0 ]; then
        coverage=$((passed_tests * 100 / total_tests))
        echo -e "\nPorcentaje de cobertura: ${YELLOW}${coverage}%${NC}"
        
        # Mostrar barra de progreso
        printf "["
        for ((i=0; i<coverage; i+=2)); do
            printf "#"
        done
        for ((i=coverage; i<100; i+=2)); do
            printf " "
        done
        printf "] ${coverage}%%\n"
    else
        echo -e "\n${RED}No se ejecutaron pruebas${NC}"
    fi
}

echo -e "${BLUE}Iniciando pruebas de todos los servicios...${NC}"
echo "=========================================="

# Función para verificar si un servicio está disponible
check_service() {
    local url=$1
    local service_name=$2
    local max_attempts=5
    local attempt=1

    echo -e "\nVerificando disponibilidad de $service_name..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url/health" > /dev/null; then
            echo -e "${GREEN}✓ $service_name está disponible${NC}"
            record_test_result "pass"
            return 0
        fi
        echo "Intento $attempt de $max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}✗ $service_name no está disponible${NC}"
    record_test_result "fail"
    return 1
}

# Verificar que todos los servicios estén disponibles
services=(
    "http://${KUBE_IP}:30081|Create Service"
    "http://${KUBE_IP}:30082|Get Service"
    "http://${KUBE_IP}:30083|GetById Service"
    "http://${KUBE_IP}:30084|Update Service"
    "http://${KUBE_IP}:30085|Delete Service"
)

for service in "${services[@]}"; do
    IFS="|" read -r url name <<< "$service"
    if ! check_service "$url" "$name"; then
        echo -e "${RED}Error: No se pueden ejecutar las pruebas porque no todos los servicios están disponibles${NC}"
        show_coverage_summary
        exit 1
    fi
done

echo -e "\n${BLUE}Ejecutando pruebas individuales...${NC}"
echo "================================="

# Función para ejecutar prueba y registrar resultado
run_test() {
    local test_script=$1
    local test_name=$2
    echo -e "\n${BLUE}$test_name${NC}"
    
    # Exportar la variable KUBE_IP para que los scripts individuales puedan usarla
    export KUBE_IP
    
    if bash "$test_script"; then
        record_test_result "pass"
    else
        record_test_result "fail"
    fi
}

# Ejecutar las pruebas de cada servicio
run_test "students-create-service/test/test-create.sh" "1. Probando Create Service"
run_test "students-get-service/test/test-get.sh" "2. Probando Get Service"
run_test "students-getbyid-service/test/test-getbyid.sh" "3. Probando GetById Service"
run_test "students-update-service/test/test-update.sh" "4. Probando Update Service"
run_test "students-delete-service/test/test-delete.sh" "5. Probando Delete Service"

echo -e "\n${GREEN}¡Todas las pruebas han sido completadas!${NC}"

# Mostrar el resumen de cobertura al final
show_coverage_summary 