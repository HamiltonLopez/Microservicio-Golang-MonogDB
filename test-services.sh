#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Prueba de Microservicios de Estudiantes ===${NC}"
echo -e "${YELLOW}Este script probará todos los endpoints de la API${NC}"
echo

# Definir las URLs base
CREATE_URL="http://localhost:8082/students"
GET_ALL_URL="http://localhost:8081/students"
GETBYID_URL="http://localhost:8083/students"
UPDATE_URL="http://localhost:8084/students"
DELETE_URL="http://localhost:8085/students"

# 1. Crear un nuevo estudiante
echo -e "${YELLOW}1. Creando un nuevo estudiante...${NC}"
CREATE_RESPONSE=$(curl -s -X POST $CREATE_URL \
  -H "Content-Type: application/json" \
  -d '{"name":"Estudiante de Prueba","age":25,"email":"test@example.com"}')

# Verificar si la respuesta contiene id
if echo $CREATE_RESPONSE | grep -q "id"; then
  # Extraer ID del estudiante creado (utilizando herramientas de procesamiento de JSON)
  # Usamos jq si está disponible, si no, usamos grep y cut para una aproximación
  if command -v jq &> /dev/null; then
    STUDENT_ID=$(echo $CREATE_RESPONSE | jq -r '.id')
  else
    STUDENT_ID=$(echo $CREATE_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)
  fi
  
  echo -e "${GREEN}✓ Estudiante creado exitosamente con ID: $STUDENT_ID${NC}"
  echo "$CREATE_RESPONSE" | grep -v "password" | tr -d '{}' | sed 's/,/\n/g' | sed 's/"//g' | sed 's/:/: /g'
else
  echo -e "${RED}✗ Error al crear estudiante. Respuesta: $CREATE_RESPONSE${NC}"
  exit 1
fi

echo

# 2. Obtener todos los estudiantes
echo -e "${YELLOW}2. Obteniendo todos los estudiantes...${NC}"
GET_ALL_RESPONSE=$(curl -s -X GET $GET_ALL_URL)

if echo $GET_ALL_RESPONSE | grep -q "students"; then
  echo -e "${GREEN}✓ Estudiantes obtenidos correctamente${NC}"
  echo -e "${YELLOW}Lista resumida de estudiantes:${NC}"
  echo "$GET_ALL_RESPONSE" | grep -o '"name":"[^"]*' | cut -d'"' -f4 | sort | sed 's/^/- /'
else
  echo -e "${RED}✗ Error al obtener estudiantes. Respuesta: $GET_ALL_RESPONSE${NC}"
fi

echo

# 3. Obtener estudiante por ID
echo -e "${YELLOW}3. Obteniendo estudiante con ID: $STUDENT_ID${NC}"
GET_BY_ID_RESPONSE=$(curl -s -X GET "$GETBYID_URL/$STUDENT_ID")

if echo $GET_BY_ID_RESPONSE | grep -q "student"; then
  echo -e "${GREEN}✓ Estudiante encontrado${NC}"
  echo "$GET_BY_ID_RESPONSE" | grep -v "password" | tr -d '{}' | sed 's/,/\n/g' | sed 's/"//g' | sed 's/:/: /g' | grep -v "message"
else
  echo -e "${RED}✗ Error al buscar estudiante. Respuesta: $GET_BY_ID_RESPONSE${NC}"
fi

echo

# 4. Actualizar el estudiante
echo -e "${YELLOW}4. Actualizando estudiante con ID: $STUDENT_ID${NC}"
UPDATE_RESPONSE=$(curl -s -X PUT "$UPDATE_URL/$STUDENT_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"Estudiante Actualizado","age":26,"email":"updated@example.com"}')

if echo $UPDATE_RESPONSE | grep -q "actualizado"; then
  echo -e "${GREEN}✓ Estudiante actualizado correctamente${NC}"
  echo "$UPDATE_RESPONSE" | grep -v "password" | tr -d '{}' | sed 's/,/\n/g' | sed 's/"//g' | sed 's/:/: /g' | grep -v "message"
else
  echo -e "${RED}✗ Error al actualizar estudiante. Respuesta: $UPDATE_RESPONSE${NC}"
fi

echo

# 5. Obtener el estudiante actualizado
echo -e "${YELLOW}5. Verificando la actualización del estudiante con ID: $STUDENT_ID${NC}"
GET_UPDATED_RESPONSE=$(curl -s -X GET "$GETBYID_URL/$STUDENT_ID")

if echo $GET_UPDATED_RESPONSE | grep -q "Estudiante Actualizado"; then
  echo -e "${GREEN}✓ Estudiante actualizado verificado${NC}"
  echo "$GET_UPDATED_RESPONSE" | grep -v "password" | tr -d '{}' | sed 's/,/\n/g' | sed 's/"//g' | sed 's/:/: /g' | grep -v "message"
else
  echo -e "${RED}✗ Error al verificar la actualización. Respuesta: $GET_UPDATED_RESPONSE${NC}"
fi

echo

# 6. Eliminar el estudiante
echo -e "${YELLOW}6. Eliminando estudiante con ID: $STUDENT_ID${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE "$DELETE_URL/$STUDENT_ID" -w "%{http_code}")

# Verificar si el código de estado es 204 (No Content)
if [[ "$DELETE_RESPONSE" == "204" ]]; then
  echo -e "${GREEN}✓ Estudiante eliminado correctamente${NC}"
else
  echo -e "${RED}✗ Error al eliminar estudiante. Código de respuesta: $DELETE_RESPONSE${NC}"
fi

echo

# 7. Verificar que el estudiante fue eliminado
echo -e "${YELLOW}7. Verificando que el estudiante fue eliminado...${NC}"
CHECK_DELETED_RESPONSE=$(curl -s -X GET "$GETBYID_URL/$STUDENT_ID")

if echo $CHECK_DELETED_RESPONSE | grep -q "encontrado" || echo $CHECK_DELETED_RESPONSE | grep -q "404"; then
  echo -e "${GREEN}✓ Confirmado: El estudiante ya no existe${NC}"
else
  echo -e "${RED}✗ Error: El estudiante aún existe. Respuesta: $CHECK_DELETED_RESPONSE${NC}"
fi

echo
echo -e "${GREEN}=== Prueba de servicios completada ===${NC}"

