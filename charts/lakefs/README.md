# lakeFS Helm Chart

A Helm chart to deploy lakeFS on Kubernetes.

## Installing the Chart

To install the chart with Helm Release *my-release* run the following commands:

```bash
# Add the lakeFS repository
helm repo add lakefs https://charts.lakefs.io
# Deploy lakeFS
helm install -f m-values.yaml my-release lakefs/lakefs
```

Example my-values.yaml:

```yaml
service:
    type: LoadBalancer
lakefsConfig: |
  database:
    connection_string: postgres://postgres:myPassword@my-lakefs-db.rds.amazonaws.com:5432/lakefs?search_path=lakefs
  auth:
    encrypt:
      secret_key: <some random string>
  blockstore:
    type: s3
    s3:
      region: us-east-1
  gateways:
    s3:
      domain_name: s3.lakefs.example.com
```

You should give your Kubernetes nodes access to all S3 buckets you intend to use lakeFS with.
If you can't provide such access, lakeFS can be configured to use an AWS key-pair to authenticate (part of the `lakefsConfig` YAML below).


## Configurations
| **Parameter**                               | **Description**                                                                                            | **Default** |
|---------------------------------------------|------------------------------------------------------------------------------------------------------------|-------------|
| `lakefsConfig`                              | lakeFS config YAML stringified, as shown above. See [reference](https://docs.lakefs.io/reference/configuration.html) for available configurations.                                                               |             |
| `replicaCount`                              | Number of lakeFS pods                                                                                      | `1`         |
| `resources`                                 | Pod resource requests & limits                                                                             | `{}`        |
| `service.type`                              | Kuberenetes service type                                                                                   | ClusterIP   |
| `service.port`                              | Kubernetes service external port                                                                           | 80          |
