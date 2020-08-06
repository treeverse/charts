# lakeFS Helm Chart

A Helm chart to deploy lakeFS on Kubernetes.

## Installing the Chart

To install the chart with Helm Release *my-release* run the following commands:

```bash
# Add the lakeFS repository
helm repo add lakefs https://charts.lakefs.io
# Deploy lakeFS
helm install lakefs/lakefs -f my-values.yaml --name my-release
```

You should give your Kubernetes nodes access to all S3 buckets you intend to use lakeFS with.
If you can't provide such access, you can use an AWS key-pair to authenticate (see configurations below). 

## Configurations
| **Parameter**                               | **Description**                                                                                            | **Default** |
|---------------------------------------------|------------------------------------------------------------------------------------------------------------|-------------|
| `blockstore.type`                           | Type of storage to use: `s3`, `local`, `mem`                                                               |             |
| `blockstore.s3.region`                      | AWS region where to use for storage                                                                        |             |
| `blockstore.s3.credentials.accessKeyId`     | AWS Access Key to use when accessing S3. Leave empty if your Kuberenets nodes have access to your buckets. |             |
| `blockstore.s3.credentials.secretAccessKey` | AWS Secret Key to use when accessing S3. Leave empty if your Kuberenets nodes have access to your buckets. |             |
| `gateways.s3.domain_name` | Domain name to be used by clients to call the lakeFS S3-compatible API |             |
| `databaseConnectionString`                  | Connection string to your lakeFS database                                                                  |             |
| `authEncryptSecretKey`                      | A cryptographically secure random string                                                                   |             |
| `replicaCount`                              | Number of lakeFS pods                                                                                      | `1`         |
| `resources`                                 | Pod resource requests & limits                                                                             | `{}`        |
| `service.type`                              | Kuberenetes service type                                                                                   | ClusterIP   |
| `service.port`                              | Kubernetes service external port                                                                           | 80          |
