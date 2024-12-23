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

This will start lakeFS while data will be stored inside the container and will not be persisted.

### Custom Configuration

To install the chart with custom configuration values:

```bash
# Deploy lakeFS with helm release "my-lakefs"
helm install -f my-values.yaml my-lakefs lakefs/lakefs
```

Example `my-values.yaml` using PostgreSQL:

```yaml
secrets:
  databaseConnectionString: postgres://postgres:myPassword@my-lakefs-db.rds.amazonaws.com:5432/lakefs?search_path=lakefs
  authEncryptSecretKey: <some random string>
lakefsConfig: |
  database:
    type: postgres
  blockstore:
    type: s3
    s3:
      region: us-east-1
  gateways:
    s3:
      domain_name: s3.lakefs.example.com
```

Example `my-values.yaml` using PostgreSQL with Cloud SQL Auth Proxy in GCP:

```yaml
secrets:
    databaseConnectionString: postgres://<DB_USERNAME>:<DB_PASSWORD>@localhost:5432/<DB_NAME>
    authEncryptSecretKey: <some random string>
lakefsConfig: |
  database:
    type: postgres
  blockstore:
    type: gs
    gs:
      credentials_json: '<credentials_json>'
serviceAccount:
  name: <service account name>
gcpFallback:
  enabled: true
  instance: <my_project>:<my_region>:<my_instance>=tcp:5432
```

Example `my-values.yaml` using DynamoDB:
```yaml
secrets:
  authEncryptSecretKey: <some random string>
lakefsConfig: |
  database:
    type: dynamodb
    dynamodb:
      table_name: my-lakefs
      aws_region: us-east-1
  blockstore:
    type: s3
    s3:
      region: us-east-1
  gateways:
    s3:
      domain_name: s3.lakefs.example.com
```

The `lakefsConfig` parameter is the lakeFS configuration documented [here](https://docs.lakefs.io/reference/configuration.html), but without sensitive information.
Sensitive information like `database_connection_string` (used by PostgreSQL) is given through "secrets" section, and will be injected into Kubernetes secrets.

You should give your Kubernetes nodes access to all S3 buckets (or other resources) you intend to use lakeFS with.
If you can't provide such access, lakeFS can be configured to use an AWS key-pair to authenticate (part of the `lakefsConfig` YAML).

## Notable Chart Upgrades

### Upgrading from chart version 0.9.4 or lower

Introducing changes to the [security model in lakeFS](https://docs.lakefs.io/posts/security_update.html)  
The lakeFS service will not run if the migration version isn't compatible with the binary.
Before running the new version you will be required to run migrate, with the new version.
Please refer to this [upgrade documentation](https://docs.lakefs.io/reference/access-control-lists.html#migrating-from-the-previous-version-of-acls) for more information on the specific migration from RBAC to ACL

### Upgrading from chart version 0.7.XX or lower

If you are using Postgres as your database, make sure your `lakefsConfig` property contains the key `database.type` and that it is set to `postgres`. Before this version, the Helm chart set this property implicitly.

### Upgrading from chart version 0.5.XX or lower (lakeFS v0.70.XX or lower)

Introducing [lakeFS v0.80.0](https://github.com/treeverse/lakeFS/releases/tag/v0.80.0), with **Key Value Store** support. As part of this upgrade, the entire database will be ported to the new KV.
Before performing this upgrade, it is strongly recommended to perform these steps:
* Commit all uncommitted data on branches
* Create a snapshot of your database

In order to prevent loss of data during this process, it is recommended to stop all the pods running `lakeFS`.
This can be achieved by scaling the number of pods down to 0:

```bash
# Stopping all pods running release my-lakefs
kubectl scale --replicas=0 deployment my-lakefs
```

Once all `lakeFS` pods are stopped, you can upgrade using the `upgrade` command

```bash
# Upgrade lakeFS to the latest helm release
helm upgrade -f my-values.yaml my-lakefs lakefs/lakefs --set kv_upgrade=true
```

**Please note the `kv_upgrade` flag, which is required for this upgrade** (It is not required for a fresh installation of `lakeFS` with KV)


## Configurations

| **Parameter**                         | **Description**                                                                                                                                                                                                                                                                      | **Default**                         |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------|
| `secrets.databaseConnectionString`    | PostgreSQL connection string to be used by lakeFS. (Ignored when existingSecret is set)                                                                                                                                                                                              |                                     |
| `secrets.authEncryptSecretKey`        | A random (cryptographically safe) generated string that is used for encryption and HMAC signing. (Ignored when existingSecret is set)                                                                                                                                                |                                     |
| `existingSecret`                      | Name of existing secret to use for the chart's secrets (by default the charts create a secret to hold the authEncryptSecretKey and databaseConnectionString                                                                                                                          |                                     |
| `secretKeys.databaseConnectionString` | Name of key in existing secret to use for a PostgreSQL databaseConnectionString (no default). Only used when sed when `existingSecret is set`                                                                                                                                        |                                     |
| `secretKeys.authEncryptSecretKey`     | Name of key in existing secret to use for authEncryptSecretKey. Only used when existingSecret is set.                                                                                                                                                                                |                                     |
| `lakefsConfig`                        | lakeFS config YAML stringified, as shown above. See [reference](https://docs.lakefs.io/reference/configuration.html) for available configurations.                                                                                                                                   |                                     |
| `replicaCount`                        | Number of lakeFS pods                                                                                                                                                                                                                                                                | `1`                                 |
| `resources`                           | Pod resource requests & limits                                                                                                                                                                                                                                                       | `{}`                                |
| `service.type`                        | Kubernetes service type                                                                                                                                                                                                                                                              | ClusterIP                           |
| `service.port`                        | Kubernetes service external port                                                                                                                                                                                                                                                     | 80                                  |
| `extraEnvVars`                        | Adds additional environment variables to the deployment (in yaml syntax)                                                                                                                                                                                                             | `{}` See [values.yaml](values.yaml) |
| `extraEnvVarsSecret`                  | Name of a Kubernetes secret containing extra environment variables                                                                                                                                                                                                                   |                                     |
| `s3Fallback.enabled`                  | If set to true, an [S3Proxy](https://github.com/gaul/s3proxy) container will be started. Requests to lakeFS S3 gateway with a non-existing repository will be forwarded to this container.                                                                                           |                                     |
| `s3Fallback.aws_access_key`           | An AWS access key to be used by the S3Proxy for authentication                                                                                                                                                                                                                       |                                     |
| `s3Fallback.aws_secret_key`           | An AWS secret key to be used by the S3Proxy for authentication                                                                                                                                                                                                                       |                                     |
| `gcpFallback.enabled`                 | If set to true, an [GCP Proxy](https://github.com/GoogleCloudPlatform/cloud-sql-proxy) container will be started.                                                                                                                                                                    |                                     |
| `gcpFallback.instance`                | The instance to connect to. See the example above for the format.                                                                                                                                                                                                                                                        |                                     |
| `committedLocalCacheVolume`           | A volume definition to be mounted by lakeFS and used for caching committed metadata. See [here](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types) for a list of supported volume types. The default values.yaml file shows an example of how to use this parameter. |                                     |
| `serviceAccount.name`                 | Name of the service account to use for the lakeFS pods. If not set, use the `default` service account.                                                                                                                                                                               |                                     |
