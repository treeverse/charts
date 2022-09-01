# lakeFS Helm Chart

A Helm chart to deploy lakeFS on Kubernetes.

## Installing the Chart

First, add the lakeFS helm repository:

```bash
helm repo add lakefs https://charts.lakefs.io
```
### Quickstart

For learning purposes, you can install lakeFS with the following commands:

```bash
# Deploy lakeFS with helm release "my-lakefs"
helm install my-lakefs lakefs/lakefs
```

This will start lakeFS with a dedicated PostgreSQL container. Data will be stored inside the container and will not be persisted.

### Custom Configuration

To install the chart with custom configuration values:

```bash
# Deploy lakeFS with helm release "my-lakefs"
helm install -f my-values.yaml my-lakefs lakefs/lakefs
```

Example my-values.yaml:

```yaml
secrets:
  databaseConnectionString: postgres://postgres:myPassword@my-lakefs-db.rds.amazonaws.com:5432/lakefs?search_path=lakefs
  authEncryptSecretKey: <some random string>
lakefsConfig: |
  blockstore:
    type: s3
    s3:
      region: us-east-1
  gateways:
    s3:
      domain_name: s3.lakefs.example.com
```

The `lakefsConfig` parameter is the lakeFS configuration documented [here](https://docs.lakefs.io/reference/configuration.html), but without sensitive information.
Sensitive information like `database_connection_string` is given through "secrets" section, and will be injected into Kubernetes secrets.

You should give your Kubernetes nodes access to all S3 buckets you intend to use lakeFS with.
If you can't provide such access, lakeFS can be configured to use an AWS key-pair to authenticate (part of the `lakefsConfig` YAML below).

## Major Chart Upgrades

### Upgrading from chart version 0.5.XX or lower (lakeFS v0.70.XX or lower)
Introducing [lakeFS v0.80.0](https://github.com/treeverse/lakeFS/releases/tag/v0.80.0), with **Key Value Store** support. As part of this upgrade, the entire database will be ported to the new KV.
Before performing this upgrade, it is strongly recommended to perform these steps:
* Commit all uncommitted data on branches
* Create a snapshot of your database

In order to prevent loss of data during this process it is recommended to stop all the pods running `lakeFS`. This can be achieved by scaling the number of pods down to 0:
```bash
# Stopping all pods running release my-lakefs
kubectl scale --replicas=0 deployment my-lakefs
```

Once all `lakeFS` pods are stopped, you can upgrade using the `upgrade` command
```bash
# Upgrade lakeFS to the latest helm release
helm upgrade -f my-values.yaml my-lakefs lakefs/lakefs
```


## Configurations
| **Parameter**                               | **Description**                                                                                            | **Default** |
|---------------------------------------------|------------------------------------------------------------------------------------------------------------|-------------|
|`secrets.databaseConnectionString`|PostgreSQL connection string to be used by lakeFS||
|`secrets.authEncryptSecretKey`|A random (cryptographically safe) generated string that is used for encryption and HMAC signing||
| `lakefsConfig`                              | lakeFS config YAML stringified, as shown above. See [reference](https://docs.lakefs.io/reference/configuration.html) for available configurations.                                                               |             |
| `replicaCount`                              | Number of lakeFS pods                                                                                      | `1`         |
| `resources`                                 | Pod resource requests & limits                                                                             | `{}`        |
| `service.type`                              | Kuberenetes service type                                                                                   | ClusterIP   |
| `service.port`                              | Kubernetes service external port                                                                           | 80          |
| `extraEnvVars`                        | Adds additional environment variables to the deployment (in yaml syntax) | `{}` See [values.yaml](values.yaml) |
| `extraEnvVarsSecret`                        | Name of a Kubernetes secret containing extra environment variables |
| `s3Fallback.enabled`                            | If set to true, an [S3Proxy](https://github.com/gaul/s3proxy) container will be started. Requests to lakeFS S3 gateway with a non-existing repository will be forwarded to this container.
| `s3Fallback.aws_access_key` | An AWS access key to be used by the S3Proxy for authentication |
| `s3Fallback.aws_secret_key` | An AWS secret key to be used by the S3Proxy for authentication |
| `committedLocalCacheVolume` | A volume definition to be mounted by lakeFS and used for caching committed metadata. See [here](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types) for a list of supported volume types. The default values.yaml file shows an example of how to use this parameter. |