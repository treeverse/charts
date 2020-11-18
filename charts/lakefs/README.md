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
| `extraEnvVarsSecret`                        | Name of a Kubernetes secret containing extra environment variables |