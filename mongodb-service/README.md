# MongoDB Service

Este servicio proporciona la capa de persistencia de datos para todos los microservicios del sistema de gestión de estudiantes.

## Componentes

- **Deployment**: Gestiona el pod de MongoDB
- **Service**: Expone MongoDB a otros servicios
- **PersistentVolume (PV)**: Proporciona almacenamiento persistente
- **PersistentVolumeClaim (PVC)**: Reclama el almacenamiento para MongoDB

## Configuración

### Deployment
- **Imagen**: mongo:latest
- **Puerto**: 27017
- **Volumen**: Montado en `/data/db`

### Service
- **Tipo**: ClusterIP
- **Puerto**: 27017
- **Nombre**: mongo-service

### Persistencia
- **PV**: Almacenamiento local
- **PVC**: Reclama el almacenamiento del PV

## Estructura de Archivos

```
mongodb-service/
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pv.yaml
│   └── pvc.yaml
└── README.md
```

## Despliegue

```bash
kubectl apply -f k8s/
```

## Verificación

1. Verificar el pod:
```bash
kubectl get pods -l app=mongodb
```

2. Verificar el servicio:
```bash
kubectl get svc mongo-service
```

3. Verificar la persistencia:
```bash
kubectl get pv,pvc
```

## Conexión

Los otros servicios pueden conectarse usando:
```
mongodb://mongo-service:27017
```

## Logs

Ver logs del pod:
```bash
kubectl logs -f deployment/mongodb
```

## Respaldo y Restauración

### Crear Backup
```bash
kubectl exec -it <pod-name> -- mongodump --out /data/backup
```

### Restaurar Backup
```bash
kubectl exec -it <pod-name> -- mongorestore /data/backup
```

## Solución de Problemas

1. **Pod no inicia**:
   - Verificar logs del pod
   - Comprobar PV y PVC
   - Verificar permisos de almacenamiento

2. **Problemas de conexión**:
   - Verificar que el servicio está corriendo
   - Comprobar la resolución DNS del servicio
   - Verificar la configuración de red

3. **Problemas de persistencia**:
   - Verificar el estado del PV y PVC
   - Comprobar los permisos del directorio de datos
   - Verificar el espacio disponible 