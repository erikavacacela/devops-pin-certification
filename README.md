# Welcome to devops-pin-certification

## Crear y configurar Máquina EC2


### Conexión de máquina local a AWS
Para ejecutar terraform se configuro un usuario con la política de permiso `AdministratorAccess`.
Se creo *access key* para la conexión remota.

Se utiliza el método [Environment Variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables)
para establecer las credenciales de acceso.


### Crear y configurar máquina EC2

**Carácteristicas**

* Region: us-west-1
* Sistema Operativo : Ubuntu Server 20.04
* Family (Tipo): t2.micro


**1. Crear Key Pairs**

Desde la consola de AWS *Services* > *EC2* > Sidebar *Network & Security* > *Keys Pair* > 
*Create key pair*

* **Name**: devops
* **Key pair type**: RSA
* **Private key file format**: .pem

Descargar el archivo .pem generado, este será usado posteriormente para la conexión a la instancia EC2.



**2. Crear Role para EC2**
Vamos a realizar una serie de configuraciones para permitir a la instancia de EC2 realizar las diferentes tareas que necesitaremos.

* En la barra de busqueda escribir IAM y Abrir la consola.
* Luego creamos un role siguiente el siguiente ﬂujo *IAM* > *Roles* > *Create Role*

* Type: AWS Service
* Choose a use case: EC2
* Attach permissions policies: AdministratorAccess
* Add tag:
    
    - Key: RoleName
    - Value: ec2-admin-role

Notes: El rol creado es asignado a la instancia EC2 [ec2.tf](/setup_cluster_terraform/instance_profile.tf#L3)

**3. Crear instancia EC2, security group**

```
cd setup_cluster_terraform

terraform init
terraform plan
terraform apply
```

Verificar en la consola AWS que la instancia EC2 ha sido creada.

*Desde EC2* > *EC2 Dashboard*

Se mostra la cantidad de recursos que tiene creado: instances, security groups, key pairs.

**Nota** Para eliminar los recursos creados, usar el comando:

```terraform destroy    ```


### Conectarse a una máquina EC2

* Clic en el Link del instance ID , esto abre las configuraciones.
* Connect
![ScreenShot](/images/1-ec2-connect.png)

* Seguir las instrucciones para asignar los permisos correspondientes al archivo .PEM y conectarse a la instancia EC2
Nota: Es posible que si están utilizando WSL en Windows (Ubuntu desde Windows), incluso luego de cambiar los permisos arroje un error:
![ScreenShot](/images/2-ec2-connect-issue.png)
Se soluciona corriendo la conexión SSH con `sudo`

## Crea cluster con Terraform

### Crear Cluster de EKS

[Documentación adicional]((https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html))

* Dentro de la instancia de EC2 clonamos el siguiente repositorio [devops-pin-certification](https://github.com/erikavacacela/devops-pin-certification)
* Luego navegamos a la carpeta eks_setup_terraform y ejecutamos los comandos siguientes:

```
terraform init
terraform apply
```
Esto puede tomar 15-20 Minutos.

En donde:
- `terraform init` Descarga los proveedores
- `terraform apply` Instala el proveedor de AWS EKS, vpc, security groups entre otros y luego despliega el cluster.


### Configurar kubectl

Para poder conectarnos al cluster tenemos que configurar:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```