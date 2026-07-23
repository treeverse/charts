# Changelog

# 1.12.14
:new: What's new:
- Update lakeFS community version to [1.84.0](https://github.com/treeverse/lakeFS/releases/tag/v1.84.0/)

# 1.12.13
:new: What's new:
- Add `service.trafficDistribution` value to set [trafficDistribution](https://kubernetes.io/docs/concepts/services-networking/service/#traffic-distribution) on the lakeFS Service (requires Kubernetes 1.31+)

# 1.12.12
:new: What's new:
- Update lakeFS Enterprise version to [1.91.0](https://docs.lakefs.io/releases/lakefs-enterprise/1.91.0/)

# 1.12.11
:new: What's new:
- Update lakeFS Enterprise version to [1.90.1](https://docs.lakefs.io/releases/lakefs-enterprise/1.90.1/)

# 1.12.10
:new: What's new:
- Update lakeFS Enterprise version to [1.90.0](https://docs.lakefs.io/releases/lakefs-enterprise/1.90.0/)

# 1.12.9
🆕 What's new:

Update lakeFS community version to 1.83.0

# 1.12.8
:new: What's new:
- Update lakeFS Enterprise version to [1.89.0](https://changelog.lakefs.io/lakefs-enterprise/1.89.0/)

# 1.12.7
:new: What's new:
- Update lakeFS Enterprise version to [1.88.0](https://changelog.lakefs.io/lakefs-enterprise/1.88.0/)

# 1.12.6
:books: Documentation:
- Clarify that lakeFS Enterprise images are public and a private registry token is not required

# 1.12.5
:new: What's new:
- Update lakeFS Enterprise version to [1.87.0](https://changelog.lakefs.io/lakefs-enterprise/1.87.0/)

# 1.12.4
:new: What's new:
- Update lakeFS community version to [1.82.0](https://github.com/treeverse/lakeFS/releases/tag/v1.82.0/)

# 1.12.3
:new: What's new:
- Update lakeFS Enterprise version to [1.86.0](https://changelog.lakefs.io/lakefs-enterprise/1.86.0/)
  - Important note: lakeFS Enterprise 1.86.0 adds auth inverse secondary indices. Deployments with local RBAC data require a one-time KV migration (`lakefs migrate up`) before rolling out the new version — see the [release notes](https://changelog.lakefs.io/lakefs-enterprise/1.86.0/) for details.

# 1.12.2
:new: What's new:
- Update lakeFS Enterprise version to [1.85.1](https://changelog.lakefs.io/lakefs-enterprise/1.85.1/)

# 1.12.1
:new: What's new:
- Update lakeFS Enterprise version to [1.85.0](https://changelog.lakefs.io/lakefs-enterprise/1.85.0/)

# 1.12.0
:new: What's new:
- MDS now reads the same lakeFS secrets as the server (database connection string, auth encrypt key, license token) via `existingSecret` / `secrets`, so `lakefs mds run` can open the KV store, build the catalog, and validate the license without a separate secret block. Added `mds.extraEnvVarsSecret` for additional env-from secrets.

# 1.11.1
:new: What's new:
- Update lakeFS community version to [1.81.1](https://github.com/treeverse/lakeFS/releases/tag/v1.81.1/)

# 1.11.0
:new: What's new:
- Update lakeFS Enterprise version to [1.84.0](https://changelog.lakefs.io/lakefs-enterprise/1.84.0/)

# 1.10.0
:new: What's new:
- MDS now runs on the `treeverse/lakefs-enterprise` image via `lakefs mds run` and uses the `metadata_search` config schema.
- Added `mds.command` and `mds.args` for overriding the MDS container entrypoint and arguments.

# 1.9.4
:new: What's new:
- Update lakeFS Enterprise version to [1.83.0](https://changelog.lakefs.io/changelog/releases/v1.83.0/)

# 1.9.3
:new: What's new:
- Update lakeFS community version to [1.81.0](https://github.com/treeverse/lakeFS/releases/tag/v1.81.0/)

# 1.9.2
:new: What's new:
- Update lakeFS Enterprise version to [1.82.0](https://changelog.lakefs.io/changelog/releases/v1.82.0/)
- Add audit log maintenance CronJob support (Enterprise-only). Runs compaction, snapshot expiration, orphan cleanup, and lakeFS commit on a configurable schedule (default: every hour). Enable with `auditLog.enabled: true` and `auditLog.maintenance: true`.

# 1.9.1
:new: What's new:
- Update lakeFS Enterprise version to [1.81.0](https://changelog.lakefs.io/changelog/releases/v1.81.0/)

# 1.9.0
:new: What's new:
- Decouple lakeFS image tag from `Chart.AppVersion`: select community or enterprise tag via `image.community.tag` / `image.enterprise.tag` based on the `enterprise.enabled` flag

# 1.8.1
:new: What's new:
- Update lakeFS version to [1.80.0](https://github.com/treeverse/lakeFS/releases/tag/v1.80.0)

# 1.8.0
:new: What's new:
- Remove image tag from mds (will take latest tag)

# 1.7.22
:new: What's new:
- Update lakeFS version to [1.79.0](https://github.com/treeverse/lakeFS/releases/tag/v1.79.0)

# 1.7.21
:new: What's new:
- Add support for replication service (Enterprise-only feature)

# 1.7.20
:bug: Bugs fixed:
- Fix MDS crash when securityContext sets a different runAsUser by adding PYTHONPATH workaround

# 1.7.19
:new: What's new:
- Update lakeFS version to [1.78.0](https://github.com/treeverse/lakeFS/releases/tag/v1.78.0)

# 1.7.18
:new: What's new:
- Update lakeFS version to [1.77.0](https://github.com/treeverse/lakeFS/releases/tag/v1.77.0)

# 1.7.17
:new: What's new:
- Update lakeFS version to [1.76.0](https://github.com/treeverse/lakeFS/releases/tag/v1.76.0)

# 1.7.16
:new: What's new:
- Update lakeFS version to [1.75.0](https://github.com/treeverse/lakeFS/releases/tag/v1.75.0)

# 1.7.15
:new: What's new:
- Update lakeFS version to [1.74.4](https://github.com/treeverse/lakeFS/releases/tag/v1.74.4)
  
# 1.7.14
:new: What's new:
- Update lakeFS version to [1.74.2](https://github.com/treeverse/lakeFS/releases/tag/v1.74.2)

# 1.7.13
:new: What's new:
- Update lakeFS version to [1.74.1](https://github.com/treeverse/lakeFS/releases/tag/v1.74.1)

# 1.7.12

:new: What's new:
- Update lakeFS version to [1.73.0](https://github.com/treeverse/lakeFS/releases/tag/v1.73.0)

# 1.7.11

:new: What's new:
- Update lakeFS version to [1.72.0](https://github.com/treeverse/lakeFS/releases/tag/v1.72.0)

# 1.7.9

:new: What's new:
- Update lakeFS version to [1.71.0](https://github.com/treeverse/lakeFS/releases/tag/v1.71.0)
- Update metadata search version to v0.2.1

# 1.7.9

:new: What's new:
- Update lakeFS version to [1.70.1](https://github.com/treeverse/lakeFS/releases/tag/v1.70.1)

# 1.7.8

:bug: Bugs fixed:
- Prevent overlapping mounts: use subPath to mount the config file at `/etc/lakefs/config.yaml` so `/etc/lakefs/license.tkn` can be mounted separately

# 1.7.7

:new: What's new:
- Update lakeFS version to [1.69.0](https://github.com/treeverse/lakeFS/releases/tag/v1.69.0)

# 1.7.6

:new: What's new:
- Update lakeFS version to [1.68.0](https://github.com/treeverse/lakeFS/releases/tag/v1.68.0)

# 1.7.5

:new: What's new:
- Update lakeFS version to [1.67.0](https://github.com/treeverse/lakeFS/releases/tag/v1.67.0)

# 1.7.4

:new: What's new:
- Update lakeFS version to [1.66.0](https://github.com/treeverse/lakeFS/releases/tag/v1.66.0)

# 1.7.3

:new: What's new:
- Update lakeFS version to [1.65.2](https://github.com/treeverse/lakeFS/releases/tag/v1.65.2)

# 1.7.2

:new: What's new:
- Update lakeFS version to [1.65.1](https://github.com/treeverse/lakeFS/releases/tag/v1.65.1)

# 1.7.1

:new: What's new:
- Update lakeFS version to [1.65.0](https://github.com/treeverse/lakeFS/releases/tag/v1.65.0)

# 1.7.0

:new: What's new:
- Support Metadata Search

# 1.6.2

:new: What's new:
- Update lakeFS version to [1.64.1](https://github.com/treeverse/lakeFS/releases/tag/v1.64.1)

# 1.6.1

:new: What's new:
- Update lakeFS version to [1.64.0](https://github.com/treeverse/lakeFS/releases/tag/v1.64.0)

# 1.6.0

:new: What's new:
- Add license support to helm chart

# 1.5.0

### Important
Fluffy is no longer supported in this chart version, and all authentication capabilities (LDAP, OIDC, SAML, AWS IAM) are now built directly into lakeFS Enterprise.
lakeFS-Enterprise image is now required for all enterprise authentication capabilities to work.
For more information, see the [migration guide](https://docs.lakefs.io/latest/enterprise/upgrade/#kubernetes-migrating-with-helm-from-fluffy-to-new-lakefs-enterprise).

:new: What's new:
- Update lakeFS version to [1.63.0](https://github.com/treeverse/lakeFS/releases/tag/v1.63.0)

# 1.4.20

:new: What's new:
- Update lakeFS version to [1.62.0](https://github.com/treeverse/lakeFS/releases/tag/v1.62.0)

# 1.4.19

:new: What's new:
- Update lakeFS version to [1.61.0](https://github.com/treeverse/lakeFS/releases/tag/v1.61.0)
- Update fluffy version to [0.13.2](https://github.com/treeverse/fluffy/releases/tag/v0.13.2), with latest security updates

# 1.4.18

:new: What's new:
- Update lakeFS version to [1.60.0](https://github.com/treeverse/lakeFS/releases/tag/v1.60.0)

# 1.4.17

:new: What's new:
- Update lakeFS version to [1.59.0](https://github.com/treeverse/lakeFS/releases/tag/v1.59.0)

# 1.4.14

:new: What's new:
- Update lakeFS version to [1.58.0](https://github.com/treeverse/lakeFS/releases/tag/v1.58.0)

## 1.4.13

:new: What's new:
- Update lakeFS version to [1.57.0](https://github.com/treeverse/lakeFS/releases/tag/v1.57.0)

## 1.4.12

:new: What's new:
- Update lakeFS version to [1.56.0](https://github.com/treeverse/lakeFS/releases/tag/v1.56.0)

## 1.4.11

:new: What's new:
- Update lakeFS version to [1.55.0](https://github.com/treeverse/lakeFS/releases/tag/v1.55.0)

## 1.4.10

:new: What's new:
- Update fluffy version to [0.11.0](https://github.com/treeverse/fluffy/releases/tag/v0.11.0), support multi resource policies 

## 1.4.9

:new: What's new:
- Update lakeFS version to [1.54.0](https://github.com/treeverse/lakeFS/releases/tag/v1.54.0)

## 1.4.7

:new: What's new:
- Update lakeFS version to [1.53.1](https://github.com/treeverse/lakeFS/releases/tag/v1.53.1)

## 1.4.6

:new: What's new:
- Update lakeFS version to [1.53.0](https://github.com/treeverse/lakeFS/releases/tag/v1.53.0)

## 1.4.5

:new: What's new:
- Update lakeFS version to [1.52.0](https://github.com/treeverse/lakeFS/releases/tag/v1.52.0)

## 1.4.4

:new: What's new:
- Update lakeFS version to [1.51.0](https://github.com/treeverse/lakeFS/releases/tag/v1.51.0)

## 1.4.3

:new: What's new:
- Fix v1.4.1 and v1.4.2 to use Fluffy v0.9.0 - v0.8.4 wasn't published

## 1.4.2

:new: What's new:
- Update lakeFS version to [1.50.0](https://github.com/treeverse/lakeFS/releases/tag/v1.50.0)

## 1.4.1

:new: What's new:
- Update Fluffy version to 0.8.4

## 1.4.0

### Important

This chart introduces the use of lakeFS-Enterprise image when using fluffy.
For enterprise users when upgrading to this chart, either:
1. Remove the `image.repository` configuration from your `values.yaml` file so that the correct image is fetched
2. Modify the value to `treeverse/lakefs-enterprise`

**This chart is backwards compatible and does not require any special migration**

:new: What's new:
- Updated lakeFS version to [1.49.1](https://github.com/treeverse/lakeFS/releases/tag/v1.49.1)

## 1.3.33

:new: What's new:
- Updated lakeFS version to [1.49.1](https://github.com/treeverse/lakeFS/releases/tag/v1.49.1)


## 1.3.32

:new: What's new:
- Updated lakeFS version to [1.49.0](https://github.com/treeverse/lakeFS/releases/tag/v1.49.0)

## 1.3.31

:new: What's new:
- Update Fluffy version to 0.8.3

## 1.3.30

:new: What's new:
- Updated lakeFS version to [1.48.2](https://github.com/treeverse/lakeFS/releases/tag/v1.48.2)

## 1.3.29

:new: What's new:
- Updated lakeFS version to [1.48.1](https://github.com/treeverse/lakeFS/releases/tag/v1.48.1)

## v1.3.28

### Do **NOT** use this version, 1.48.0 breaks backwards compatibility

:new: What's new:
- Updated lakeFS version to [1.48.0](https://github.com/treeverse/lakeFS/releases/tag/v1.48.0)

## v1.3.27

:new: What's new:
- Updated lakeFS version to [1.47.0](https://github.com/treeverse/lakeFS/releases/tag/v1.47.0)

## v1.3.26

:new: What's new:
- Updated lakeFS version to [1.46.0](https://github.com/treeverse/lakeFS/releases/tag/v1.46.0)

## v1.3.24

:new: What's new:
- Updated lakeFS version to [1.45.0](https://github.com/treeverse/lakeFS/releases/tag/v1.45.0)
- Updated fluffy version to [0.8.0](https://github.com/treeverse/fluffy/releases/tag/v0.8.0)

## v1.3.23

:new: What's new:
- Updated lakeFS version to [1.44.0](https://github.com/treeverse/lakeFS/releases/tag/v1.44.0)

## v1.3.19

:new: What's new:
- Updated lakeFS version to [1.43.0](https://github.com/treeverse/lakeFS/releases/tag/v1.43.0)

## v1.3.18

:new: What's new:
- Updated lakeFS version to [1.42.0](https://github.com/treeverse/lakeFS/releases/tag/v1.42.0)
