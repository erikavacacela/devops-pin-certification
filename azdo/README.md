# Azure Devops Setup

La configuración de Azure Devops consiste en crear una cuenta, crear un proyecto, crear un repositorio de azure
repos y agregar el cluster de kubernetes.

Es necesario crear una cuenta gratuita en https://dev.azure.com/ y crear un proyecto azure Devops

1. Desde la organización creada por defecto al crear la cuenta seleccionar `+ New Project`

2. Definir un nombre, tipo de proyecto publico y proceso agile.

3. Una vez creado instanciar un repositorio con un readme por defecto.

4. Crear un archivo con el nombre nginx-deployment.yaml y pegamos el código con este aquí [nginx-deployment.yaml](/azdo/nginx-deployment.yaml)



## Agregar el cluster de Kubernetes a Azure Devops

Para poder configurar el cluster en AzDO vamos a crear un ServiceAccount en kubernetes (provee una identidad para
procesos que corren en un pod). Luego se agrega a AzDo como Service Connection para poder utilizarla en los pipelines.


### Crear ServiceAccount

**1. Crear ServiceAccount para Azure Devops**

Acceder a la instancia EC2 y ejecutar en el cluster kubernetes.
```
cd azdo
Kubectl apply -f ado-admin-service-account.yaml
```

**2. Obtener secret asociado**

Ejecutar el siguiente comando para obtener el `name` del secret.
```
kubectl get serviceAccounts ado -n kube-system -o=jsonpath={.secrets[*].name}
```

Ejecutar el siguiente comando para obtener el secret. Remplazar `[secret-name]` por el valor obtenido con el comando anterior.

```
kubectl get secret [secret-name] -n kube-system -o json
```
Copiar el contenido del objeto **Secret** y convertirlo en formato yaml.

**3. Obtener Server URL del cluster kubernetes**

Desde la consola de la instancia de EC2
```
kubectl cluster-info | grep -E 'Kubernetes master|Kubernetes control plane' | awk '/http/ {print $NF}'
```

### Agregar cuenta de servicio

Desde *Project Settings* > *Service Connection* > *new service connection* > Elegimos *Kubernetes*

Utilizamos los datos del paso anterior:

* Authentication method: `Service Account`
* Server Url: Establecer la url obtenida en el paso `3. Obtener Server URL del cluster kubernetes`
* Authorization, Secret: Pegar el contenido del objeto **Secret** y convertido en formato yaml.
* Details, Service connection name: `eks-mundos-e-2`
* Security: Seleccionar el checkbox `Grant access permission to all pipelines`


## Azure Devops Pipeline Setup

Para realizar el despliegue de nginx (Web) al cluster vamos a utilizar un archivo de deployment que también contiene un servicio del tipo Load Balancer (Externo) nginx-deployment.yaml repo.

* Dentro del proyecto de Azure Devops > *Pipelines* > *New Pipeline*

Seguimos el navegador con las selecciones que se detallan abajo.

![ScreenShot](/assets/images/az-1-pipeline-connect.png)

![ScreenShot](/assets/images/az-2-pipeline-select.png)

![ScreenShot](/assets/images/az-3-pipeline-configure.png)


Reemplazamos el código con este aquí [azure-pipelines.yaml](/azdo/azure-pipelines.yml) (cambiar el nombre de la conexión por el que hayan seleccionado)


![ScreenShot](/assets/images/az-4-pipeline-review.png)


Guardar y ejecutar

![ScreenShot](/assets/images/az-5-pipeline-save-run.png)

Al salvar el pipeline se va a iniciar el mismo de manera automática y finalmente podemos inspeccionar el job para ver en el paso del manifiesto la url creada para la nginx.

### Errores encontrados

* No hosted parallelism has been purchased or granted. To request a free parallelism grant, please fill out the following form https://aka.ms/azpipelines-parallelism-request.

Para solucionar ir  *Project Settings* > *Pipelines* > *Parallel jobs*

Solución 1. Configurar Self-hosted, esto para desplegar en nuestra maquina local un agente para ejecutar el pipeline

Solución 2. Llenar el formulario que indica el error y esperar que azure responda habilitando la capa libre.

Solución 3. Activar Billing y establecer en 1 paid parallel jobs

![ScreenShot](/assets/images/az-6-issue.png)