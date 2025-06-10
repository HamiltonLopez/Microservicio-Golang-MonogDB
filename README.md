# Sistema de Gestión de Estudiantes - Microservicios con Kubernetes

Este proyecto implementa un sistema de gestión de estudiantes utilizando una arquitectura de microservicios desplegada en Kubernetes. Cada operación CRUD (Create, Read, Update, Delete) está implementada como un servicio independiente, lo que permite una mejor escalabilidad y mantenimiento.

## Arquitectura del Sistema

El sistema está compuesto por los siguientes servicios:

- **students-create-service**: Servicio para crear nuevos estudiantes
- **students-get-service**: Servicio para listar todos los estudiantes
- **students-getbyid-service**: Servicio para obtener un estudiante específico
- **students-update-service**: Servicio para actualizar información de estudiantes
- **students-delete-service**: Servicio para eliminar estudiantes
- **mongodb-service**: Base de datos MongoDB para almacenamiento persistente

## Requisitos Previos

- Kubernetes (Minikube o cualquier otro cluster)
- kubectl configurado
- Docker
- Go (versión 1.16 o superior)

## Configuración del Entorno

1. Iniciar Minikube:
```bash
minikube start
```

2. Habilitar el addon de Ingress (opcional):
```bash
minikube addons enable ingress
```

3. Configurar el contexto de kubectl:
```bash
kubectl config use-context minikube
```

## Despliegue

1. Desplegar MongoDB:
```bash
kubectl apply -f mongodb-service/k8s/
```

2. Desplegar los servicios:
```bash
kubectl apply -f students-create-service/k8s/
kubectl apply -f students-get-service/k8s/
kubectl apply -f students-getbyid-service/k8s/
kubectl apply -f students-update-service/k8s/
kubectl apply -f students-delete-service/k8s/
```

## Verificación del Despliegue

Verificar que todos los servicios están corriendo:
```bash
kubectl get pods
kubectl get svc
```

## Uso del Sistema

### Endpoints Disponibles

- **Crear Estudiante**: POST http://localhost:30081/students
- **Listar Estudiantes**: GET http://localhost:30082/students
- **Obtener Estudiante**: GET http://localhost:30083/students/{id}
- **Actualizar Estudiante**: PUT http://localhost:30084/students/{id}
- **Eliminar Estudiante**: DELETE http://localhost:30085/students/{id}

## Scripts de Utilidad

- **init-services.sh**: Script para inicializar todos los servicios
- **test-services.sh**: Script para probar la funcionalidad de los servicios

## Estructura del Proyecto

```
.
├── mongodb-service/
├── students-create-service/
├── students-get-service/
├── students-getbyid-service/
├── students-update-service/
├── students-delete-service/
├── docker-compose.yml
├── init-services.sh
├── test-services.sh
└── README.md
```

## Mantenimiento y Monitoreo

### Logs de los Servicios
```bash
kubectl logs -f deployment/<nombre-del-deployment>
```

### Escalamiento de Servicios
```bash
kubectl scale deployment/<nombre-del-deployment> --replicas=<número>
```

## Solución de Problemas

1. **Problemas de Conexión con MongoDB**:
   - Verificar que el servicio de MongoDB está corriendo
   - Comprobar la cadena de conexión en los deployments
   - Verificar los logs de MongoDB

2. **Servicios no Accesibles**:
   - Comprobar el estado de los pods
   - Verificar la configuración de los servicios
   - Revisar los logs de los pods

## Contribución

Para contribuir al proyecto:

1. Fork del repositorio
2. Crear una rama para la nueva característica
3. Commit de los cambios
4. Push a la rama
5. Crear un Pull Request

